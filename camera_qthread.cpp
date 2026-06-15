#include "camera_qthread.h"
#include "mediapipeline.h"
#include <QLoggingCategory>
#include <QtEndian>
#include <QElapsedTimer>

Q_LOGGING_CATEGORY(camLog, "camera", QtInfoMsg)

Camera_qthread *Camera_qthread::CameraHandleSingle = nullptr;
pthread_mutex_t Camera_qthread::camera_mutex = PTHREAD_MUTEX_INITIALIZER;
AbstractCamera *Camera_qthread::camera_handle = nullptr;
Camera_qthread::Camera_qthread() { CLEAR(m_camera); }

// 打开摄像头节点，默认640x480
bool Camera_qthread::set_device(QString device, int in_width, int in_height) {
  int ret;
  bool boolvalue;

  // 参数验证
  if (in_width <= 0 || in_height <= 0) {
    qCCritical(camLog, "CAM: invalid dimensions: %d x %d", in_width,
            in_height);
    return false;
  }

  // CSI media pipeline 初始化（USB 摄像头无 sensor 实体，自动跳过）
  MediaPipeline::setupAll(in_width, in_height);

  CLEAR(m_camera);
  QByteArray devBytes = device.toUtf8();
  strncpy(m_camera.dev_name, devBytes.data(), sizeof(m_camera.dev_name) - 1);
  m_camera.dev_name[sizeof(m_camera.dev_name) - 1] = '\0';
  ret = open_device(m_camera.dev_name);
  if (ret < 0)
    return false;
  boolvalue = isMultiCamera(ret);
  if (!boolvalue) {
    close(m_camera.fd);
    return false;
  }
  m_camera.fd = ret;
  m_camera.width = in_width;
  m_camera.height = in_height;

  // 获取 CSI pipeline 配置后的实际分辨率（USB 设备返回 false，使用默认值）
  int actual_w = in_width, actual_h = in_height;
  if (MediaPipeline::getActualResolution(device, actual_w, actual_h)) {
    m_camera.width = actual_w;
    m_camera.height = actual_h;
    qCInfo(camLog, "CAM: using CSI actual resolution: %dx%d", actual_w, actual_h);
  }

  // 初始化摄像头、申请buffer并映射
  ret = camera_handle->init_device(m_camera);
  if (ret < 0) {
    qCCritical(camLog, "CAM: init_device failed");
    goto err_handle_scan;
  }
  qCDebug(camLog, "CAM: before STREAMON: %s fd=%d %dx%d fmt=%.4s planes=%d len=%zu",
          m_camera.dev_name, m_camera.fd, m_camera.width, m_camera.height,
          (char*)&m_camera.pixelformat, m_camera.NUM_PLANES, m_camera.frame_length);
  // 开启摄像头流
  ret = camera_handle->start_capturing(m_camera);
  if (ret < 0) {
    qCCritical(camLog, "CAM: start_capturing failed");
    goto err_handle_scan;
  }

  return true;
err_handle_scan:
  camera_handle->exit_device(m_camera);
  delete camera_handle;
  camera_handle = nullptr;
  return false;
}
// 判断摄像头能力，主要区分 V4L2_CAP_VIDEO_CAPTURE_MPLANE |
// V4L2_CAP_VIDEO_CAPTURE
bool Camera_qthread::isMultiCamera(int fd) {
  struct v4l2_capability cap;
  CLEAR(cap);
  if (-1 == xioctl(fd, VIDIOC_QUERYCAP, &cap)) {
    qCWarning(camLog, "CAM: VIDIOC_QUERYCAP error: %d", errno);
    return false;
  }
  if ((cap.capabilities & V4L2_CAP_VIDEO_CAPTURE_MPLANE)) {
    m_camera.capabilities = 0x0 | V4L2_CAP_VIDEO_CAPTURE_MPLANE;
    camera_handle = new MultiCamera;
    qCInfo(camLog, "CAM: %s → MPLANE (CSI)", m_camera.dev_name);
  } else if ((cap.capabilities & V4L2_CAP_VIDEO_CAPTURE)) {
    m_camera.capabilities = 0x0 | V4L2_CAP_VIDEO_CAPTURE;
    camera_handle = new AbstractCamera;
    qCInfo(camLog, "CAM: %s → CAPTURE (USB)", m_camera.dev_name);
  } else {
    qCWarning(camLog, "CAM: %s doesn't support CAPTURE", m_camera.dev_name);
    return false;
  }
  if ((cap.capabilities & V4L2_CAP_STREAMING)) {
    qCDebug(camLog, "CAM: %s supports STREAMING", m_camera.dev_name);
  } else {
    qCWarning(camLog, "CAM: %s doesn't support STREAMING", m_camera.dev_name);
    delete camera_handle;
    camera_handle = nullptr;
    return false;
  }
  return true;
}
// 停止摄像头循环取帧并释放资源
void Camera_qthread::exit_camera() {
  if (camera_handle == nullptr)
    return;
  frameLoop.store(false);
  wait();
  if (onebuf != nullptr) {
    free(onebuf);
    onebuf = nullptr;
  }
  camera_handle->stop_capturing(m_camera);
  camera_handle->exit_device(m_camera);
  delete camera_handle;
  camera_handle = nullptr;
}

