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
    unsigned char *p;

    CLEAR(fmtDesc);
    fmtDesc.index = 0;
    fmtDesc.type = V4L2_BUF_TYPE_VIDEO_CAPTURE_MPLANE;
    //获取摄像头支持的编码格式
    qCDebug(camLog, "CAM: %s supported pixelformat:", in_camera.dev_name);
    pixformat_l.clear();
    while (xioctl(in_camera.fd, VIDIOC_ENUM_FMT, &fmtDesc) == 0){
        fmtDesc.index++;
        p = (unsigned char *)&fmtDesc.pixelformat;
        qCDebug(camLog, "CAM:   %c%c%c%c", p[0], p[1], p[2], p[3]);
        // printf("pixelformat=%c%c%c%c\n\n",p[0],p[1],p[2],p[3]);
        if(fmtDesc.pixelformat == v4l2_fourcc_i('N', 'V', '1', '2')) {
            pixformat_l.append("NV12");
            continue;
        }
        else if(fmtDesc.pixelformat == v4l2_fourcc_i('Y', 'U', 'Y', 'V')) {
            pixformat_l.append("YUYV");
            continue;
        }
        else if(fmtDesc.pixelformat == v4l2_fourcc_i('R', 'G', 'B', '3')) {
            pixformat_l.append("RGB3");
            continue;
        }
    }
    CLEAR(fmt);

    fmt.type = V4L2_BUF_TYPE_VIDEO_CAPTURE_MPLANE;
    in_camera.type = V4L2_BUF_TYPE_VIDEO_CAPTURE_MPLANE;
    if (-1  == xioctl(in_camera.fd, VIDIOC_G_FMT, &fmt)) {
        qCCritical(camLog, "CAM: G_FMT failed");
        return -1;
    }

    // 像素格式优先级选择 — ISI SOURCE pad 输出 RGB888_1X24
    // RGB3: 零 CPU 转换，DQBUF 直接就是 RGB 数据
    // YUYV: ISI 回退到 YUV8_1X24 时使用，整数转换
    // NV12: 半平面格式，转换最慢
    if(pixformat_l.contains(QString("RGB3")))
        in_camera.pixelformat = V4L2_PIX_FMT_RGB24;
    else if(pixformat_l.contains(QString("YUYV")))
        in_camera.pixelformat = V4L2_PIX_FMT_YUYV;
    else if(pixformat_l.contains(QString("NV12")))
        in_camera.pixelformat = V4L2_PIX_FMT_NV12;
    else return -1;

    // ★ 清除 G_FMT 残留的 plane_fmt，避免驱动使用旧缓冲区尺寸
    CLEAR(fmt);
    fmt.type = V4L2_BUF_TYPE_VIDEO_CAPTURE_MPLANE;
    fmt.fmt.pix_mp.width = in_camera.width;
    fmt.fmt.pix_mp.height = in_camera.height;
    fmt.fmt.pix_mp.pixelformat = in_camera.pixelformat;
    fmt.fmt.pix_mp.num_planes = 1;
    fmt.fmt.pix_mp.field = V4L2_FIELD_NONE;
    // colorspace 由驱动根据 ISI SOURCE pad 输出格式自动确定
    // RGB888_1X24 → SRGB, YUV8_1X24 → JPEG/Rec.601

    if (-1 == xioctl(in_camera.fd, VIDIOC_S_FMT, &fmt)) {
        qCCritical(camLog, "CAM: S_FMT failed: %d", errno);
        return -1;
    }
    //获取驱动实际设置的参数
    in_camera.NUM_PLANES = fmt.fmt.pix_mp.num_planes;
    in_camera.pixelformat = fmt.fmt.pix_mp.pixelformat;
    in_camera.width = fmt.fmt.pix_mp.width;
    in_camera.height = fmt.fmt.pix_mp.height;
    p = (unsigned char *)&in_camera.pixelformat;
    qCInfo(camLog, "CAM: %s → %c%c%c%c", in_camera.dev_name, p[0], p[1], p[2], p[3]);

    qCDebug(camLog, "CAM: MPL S_FMT result: %dx%d planes=%d sizeimg=%u bpl=%u csc=%d/%d/%d/%d fl=0x%x",
            in_camera.width, in_camera.height,
            in_camera.NUM_PLANES,
            fmt.fmt.pix_mp.plane_fmt[0].sizeimage,
            fmt.fmt.pix_mp.plane_fmt[0].bytesperline,
            fmt.fmt.pix_mp.colorspace, fmt.fmt.pix_mp.ycbcr_enc,
            fmt.fmt.pix_mp.quantization, fmt.fmt.pix_mp.xfer_func,
            fmt.fmt.pix_mp.flags);

    if(init_mmap(in_camera) == -1)
        return -1;
    return 0;
}

