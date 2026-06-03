#include "abstractcamera.h"


AbstractCamera::AbstractCamera()
{

}

AbstractCamera::~AbstractCamera()
{

}

int AbstractCamera::init_device(camera_info& in_camera)
{
    struct v4l2_format fmt;
    struct v4l2_fmtdesc fmtDesc;
    unsigned char *p;

    CLEAR(fmtDesc);
    fmtDesc.index = 0;
    fmtDesc.type = V4L2_CAP_VIDEO_CAPTURE;
    pixformat_l.clear();
    qDebug() << in_camera.dev_name << " supported pixelformat:";
    while (ioctl(in_camera.fd, VIDIOC_ENUM_FMT, &fmtDesc) == 0) {
        fmtDesc.index++;
        p = (unsigned char *)&fmtDesc.pixelformat;
        qDebug() << QString("%1%2%3%4").arg(QChar(p[0])).arg(QChar(p[1])).arg(QChar(p[2])).arg(QChar(p[3]));
        // printf("pixelformat=%c%c%c%c\n\n",p[0],p[1],p[2],p[3]);
        if(fmtDesc.pixelformat == v4l2_fourcc_i('M', 'J', 'P', 'G')) {
            pixformat_l.append("MJPG");
            continue;
        }
        else if(fmtDesc.pixelformat == v4l2_fourcc_i('R', 'G', 'B', 'R')) {
            pixformat_l.append("RGBR");
            continue;
        }
        else if(fmtDesc.pixelformat == v4l2_fourcc_i('Y', 'U', 'Y', 'V')) {
            pixformat_l.append("YUYV");
            continue;
        }
    }

    CLEAR(fmt);
    fmt.type = V4L2_BUF_TYPE_VIDEO_CAPTURE;
    in_camera.type = V4L2_BUF_TYPE_VIDEO_CAPTURE;
    if (-1  == ioctl(in_camera.fd, VIDIOC_G_FMT, &fmt)) {
        fprintf(stderr, "get format failed : %d\n", errno);
        return -1;
    }

    // 像素格式优先级选择
    if(pixformat_l.contains(QString("MJPG")))
        in_camera.pixelformat = V4L2_PIX_FMT_MJPEG;
    else if(pixformat_l.contains(QString("RGBR")))
        in_camera.pixelformat = V4L2_PIX_FMT_RGB565X;
    else if(pixformat_l.contains(QString("YUYV")))
        in_camera.pixelformat = V4L2_PIX_FMT_YUYV;
    else return -1;

    fmt.type = V4L2_BUF_TYPE_VIDEO_CAPTURE;
    fmt.fmt.pix.width = in_camera.width;
    fmt.fmt.pix.height = in_camera.height;
    fmt.fmt.pix.pixelformat = in_camera.pixelformat;
    // fmt.fmt.pix.pixelformat = V4L2_PIX_FMT_YUYV;
    // fmt.fmt.pix.pixelformat = V4L2_PIX_FMT_MJPEG;

    if (ioctl(in_camera.fd, VIDIOC_S_FMT, &fmt) == -1) {
        fprintf(stderr, "set format failed : %d\n",errno);
        return -1;
    }
    in_camera.pixelformat = fmt.fmt.pix.pixelformat;
    p = (unsigned char *)&in_camera.pixelformat;
    qDebug() << in_camera.dev_name << QString("%1%2%3%4").arg(QChar(p[0])).arg(QChar(p[1])).arg(QChar(p[2])).arg(QChar(p[3]));

    // 获取实际的帧宽高度
    struct v4l2_requestbuffers reqbuf;
    CLEAR(reqbuf);
    reqbuf.count = FRAMEBUFFER_COUNT;       //帧缓冲的数量
    reqbuf.type = V4L2_BUF_TYPE_VIDEO_CAPTURE;
    reqbuf.memory = V4L2_MEMORY_MMAP;
    if (0 > ioctl(in_camera.fd, VIDIOC_REQBUFS, &reqbuf)) {
        qDebug("request buffer failed\n");
        return -1;
    }
    qDebug()<<"request buffer success";

    /* 建立内存映射 */
    in_camera.frame_length = 0;
    for(n_buffers = 0; n_buffers < FRAMEBUFFER_COUNT; n_buffers++) {
        struct v4l2_buffer buf;
        CLEAR(buf);
        buf.index = n_buffers;
        buf.type = V4L2_BUF_TYPE_VIDEO_CAPTURE;
        buf.memory = V4L2_MEMORY_MMAP;
        if(0 > ioctl(in_camera.fd, VIDIOC_QUERYBUF, &buf)) {
            fprintf(stderr, "VIDIOC_QUERYBUF failed : %d\n", errno);
            return -1;
        }

        in_camera.caputure_type.simple_plane[n_buffers].length = buf.length;
        in_camera.caputure_type.simple_plane[n_buffers].start = MAP_FAILED;
        in_camera.caputure_type.simple_plane[n_buffers].start = mmap(nullptr, buf.length,
                                                                     PROT_READ | PROT_WRITE,
                                                                     MAP_SHARED, in_camera.fd, buf.m.offset);
        if (MAP_FAILED == in_camera.caputure_type.simple_plane[n_buffers].start) {
            fprintf(stderr, "mmap error : %d\n", errno);
            // 清理前面已映射的 buffer
            for(int k = 0; k < n_buffers; k++) {
                if(in_camera.caputure_type.simple_plane[k].start != MAP_FAILED) {
                    munmap(in_camera.caputure_type.simple_plane[k].start,
                           in_camera.caputure_type.simple_plane[k].length);
                    in_camera.caputure_type.simple_plane[k].start = MAP_FAILED;
                }
            }
            return -1;
        }
    }
    in_camera.frame_length = in_camera.caputure_type.simple_plane[0].length;
    return 0;
}

