#include "camera_qthread.h"

Camera_qthread* Camera_qthread::CameraHandleSingle = nullptr;
pthread_mutex_t Camera_qthread::camera_mutex = PTHREAD_MUTEX_INITIALIZER;
AbstractCamera* Camera_qthread::camera_handle = nullptr;
Camera_qthread::Camera_qthread() {CLEAR(m_camera);}

//打开摄像头节点，默认640x480
bool Camera_qthread::set_device(QString device, int in_width, int in_height)
{
    int ret;
    bool boolvalue;
    strncpy(m_camera.dev_name,device.toUtf8().data(),strlen(device.toUtf8().data())+1);
    ret = open_device(m_camera.dev_name);
    if(ret < 0)
        return false;
    boolvalue = isMultiCamera(ret);
    if(!boolvalue){
        close(m_camera.fd);
        return false;
    }
    m_camera.fd = ret;
    m_camera.width = in_width;
    m_camera.height = in_height;
    return true;
}
//判断摄像头能力，主要区分 V4L2_CAP_VIDEO_CAPTURE_MPLANE | V4L2_CAP_VIDEO_CAPTURE
bool Camera_qthread::isMultiCamera(int fd)
{
    struct v4l2_capability cap;
    CLEAR(cap);
    if (-1 == xioctl(fd, VIDIOC_QUERYCAP, &cap)) {
        fprintf(stderr, "VIDIOC_QUERYCAP: error - %d\n", errno);
        return false;
    }
    if((cap.capabilities & V4L2_CAP_VIDEO_CAPTURE_MPLANE)){
        m_camera.capabilities = 0x0 | V4L2_CAP_VIDEO_CAPTURE_MPLANE;
        camera_handle = new MultiCamera;
        fprintf(stdout, "%s set V4L2_CAP_VIDEO_CAPTURE_MPLANE\n",m_camera.dev_name);
    }else if((cap.capabilities & V4L2_CAP_VIDEO_CAPTURE)){
        m_camera.capabilities = 0x0 | V4L2_CAP_VIDEO_CAPTURE;
        camera_handle = new AbstractCamera;
        fprintf(stdout, "%s set V4L2_CAP_VIDEO_CAPTURE\n",m_camera.dev_name);
    }else{
        fprintf(stdout, "%s don't support CAPTURE\n",m_camera.dev_name);
        return false;
    }
    if((cap.capabilities & V4L2_CAP_STREAMING)) {
        fprintf(stdout, "%s support V4L2_CAP_STREAMING\n",m_camera.dev_name);
    }else{
        fprintf(stdout, "%s don't support STREAMING I/O\n",m_camera.dev_name);
        delete camera_handle;
        camera_handle = nullptr;
        return false;
    }
    return true;
}
//停止摄像头循环取帧并释放资源
void Camera_qthread::exit_camera()
{
    if(camera_handle == nullptr)
        return ;
    frameLoop.store(false);
    wait();
    camera_handle->stop_capturing(m_camera);
    camera_handle->exit_device(m_camera);
    delete camera_handle;
    camera_handle = nullptr;
}

int Camera_qthread::open_device(char* dev_name)
{
    int ret;
    ret = open(dev_name, O_RDWR /* required *//* | O_NONBLOCK*/, 0);

    if (ret == -1) {
        fprintf(stderr, "Cannot open '%s': %d\n", dev_name, errno);
        return -1;
    }
    return ret;
}

