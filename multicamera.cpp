#include "multicamera.h"


MultiCamera::MultiCamera()
{

}

MultiCamera::~MultiCamera()
{

}

int MultiCamera::init_device(camera_info& in_camera)
{
    struct v4l2_format fmt;
    struct v4l2_fmtdesc fmtDesc;

    CLEAR(fmtDesc);
    fmtDesc.index = 0;
    fmtDesc.type = V4L2_BUF_TYPE_VIDEO_CAPTURE_MPLANE;
    //获取摄像头支持的编码格式
    qDebug() << in_camera.dev_name << " supported pixelformat:";
    while (xioctl(in_camera.fd, VIDIOC_ENUM_FMT, &fmtDesc) == 0){
        printf("discription=%s\n",fmtDesc.description);
        unsigned char *p = (unsigned char *)&fmtDesc.pixelformat;
        printf("pixelformat=%c%c%c%c\n\n",p[0],p[1],p[2],p[3]);
        fmtDesc.index++;
    }
    CLEAR(fmt);

    fmt.type = V4L2_BUF_TYPE_VIDEO_CAPTURE_MPLANE;
    in_camera.type = V4L2_BUF_TYPE_VIDEO_CAPTURE_MPLANE;
    if (-1  == xioctl(in_camera.fd, VIDIOC_G_FMT, &fmt)) {
        fprintf(stderr,"get format failed\n");
        return -1;
    }

    fmt.type = V4L2_BUF_TYPE_VIDEO_CAPTURE_MPLANE;
    fmt.fmt.pix_mp.width = in_camera.width; //replace
    fmt.fmt.pix_mp.height = in_camera.height; //replace
    fmt.fmt.pix_mp.pixelformat = V4L2_PIX_FMT_RGB24; //replace
    // fmt.fmt.pix.pixelformat = V4L2_PIX_FMT_YUYV;
    // fmt.fmt.pix_mp.colorspace = V4L2_COLORSPACE_SRGB;
    fmt.fmt.pix_mp.field       = V4L2_FIELD_ANY;


    if (-1 == xioctl(in_camera.fd, VIDIOC_S_FMT, &fmt)) {
        fprintf(stderr, "VIDIOC_S_FMT: error: %d\n", errno);
        return -1;
    }
    //获取多平面个数和设置的编码格式
    in_camera.NUM_PLANES = fmt.fmt.pix_mp.num_planes;
    in_camera.pixelformat = fmt.fmt.pix.pixelformat;
    qDebug() << in_camera.dev_name << " set pixelformat: RGB3";
    qDebug()<<"camera NUM_PLANES:"<<in_camera.NUM_PLANES;
    if(init_mmap(in_camera) == -1)
        return -1;
    return 0;
}

void MultiCamera::exit_device(camera_info& in_camera)
{
    int i, j;
    for (i = 0; i < FRAMEBUFFER_COUNT; ++i){
        for (j = 0; j < in_camera.NUM_PLANES; j++){
            if(MAP_FAILED != in_camera.caputure_type.multi_plane[i].start[j])
                munmap(in_camera.caputure_type.multi_plane[i].start[j], in_camera.caputure_type.multi_plane[i].length[j]);
        }
        if(in_camera.caputure_type.multi_plane[i].length != nullptr){
            free(in_camera.caputure_type.multi_plane[i].length);
            in_camera.caputure_type.multi_plane[i].length = nullptr;
        }
        if(in_camera.caputure_type.multi_plane[i].start != nullptr){
            free(in_camera.caputure_type.multi_plane[i].start);
            in_camera.caputure_type.multi_plane[i].start = nullptr;
        }
    }
    close(in_camera.fd);
}

int MultiCamera::start_capturing(camera_info& in_camera)
{
    unsigned int i;
    enum v4l2_buf_type type;

    for (i = 0; i < FRAMEBUFFER_COUNT; ++i) {
        struct v4l2_buffer buf;
        struct v4l2_plane mplanes[in_camera.NUM_PLANES];

        CLEAR(buf);
        buf.type = V4L2_BUF_TYPE_VIDEO_CAPTURE_MPLANE;
        buf.memory = V4L2_MEMORY_MMAP;
        buf.index = i;
        buf.m.planes	= mplanes;
        buf.length	= in_camera.NUM_PLANES;

        if (-1 == xioctl(in_camera.fd, VIDIOC_QBUF, &buf)) {
            fprintf(stderr, "VIDIOC_QBUF error: %d\n", errno);
            return -1;
        }
    }

    type = V4L2_BUF_TYPE_VIDEO_CAPTURE_MPLANE;
    if (-1 == xioctl(in_camera.fd, VIDIOC_STREAMON, &type)) {
        fprintf(stderr, "VIDIOC_STREAMON error: %d\n", errno);
        return -1;
    }
    return 0;
}