int Camera_qthread::open_device(char *dev_name) {
  int ret;
  ret = open(dev_name, O_RDWR /* required */ /* | O_NONBLOCK*/, 0);

  if (ret == -1) {
    qCWarning(camLog, "CAM: cannot open '%s': %d", dev_name, errno);
    return -1;
  }
  return ret;
}

Camera_qthread *Camera_qthread::getInstance() {
  if (CameraHandleSingle != nullptr)
    return CameraHandleSingle;
  pthread_mutex_lock(&camera_mutex);
  if (CameraHandleSingle == nullptr) {
    CameraHandleSingle = new Camera_qthread;
  }
  pthread_mutex_unlock(&camera_mutex);
  return CameraHandleSingle;
}
// 摄像头取帧函数
void Camera_qthread::run() {
  struct v4l2_buffer buf;
  int ret;
  QImage img;
  int frameCount = 0;
  QElapsedTimer fpsTimer;
  struct pollfd Fds[1];
  Fds[0].fd = m_camera.fd;
  Fds[0].events = POLLIN;

  frameLoop.store(true);
  fpsTimer.start();
  qCDebug(camLog, "CAM: frame_length=%zu", (size_t)m_camera.frame_length);
  onebuf = (unsigned char *)calloc(m_camera.frame_length, sizeof(unsigned char));
  // 预分配 RGB 转换缓冲区，避免每帧栈分配 VLA
  unsigned char *rgbbuf = (unsigned char *)calloc(m_camera.width * m_camera.height * 3, 1);
  if (onebuf == nullptr || rgbbuf == nullptr) {
    free(onebuf); onebuf = nullptr;
    free(rgbbuf); rgbbuf = nullptr;
    goto streamoff_handle;
  }
  while (frameLoop.load()) {
    ret = poll(Fds, 1, 1000);
    if (ret == 0) {
      qCWarning(camLog, "CAM: poll I/O timeout");
      qCInfo(camLog, "CAM: %s reset on timeout", m_camera.dev_name);
      size_t oldFrameLen = m_camera.frame_length;
      size_t oldRgbLen   = (size_t)m_camera.width * m_camera.height * 3;
      camera_handle->stop_capturing(m_camera);
      camera_handle->exit_device(m_camera);
      delete camera_handle;
      camera_handle = nullptr;
      if (set_device(m_camera.dev_name)) {
        // 仅当缓冲区尺寸变化时才重新分配（避免每次超时都 free/malloc）
        if (m_camera.frame_length != oldFrameLen ||
            (size_t)m_camera.width * m_camera.height * 3 != oldRgbLen) {
          free(onebuf); onebuf = nullptr;
          free(rgbbuf); rgbbuf = nullptr;
          onebuf = (unsigned char *)calloc(m_camera.frame_length, 1);
          rgbbuf = (unsigned char *)calloc(m_camera.width * m_camera.height * 3, 1);
        }
        if (onebuf == nullptr || rgbbuf == nullptr)
          goto streamoff_handle;
        Fds[0].fd = m_camera.fd;
        Fds[0].events = POLLIN;
        frameCount = 0;
        fpsTimer.restart();
        continue;
      } else {
        qCCritical(camLog, "CAM: %s reset failed", m_camera.dev_name);
        goto streamoff_handle;
      }
    } else if (ret < 0) {
      qCWarning(camLog, "CAM: poll I/O err: %d", errno);
      goto streamoff_handle;
    }

    ret = camera_handle->framebuffer_handle(m_camera, buf, onebuf);
    if (ret < 0) {
      qCWarning(camLog, "CAM: camera handle failed");
      goto streamoff_handle;
    }

    frameCount++;

    if (m_camera.pixelformat == v4l2_fourcc_i('Y', 'U', 'Y', 'V')) {
      yuv_to_rgb(onebuf, rgbbuf);
      img = QImage(m_camera.width, m_camera.height, QImage::Format_RGB888);
      if (!img.isNull())
        memcpy(img.bits(), rgbbuf, m_camera.width * m_camera.height * 3);
    } else if (m_camera.pixelformat == v4l2_fourcc_i('M', 'J', 'P', 'G'))
      img = QImage::fromData(onebuf, m_camera.frame_length, "JPEG");
    else if (m_camera.pixelformat == v4l2_fourcc_i('R', 'G', 'B', '3')) {
      img = QImage(m_camera.width, m_camera.height, QImage::Format_RGB888);
      if (!img.isNull())
        memcpy(img.bits(), onebuf, m_camera.width * m_camera.height * 3);
    } else if (m_camera.pixelformat == v4l2_fourcc_i('R', 'G', 'B', 'R')) {
      img = QImage(m_camera.width, m_camera.height, QImage::Format_RGB16);
      if (!img.isNull())
        memcpy(img.bits(), onebuf, m_camera.frame_length);
    } else if (m_camera.pixelformat == v4l2_fourcc_i('N', 'V', '1', '2')) {
      nv12_to_rgb(onebuf, rgbbuf);
      img = QImage(m_camera.width, m_camera.height, QImage::Format_RGB888);
      if (!img.isNull())
        memcpy(img.bits(), rgbbuf, m_camera.width * m_camera.height * 3);
    }
    if (!img.isNull())
      emit sign_img(img);

    if (fpsTimer.elapsed() >= 5000) {
        double fps = frameCount * 1000.0 / fpsTimer.elapsed();
        qCDebug(camLog, "FPS: %.1f (frames=%d, duration=%lldms)",
                fps, frameCount, fpsTimer.elapsed());
        frameCount = 0;
        fpsTimer.restart();
    }
  }
  qCInfo(camLog, "CAM: camera loop end");
  free(onebuf); onebuf = nullptr;
  free(rgbbuf); rgbbuf = nullptr;
  return;
streamoff_handle:
  if (onebuf != nullptr) { free(onebuf); onebuf = nullptr; }
  if (rgbbuf != nullptr) { free(rgbbuf); rgbbuf = nullptr; }
  if (camera_handle != nullptr) {
    camera_handle->stop_capturing(m_camera);
    camera_handle->exit_device(m_camera);
    delete camera_handle;
    camera_handle = nullptr;
  }
  return;
}