void MultiCamera::exit_device(camera_info& in_camera)
{
    int i, j;
    for (i = 0; i < FRAMEBUFFER_COUNT; ++i){
        for (j = 0; j < in_camera.NUM_PLANES; j++){
            if(in_camera.caputure_type.multi_plane[i].start != nullptr) {
                if(MAP_FAILED != in_camera.caputure_type.multi_plane[i].start[j]){
                    munmap(in_camera.caputure_type.multi_plane[i].start[j], in_camera.caputure_type.multi_plane[i].length[j]);
                    in_camera.caputure_type.multi_plane[i].start[j] = MAP_FAILED;
                }
            }
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

    // MMAP 模式: 必须先 QBUF 再 STREAMON
    // 驱动在 STREAMON 时立即开始 DMA，如果队列为空会丢弃帧导致卡顿
    // libcamera 的 importBuffers→streamOn→QBUF 顺序仅适用于 DMABUF 模式
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
            qCCritical(camLog, "CAM: QBUF failed: %d", errno);
            return -1;
        }
    }

    type = V4L2_BUF_TYPE_VIDEO_CAPTURE_MPLANE;
    qCDebug(camLog, "CAM: MPL STREAMON type=%u fd=%d", type, in_camera.fd);
    if (-1 == xioctl(in_camera.fd, VIDIOC_STREAMON, &type)) {
        qCCritical(camLog, "CAM: STREAMON failed: %d", errno);
        return -1;
    }

    return 0;
}