void AbstractCamera::exit_device(camera_info& in_camera)
{
    int i;
    for (i = 0; i < FRAMEBUFFER_COUNT; ++i){
        if(in_camera.caputure_type.simple_plane[i].start != MAP_FAILED){
            munmap(in_camera.caputure_type.simple_plane[i].start, in_camera.caputure_type.simple_plane[i].length);
            in_camera.caputure_type.simple_plane[i].start = MAP_FAILED;
        }
    }
    close(in_camera.fd);
}

int AbstractCamera::start_capturing(camera_info& in_camera)
{
    unsigned int i;
    enum v4l2_buf_type type;

    /* 入队 */
    for(i = 0;i < FRAMEBUFFER_COUNT;i++){
        struct v4l2_buffer buf;
        CLEAR(buf);
        buf.type = V4L2_BUF_TYPE_VIDEO_CAPTURE;
        buf.memory = V4L2_MEMORY_MMAP;
        buf.index = i;
        if (0 > ioctl(in_camera.fd, VIDIOC_QBUF, &buf)) {
            fprintf(stderr, "VIDIOC_QBUF error: %d\n", errno);
            return -1;
        }
    }
    /* 开启视频流 */
    type = V4L2_BUF_TYPE_VIDEO_CAPTURE;
    if (0 > ioctl(in_camera.fd, VIDIOC_STREAMON, &type)) {
        fprintf(stderr, "VIDIOC_STREAMON error: %d\n", errno);
        return -1;
    }
    return 0;
}

int AbstractCamera::stop_capturing(camera_info& in_camera)
{
    enum v4l2_buf_type type;
    type = V4L2_BUF_TYPE_VIDEO_CAPTURE;
    if (-1 == xioctl(in_camera.fd, VIDIOC_STREAMOFF, &type)) {
        fprintf(stderr, "VIDIOC_STREAMOFF: error - %d\n", errno);
        return -1;
    }
    return 0;
}

int AbstractCamera::framebuffer_handle(camera_info &in_camera, v4l2_buffer &buf, unsigned char *framebuf)
{
    CLEAR(buf);
    buf.type = V4L2_BUF_TYPE_VIDEO_CAPTURE;
    buf.memory = V4L2_MEMORY_MMAP;
    // 出队
    if(0 > ioctl(in_camera.fd,VIDIOC_DQBUF,&buf)){
        fprintf(stderr, "VIDIOC DQBUF failed : %d\n", errno);
        return -1;
    }
    memcpy(framebuf, in_camera.caputure_type.simple_plane[buf.index].start, buf.bytesused);
    if (0 > ioctl(in_camera.fd, VIDIOC_QBUF, &buf)) {
        fprintf(stderr, "VIDIOC QBUF failed : %d\n", errno);
        return -1;
    }
    return 0;
}

int AbstractCamera::xioctl(int fh, int request, void *arg)
{
    int r;
    do {
        r = ioctl(fh, request, arg);
    } while (-1 == r && EINTR == errno);

    return r;
}

