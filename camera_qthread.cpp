#include "camera_qthread.h"
#include "mediapipeline.h"
#include <QtEndian>

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
    fprintf(stderr, "Invalid camera dimensions: %d x %d\n", in_width,
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
    qDebug() << "Using CSI actual resolution:" << actual_w << "x" << actual_h;
  }

  // 初始化摄像头、申请buffer并映射
  ret = camera_handle->init_device(m_camera);
  if (ret < 0) {
    printf("init_device failed\n");
    goto err_handle_scan;
  }
  // 开启摄像头流
  ret = camera_handle->start_capturing(m_camera);
  if (ret < 0) {
    printf("start_capturing failed\n");
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
    fprintf(stderr, "VIDIOC_QUERYCAP: error - %d\n", errno);
    return false;
  }
  if ((cap.capabilities & V4L2_CAP_VIDEO_CAPTURE_MPLANE)) {
    m_camera.capabilities = 0x0 | V4L2_CAP_VIDEO_CAPTURE_MPLANE;
    camera_handle = new MultiCamera;
    fprintf(stdout, "%s set V4L2_CAP_VIDEO_CAPTURE_MPLANE\n",
            m_camera.dev_name);
  } else if ((cap.capabilities & V4L2_CAP_VIDEO_CAPTURE)) {
    m_camera.capabilities = 0x0 | V4L2_CAP_VIDEO_CAPTURE;
    camera_handle = new AbstractCamera;
    fprintf(stdout, "%s set V4L2_CAP_VIDEO_CAPTURE\n", m_camera.dev_name);
  } else {
    fprintf(stdout, "%s don't support CAPTURE\n", m_camera.dev_name);
    return false;
  }
  if ((cap.capabilities & V4L2_CAP_STREAMING)) {
    fprintf(stdout, "%s support V4L2_CAP_STREAMING\n", m_camera.dev_name);
  } else {
    fprintf(stdout, "%s don't support STREAMING I/O\n", m_camera.dev_name);
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
    fprintf(stderr, "Cannot open '%s': %d\n", dev_name, errno);
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
  struct pollfd Fds[1];
  Fds[0].fd = m_camera.fd;
  Fds[0].events = POLLIN;

  frameLoop.store(true);
  qDebug() << "frame_length: " << m_camera.frame_length;
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
      fprintf(stderr, "poll I/O timeout\n");
      fprintf(stderr, "%s reset again\n", m_camera.dev_name);
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
        continue;
      } else {
        fprintf(stderr, "%s reset again err\n", m_camera.dev_name);
        goto streamoff_handle;
      }
    } else if (ret < 0) {
      fprintf(stderr, "poll I/O err: %d\n", errno);
      goto streamoff_handle;
    }

    ret = camera_handle->framebuffer_handle(m_camera, buf, onebuf);
    if (ret < 0) {
      fprintf(stderr, "camera handle failed \n");
      goto streamoff_handle;
    }

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
  }
  qDebug() << "camera loop end";
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
  int i;
  unsigned char *y0 = yuv + 0;
  unsigned char *u0 = yuv + 1;
  unsigned char *y1 = yuv + 2;
  unsigned char *v0 = yuv + 3;

  unsigned char *r0 = rgb + 0;
  unsigned char *g0 = rgb + 1;
  unsigned char *b0 = rgb + 2;
  unsigned char *r1 = rgb + 3;
  unsigned char *g1 = rgb + 4;
  unsigned char *b1 = rgb + 5;

  float rt0 = 0, gt0 = 0, bt0 = 0, rt1 = 0, gt1 = 0, bt1 = 0;

  for (i = 0; i <= (m_camera.width * m_camera.height) / 2; i++) {
    bt0 = 1.164 * (*y0 - 16) + 2.018 * (*u0 - 128);
    gt0 = 1.164 * (*y0 - 16) - 0.813 * (*v0 - 128) - 0.394 * (*u0 - 128);
    rt0 = 1.164 * (*y0 - 16) + 1.596 * (*v0 - 128);

    bt1 = 1.164 * (*y1 - 16) + 2.018 * (*u0 - 128);
    gt1 = 1.164 * (*y1 - 16) - 0.813 * (*v0 - 128) - 0.394 * (*u0 - 128);
    rt1 = 1.164 * (*y1 - 16) + 1.596 * (*v0 - 128);

    if (rt0 > 255)
      rt0 = 255;
    if (rt0 < 0)
      rt0 = 0;

    if (gt0 > 255)
      gt0 = 255;
    if (gt0 < 0)
      gt0 = 0;

    if (bt0 > 255)
      bt0 = 255;
    if (bt0 < 0)
      bt0 = 0;

    if (rt1 > 255)
      rt1 = 255;
    if (rt1 < 0)
      rt1 = 0;

    if (gt1 > 255)
      gt1 = 255;
    if (gt1 < 0)
      gt1 = 0;

    if (bt1 > 255)
      bt1 = 255;
    if (bt1 < 0)
      bt1 = 0;

    *r0 = (unsigned char)rt0;
    *g0 = (unsigned char)gt0;
    *b0 = (unsigned char)bt0;

    *r1 = (unsigned char)rt1;
    *g1 = (unsigned char)gt1;
    *b1 = (unsigned char)bt1;

    yuv = yuv + 4;
    rgb = rgb + 6;
    if (yuv == nullptr)
      break;

    y0 = yuv;
    u0 = yuv + 1;
    y1 = yuv + 2;
    v0 = yuv + 3;

    r0 = rgb + 0;
    g0 = rgb + 1;
    b0 = rgb + 2;
    r1 = rgb + 3;
    g1 = rgb + 4;
    b1 = rgb + 5;
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