Camera_qthread* Camera_qthread::getInstance()
{
    if(CameraHandleSingle != nullptr)
        return CameraHandleSingle;
    pthread_mutex_lock(&camera_mutex);
    if(CameraHandleSingle == nullptr){
        CameraHandleSingle = new Camera_qthread;
    }
    pthread_mutex_unlock(&camera_mutex);
    return CameraHandleSingle;
}
//摄像头取帧函数
void Camera_qthread::run()
{
    struct v4l2_buffer buf;
    int ret;
    QImage img;
    struct pollfd Fds[1];
    Fds[0].fd     = m_camera.fd;
    Fds[0].events = POLLIN;
    //初始化摄像头、申请buffer并映射
    ret = camera_handle->init_device(m_camera);
    if(ret < 0){
        goto err_handle;
    }
    //开启摄像头流
    ret = camera_handle->start_capturing(m_camera);
    if(ret < 0){
        goto err_handle;
    }
    frameLoop.store(true);  //原子变量控制摄像头是否循环取帧
    qDebug() << "frame_length: " << m_camera.frame_length;

    while(frameLoop.load()){
        ret = poll(Fds, 1, 5000);  //监听摄像头数据
        if(ret == 0){
            fprintf(stderr, "poll I/O timeout\n");
            goto streamoff_handle;
        }else if(ret < 0){
            fprintf(stderr, "poll I/O err: %d\n", errno);
            goto streamoff_handle;
        }
        unsigned char onebuf[m_camera.frame_length];
        ret = camera_handle->framebuffer_handle(m_camera, buf, onebuf);
        if(ret < 0){
            fprintf(stderr, "camera handle failed \n");
            goto streamoff_handle;
        }//如果是yuyv编码格式需要转换成rgb3
        if(m_camera.pixelformat == v4l2_fourcc_i('Y', 'U', 'Y', 'V')){
            unsigned char onebuf1[m_camera.width*m_camera.height*3];
            yuv_to_rgb(onebuf, onebuf1);
            img = QImage(onebuf1,m_camera.width,m_camera.height,QImage::Format_RGB888);
        }else if(m_camera.pixelformat == v4l2_fourcc_i('R', 'G', 'B', '3'))
            img = QImage(onebuf,m_camera.width,m_camera.height,QImage::Format_RGB888);
        else if(m_camera.pixelformat == v4l2_fourcc_i('M', 'J', 'P', 'G'))
            img = QImage::fromData(onebuf, m_camera.frame_length, "JPEG");
        else if(m_camera.pixelformat == v4l2_fourcc_i('R', 'G', 'B', 'R'))
            img = QImage(onebuf,m_camera.width,m_camera.height,QImage::Format_RGB16);
        if(!img.isNull())
            emit sign_img(img);
    }
    qDebug() << "camera loop end";
    return;
streamoff_handle:
    camera_handle->stop_capturing(m_camera);
err_handle:
    camera_handle->exit_device(m_camera);
    delete camera_handle;
    camera_handle = nullptr;
    return;
}

int Camera_qthread::xioctl(int fh, int request, void *arg)
{
    int r;
    do {
        r = ioctl(fh, request, arg);
    } while (-1 == r && EINTR == errno);

    return r;
}

void Camera_qthread::yuv_to_rgb(unsigned char *yuv, unsigned char *rgb){
    unsigned int i;
    unsigned char* y0 = yuv + 0;
    unsigned char* u0 = yuv + 1;
    unsigned char* y1 = yuv + 2;
    unsigned char* v0 = yuv + 3;

    unsigned  char* r0 = rgb + 0;
    unsigned  char* g0 = rgb + 1;
    unsigned  char* b0 = rgb + 2;
    unsigned  char* r1 = rgb + 3;
    unsigned  char* g1 = rgb + 4;
    unsigned  char* b1 = rgb + 5;

    float rt0 = 0, gt0 = 0, bt0 = 0, rt1 = 0, gt1 = 0, bt1 = 0;

    for(i = 0; i <= ( m_camera.width* m_camera.height) / 2 ;i++)
    {
        bt0 = 1.164 * (*y0 - 16) + 2.018 * (*u0 - 128);
        gt0 = 1.164 * (*y0 - 16) - 0.813 * (*v0 - 128) - 0.394 * (*u0 - 128);
        rt0 = 1.164 * (*y0 - 16) + 1.596 * (*v0 - 128);

        bt1 = 1.164 * (*y1 - 16) + 2.018 * (*u0 - 128);
        gt1 = 1.164 * (*y1 - 16) - 0.813 * (*v0 - 128) - 0.394 * (*u0 - 128);
        rt1 = 1.164 * (*y1 - 16) + 1.596 * (*v0 - 128);


        if(rt0 > 250)      rt0 = 255;
        if(rt0< 0)        rt0 = 0;

        if(gt0 > 250)     gt0 = 255;
        if(gt0 < 0)    gt0 = 0;

        if(bt0 > 250)    bt0 = 255;
        if(bt0 < 0)    bt0 = 0;

        if(rt1 > 250)    rt1 = 255;
        if(rt1 < 0)    rt1 = 0;

        if(gt1 > 250)    gt1 = 255;
        if(gt1 < 0)    gt1 = 0;

        if(bt1 > 250)    bt1 = 255;
        if(bt1 < 0)    bt1 = 0;

        *r0 = (unsigned char)rt0;
        *g0 = (unsigned char)gt0;
        *b0 = (unsigned char)bt0;

        *r1 = (unsigned char)rt1;
        *g1 = (unsigned char)gt1;
        *b1 = (unsigned char)bt1;

        yuv = yuv + 4;
        rgb = rgb + 6;
        if(yuv == NULL)
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

Camera_qthread::Autorealse::~Autorealse()
{
    pthread_mutex_lock(&camera_mutex);
    if(camera_handle != nullptr)
        delete camera_handle;
    if(CameraHandleSingle != nullptr)
        delete CameraHandleSingle;
    pthread_mutex_unlock(&camera_mutex);
}