int MultiCamera::stop_capturing(camera_info& in_camera)
{
    enum v4l2_buf_type type;
    type = V4L2_BUF_TYPE_VIDEO_CAPTURE_MPLANE;
    if (-1 == xioctl(in_camera.fd, VIDIOC_STREAMOFF, &type)) {
        qCWarning(camLog, "CAM: STREAMOFF failed: %d", errno);
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
        qCWarning(camLog, "CAM: DQBUF failed: %d", errno);
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
    if(0 > xioctl(in_camera.fd, VIDIOC_QBUF, &buf)) {
        qCWarning(camLog, "CAM: QBUF re-enqueue failed: %d", errno);
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
        qCCritical(camLog, "CAM: REQBUFS failed: %d", errno);
        return -1;
    }

    if (req.count < 2) {
        qCCritical(camLog, "CAM: insufficient buffer memory on %s", in_camera.dev_name);
        return -1;
    }

    qCInfo(camLog, "CAM: REQBUFS success (%d buffers)", FRAMEBUFFER_COUNT);

    in_camera.frame_length = 0;
    for (n_buffers = 0; n_buffers < FRAMEBUFFER_COUNT; ++n_buffers) {
        struct v4l2_buffer buf;
        struct v4l2_plane mplanes[in_camera.NUM_PLANES];
        in_camera.caputure_type.multi_plane[n_buffers].length = nullptr;
        in_camera.caputure_type.multi_plane[n_buffers].start = nullptr;

        // 分配内存并检查
        size_t* len_ptr = (size_t*)calloc(in_camera.NUM_PLANES, sizeof(size_t));
        if(len_ptr == nullptr) {
            qCCritical(camLog, "CAM: calloc length failed");
            goto cleanup_and_exit;
        }
        in_camera.caputure_type.multi_plane[n_buffers].length = len_ptr;

        void** start_ptr = (void **)calloc(in_camera.NUM_PLANES, sizeof(void *));
        if(start_ptr == nullptr) {
            qCCritical(camLog, "CAM: calloc start failed");
            free(len_ptr);
            in_camera.caputure_type.multi_plane[n_buffers].length = nullptr;
            goto cleanup_and_exit;
        }
        in_camera.caputure_type.multi_plane[n_buffers].start = start_ptr;

        CLEAR(buf);

        buf.type        = V4L2_BUF_TYPE_VIDEO_CAPTURE_MPLANE;
        buf.memory      = V4L2_MEMORY_MMAP;
        buf.index       = n_buffers;
        buf.m.planes	= mplanes;
        buf.length	= in_camera.NUM_PLANES;

        if (-1 == xioctl(in_camera.fd, VIDIOC_QUERYBUF, &buf)) {
            qCCritical(camLog, "CAM: QUERYBUF failed: %d", errno);
            goto cleanup_and_exit;
        }
        //每一个buffer的多个平面地址映射
        for(int j=0; j<in_camera.NUM_PLANES; j++) {
            in_camera.caputure_type.multi_plane[n_buffers].length[j] = buf.m.planes[j].length;
            in_camera.frame_length += buf.m.planes[j].length;
            in_camera.caputure_type.multi_plane[n_buffers].start[j] = MAP_FAILED;
            in_camera.caputure_type.multi_plane[n_buffers].start[j] = mmap(nullptr, buf.m.planes[j].length,
                                                                          PROT_READ | PROT_WRITE, /* recommended */
                                                                          MAP_SHARED,             /* recommended */
                                                                          in_camera.fd, buf.m.planes[j].m.mem_offset);
            if (MAP_FAILED == in_camera.caputure_type.multi_plane[n_buffers].start[j]) {
                qCCritical(camLog, "CAM: mmap failed: %d", errno);
                // 清理当前 buffer 已映射的部分
                for(int k=0; k<j; k++) {
                    if(in_camera.caputure_type.multi_plane[n_buffers].start[k] != MAP_FAILED) {
                        munmap(in_camera.caputure_type.multi_plane[n_buffers].start[k],
                               in_camera.caputure_type.multi_plane[n_buffers].length[k]);
                    }
                }
                in_camera.frame_length = 0;
                goto cleanup_and_exit;
            }
        }
    }
    //获取需要创建数组的长度
    in_camera.frame_length /= FRAMEBUFFER_COUNT;
    return 0;

cleanup_and_exit:
    // 清理所有已分配的内存
    for(int i = 0; i < n_buffers; i++) {
        for(int j = 0; j < in_camera.NUM_PLANES; j++) {
            if(in_camera.caputure_type.multi_plane[i].start != nullptr &&
               in_camera.caputure_type.multi_plane[i].start[j] != MAP_FAILED) {
                munmap(in_camera.caputure_type.multi_plane[i].start[j],
                       in_camera.caputure_type.multi_plane[i].length[j]);
            }
        }
        if(in_camera.caputure_type.multi_plane[i].length != nullptr) {
            free(in_camera.caputure_type.multi_plane[i].length);
            in_camera.caputure_type.multi_plane[i].length = nullptr;
        }
        if(in_camera.caputure_type.multi_plane[i].start != nullptr) {
            free(in_camera.caputure_type.multi_plane[i].start);
            in_camera.caputure_type.multi_plane[i].start = nullptr;
        }
    }
    // 清理当前 buffer 的部分分配
    if(in_camera.caputure_type.multi_plane[n_buffers].length != nullptr) {
        free(in_camera.caputure_type.multi_plane[n_buffers].length);
        in_camera.caputure_type.multi_plane[n_buffers].length = nullptr;
    }
    if(in_camera.caputure_type.multi_plane[n_buffers].start != nullptr) {
        free(in_camera.caputure_type.multi_plane[n_buffers].start);
        in_camera.caputure_type.multi_plane[n_buffers].start = nullptr;
    }
    return -1;
}