int MultiCamera::stop_capturing(camera_info& in_camera)
{
    enum v4l2_buf_type type;
    type = V4L2_BUF_TYPE_VIDEO_CAPTURE_MPLANE;
    if (-1 == xioctl(in_camera.fd, VIDIOC_STREAMOFF, &type)) {
        fprintf(stderr, "VIDIOC_STREAMOFF: error - %d\n", errno);
        return -1;
    }
    return 0;
}
//摄像头帧数据获取
int MultiCamera::framebuffer_handle(camera_info &in_camera, v4l2_buffer &buf, unsigned char *framebuf)
{
    struct v4l2_plane mplanes[in_camera.NUM_PLANES];
    CLEAR(buf);
    buf.type = V4L2_BUF_TYPE_VIDEO_CAPTURE_MPLANE;
    buf.memory = V4L2_MEMORY_MMAP;
    buf.m.planes = mplanes;
    buf.length=in_camera.NUM_PLANES;
    /* 出队 */
    if(0 > xioctl(in_camera.fd,VIDIOC_DQBUF,&buf)){
        fprintf(stderr, "VIDIOC DQBUF failed : %d\n", errno);
        return -1;
    }
    //数据处理
    // unsigned char onebuf[in_camera.frame_length];
    size_t offset = 0;
    for(int i = 0; i < in_camera.NUM_PLANES; i++){
        memcpy(framebuf+offset, in_camera.caputure_type.multi_plane[buf.index].start[i], buf.m.planes[i].bytesused);
        offset += buf.m.planes[i].bytesused;
    }
    /* 入队 */
    if(0 > ioctl(in_camera.fd,VIDIOC_QBUF,&buf)){
        fprintf(stderr,"VIDIOC QBUF failed : %d\n", errno);
        return -1;
    }
    return 0;
}
//多个buffer的多平面内存映射
int MultiCamera::init_mmap(camera_info& in_camera)
{
    struct v4l2_requestbuffers req;

    CLEAR(req);

    req.count = FRAMEBUFFER_COUNT;
    req.type = V4L2_BUF_TYPE_VIDEO_CAPTURE_MPLANE;
    req.memory = V4L2_MEMORY_MMAP;

    if (-1 == xioctl(in_camera.fd, VIDIOC_REQBUFS, &req)) {
        fprintf(stderr, "VIDIOC_REQBUFS: error - %d\n", errno);
        return -1;
    }

    if (req.count < 2) {
        fprintf(stderr, "Insufficient buffer memory on %s\n",
                in_camera.dev_name);
        return -1;
    }
    in_camera.frame_length = 0;
    for (n_buffers = 0; n_buffers < FRAMEBUFFER_COUNT; ++n_buffers) {
        struct v4l2_buffer buf;
        struct v4l2_plane mplanes[in_camera.NUM_PLANES];
        in_camera.caputure_type.multi_plane[n_buffers].length = nullptr;
        in_camera.caputure_type.multi_plane[n_buffers].start = nullptr;
        in_camera.caputure_type.multi_plane[n_buffers].length = (size_t*)calloc(in_camera.NUM_PLANES, sizeof(size_t));
        in_camera.caputure_type.multi_plane[n_buffers].start = (void **)calloc(in_camera.NUM_PLANES, sizeof(void *));
        CLEAR(buf);

        buf.type        = V4L2_BUF_TYPE_VIDEO_CAPTURE_MPLANE;
        buf.memory      = V4L2_MEMORY_MMAP;
        buf.index       = n_buffers;
        buf.m.planes	= mplanes;
        buf.length	= in_camera.NUM_PLANES;

        if (-1 == xioctl(in_camera.fd, VIDIOC_QUERYBUF, &buf)) {
            fprintf(stderr, "VIDIOC_QUERYBUF: error - %d\n", errno);
            return -1;
        }
        //每一个buffer的多个平面地址映射
        for(int j=0; j<in_camera.NUM_PLANES; j++) {
            in_camera.caputure_type.multi_plane[n_buffers].length[j] = buf.m.planes[j].length;
            in_camera.frame_length += buf.m.planes[j].length;
            in_camera.caputure_type.multi_plane[n_buffers].start[j] = MAP_FAILED;
            in_camera.caputure_type.multi_plane[n_buffers].start[j] = mmap(NULL, buf.m.planes[j].length,
                                                                          PROT_READ | PROT_WRITE, /* recommended */
                                                                          MAP_SHARED,             /* recommended */
                                                                          in_camera.fd, buf.m.planes[j].m.mem_offset);
            if (MAP_FAILED == in_camera.caputure_type.multi_plane[n_buffers].start[j]) {
                fprintf(stderr, "mmap: error - %d\n", errno);
                in_camera.frame_length = 0;
                return -1;
            }
        }
    }
    //获取需要创建数组的长度
    in_camera.frame_length /= FRAMEBUFFER_COUNT;
    return 0;
}