int Camera_qthread::xioctl(int fh, int request, void *arg) {
  int r;
  do {
    r = ioctl(fh, request, arg);
  } while (-1 == r && EINTR == errno);

  return r;
}

void Camera_qthread::yuv_to_rgb(unsigned char *yuv, unsigned char *rgb) {
  // YUYV 4:2:2 → RGB888 整数转换（ITU-R BT.601 fixed-point）
  // YUYV 打包: [Y0 U Y1 V] [Y2 U Y3 V] ...
  // 每 4 字节产生 2 个 RGB 像素 (6 字节)
  const int npixels = m_camera.width * m_camera.height;
  int yIdx = 0, rgbIdx = 0;

  for (int i = 0; i < npixels; i += 2) {
    int Y0 = yuv[yIdx++] - 16;
    int U  = yuv[yIdx++] - 128;
    int Y1 = yuv[yIdx++] - 16;
    int V  = yuv[yIdx++] - 128;

    // Pixel 0
    int R0 = (298 * Y0 + 409 * V + 128) >> 8;
    int G0 = (298 * Y0 - 100 * U - 208 * V + 128) >> 8;
    int B0 = (298 * Y0 + 516 * U + 128) >> 8;

    rgb[rgbIdx++] = qBound(0, R0, 255);
    rgb[rgbIdx++] = qBound(0, G0, 255);
    rgb[rgbIdx++] = qBound(0, B0, 255);

    // Pixel 1
    int R1 = (298 * Y1 + 409 * V + 128) >> 8;
    int G1 = (298 * Y1 - 100 * U - 208 * V + 128) >> 8;
    int B1 = (298 * Y1 + 516 * U + 128) >> 8;

    rgb[rgbIdx++] = qBound(0, R1, 255);
    rgb[rgbIdx++] = qBound(0, G1, 255);
    rgb[rgbIdx++] = qBound(0, B1, 255);
  }
}

void Camera_qthread::nv12_to_rgb(unsigned char *nv12, unsigned char *rgb) {
  const quint8 *yPlane = nv12;
  const quint8 *uvPlane = nv12 + m_camera.width * m_camera.height;

  for (int y = 0; y < m_camera.height; y++) {
    for (int x = 0; x < m_camera.width; x++) {
      int index = (y * m_camera.width + x) * 3;
      int yIdx = y * m_camera.width + x;
      int uvIdx = ((y / 2) * m_camera.width + (x & ~1));

      int Y = yPlane[yIdx];
      int U = uvPlane[uvIdx] - 128;
      int V = uvPlane[uvIdx + 1] - 128;

      int R = qBound(0, (298 * Y + 409 * V + 128) >> 8, 255);
      int G = qBound(0, (298 * Y - 100 * U - 208 * V + 128) >> 8, 255);
      int B = qBound(0, (298 * Y + 516 * U + 128) >> 8, 255);

      rgb[index] = R;
      rgb[index + 1] = G;
      rgb[index + 2] = B;
    }
  }
}

Camera_qthread::AutoRelease::~AutoRelease() {
  // 只清理静态成员 camera_handle（嵌套类只能访问静态成员）
  // 注意：m_camera 的清理需要外部类析构时处理，这里只处理静态资源
  pthread_mutex_lock(&camera_mutex);
  if (camera_handle != nullptr) {
    // camera_handle 是静态成员，可以直接删除
    // 但 stop_capturing 和 exit_device 需要 m_camera，这里无法调用
    // 所以只删除对象，资源的清理应该在 exit_camera() 中完成
    delete camera_handle;
    camera_handle = nullptr;
  }
  pthread_mutex_unlock(&camera_mutex);
}
