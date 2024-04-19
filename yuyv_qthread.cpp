/***********************************************************************
 *  This file is part of MXAPP2

    Copyright (C) 2020-2024

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.

    Additional permission under GNU Lesser General Public License version 3.0
    See <https://www.gnu.org/licenses/lgpl-3.0.html> for more details.
***********************************************************************/

#include "yuyv_qthread.h"
#include <unistd.h>

YUYVQThread::YUYVQThread(QWidget *parent):QThread(parent){
    show_flag = false;
}

int YUYVQThread::xioctl(int fh, int request, void *arg)
{
    int r;
    int i = 0;
    do {
        r = ioctl(fh, request, arg);
    } while (-1 == r && EINTR == errno);

    return r;
}

void YUYVQThread::process_image(const void *p, int size)
{
    char filename[15];
    frame_number++;
    sprintf(filename, "frame-%d.raw", frame_number);
    FILE *fp=fopen(filename,"wb");

    fwrite(p, size, 1, fp);

    fflush(fp);
    fclose(fp);
}

int YUYVQThread::read_frame(void)
{
    struct v4l2_buffer buf;
    struct v4l2_plane mplanes[1];
    unsigned int i;

    CLEAR(buf);

    buf.type = V4L2_BUF_TYPE_VIDEO_CAPTURE_MPLANE;
    buf.memory = VB2_MEMORY_MMAP;
    buf.m.planes    = mplanes;
    buf.length      = NUM_PLANES;

    if (-1 == xioctl(fd, VIDIOC_DQBUF, &buf)) {
        switch (errno) {
        case EAGAIN:
            return 0;
        default:
            fprintf(stderr, "VIDIOC_DQBUF: error - %d\n", errno);
        }
    }

    assert(buf.index < n_buffers);
    printf("plane bytesused: %u\n", buf.m.planes->bytesused);
    process_image(csi_buffers[buf.index].start[0], buf.m.planes->bytesused);

    if (-1 == xioctl(fd, VIDIOC_QBUF, &buf)) {
        fprintf(stderr, "VIDIOC_QBUF error: %d\n", errno);
    }

    return 1;
}

void YUYVQThread::stop_capturing( int m_type)
{
    if(m_type == 0){
        enum v4l2_buf_type type;
        type = V4L2_BUF_TYPE_VIDEO_CAPTURE_MPLANE;
        if (-1 == xioctl(fd, VIDIOC_STREAMOFF, &type)) {
            fprintf(stderr, "VIDIOC_STREAMOFF: error - %d\n", errno);
        }
    }
    else if(m_type == 1){
        enum v4l2_buf_type type;
        type = V4L2_BUF_TYPE_VIDEO_CAPTURE;
        if (-1 == xioctl(fd, VIDIOC_STREAMOFF, &type)) {
            fprintf(stderr, "VIDIOC_STREAMOFF: error - %d\n", errno);
        }
    }
}

int YUYVQThread::mainloop(void)
{
    unsigned int count;

    count = frame_count;
    fd_set fds;
    struct timeval tv;
    int r;

    FD_ZERO(&fds);
    FD_SET(fd, &fds);

    /* Timeout. */
    tv.tv_sec = 5;
    tv.tv_usec = 0;

    r = select(fd + 1, &fds, NULL, NULL, &tv);

    if (-1 == r) {
        if (EINTR == errno)
            fprintf(stderr, "select error\n");
    }

    if (0 == r) {
        fprintf(stderr, "select timeout\n");
    }
    return r;
}

int YUYVQThread::start_capturing( int m_type)
{
    unsigned int i;
    enum v4l2_buf_type type;

    if(m_type == 0){
        for (i = 0; i < n_buffers; ++i) {
            struct v4l2_buffer buf;
            struct v4l2_plane mplanes[1];

            CLEAR(buf);
            buf.type = V4L2_BUF_TYPE_VIDEO_CAPTURE_MPLANE;
            buf.memory = VB2_MEMORY_MMAP;
            buf.index = i;
            buf.m.planes	= mplanes;
            buf.length	= NUM_PLANES;

            if (-1 == xioctl(fd, VIDIOC_QBUF, &buf)) {
                fprintf(stderr, "VIDIOC_QBUF error: %d\n", errno);
                return -1;
            }
        }

        type = V4L2_BUF_TYPE_VIDEO_CAPTURE_MPLANE;
        if (-1 == xioctl(fd, VIDIOC_STREAMON, &type)) {
            fprintf(stderr, "VIDIOC_STREAMON error: %d\n", errno);
            return -1;
        }
    }
    else if(m_type == 1){
        /* 入队 */
        for(unsigned int i=0;i<n_buffers;i++){
            struct v4l2_buffer buf;
            CLEAR(buf);
            buf.type = V4L2_BUF_TYPE_VIDEO_CAPTURE;
            buf.memory = V4L2_MEMORY_MMAP;
            buf.index = i;
            if (0 > ioctl(fd, VIDIOC_QBUF, &buf)) {
                qDebug("入队失败\n");
                return -1;
            }
        }

        /* 开启视频流 */
        type = V4L2_BUF_TYPE_VIDEO_CAPTURE;
        if (0 > ioctl(fd, VIDIOC_STREAMON, &type)) {
            qDebug("open stream failed\n");
            return -1;
        }
    }
    return 0;
}

void YUYVQThread::uninit_device(int m_type)
{
    if(m_type == 0){
        unsigned int i, j;
        for (i = 0; i < n_buffers; ++i)
            for (j = 0; j < NUM_PLANES; j++)
                munmap(csi_buffers[i].start[j], csi_buffers[i].length[j]);
        free(csi_buffers);
    }
}

int YUYVQThread::init_mmap(void)
{
    struct v4l2_requestbuffers req;

    CLEAR(req);

    req.count = 4;
    req.type = V4L2_BUF_TYPE_VIDEO_CAPTURE_MPLANE;
    req.memory = VB2_MEMORY_MMAP;

    if (-1 == xioctl(fd, VIDIOC_REQBUFS, &req)) {
        fprintf(stderr, "VIDIOC_REQBUFS: error - %d\n", errno);
        return -1;
    }

    if (req.count < 2) {
        fprintf(stderr, "Insufficient buffer memory on %s\n",
                dev_name);
        return -1;
    }

    csi_buffers = (struct csi_buffer *)calloc(req.count, sizeof(*csi_buffers));

    if (!csi_buffers) {
        fprintf(stderr, "Out of memory\n");
        return -1;
    }

    for (n_buffers = 0; n_buffers < req.count; ++n_buffers) {
        struct v4l2_buffer buf;
        struct v4l2_plane mplanes[NUM_PLANES];

        CLEAR(buf);

        buf.type        = V4L2_BUF_TYPE_VIDEO_CAPTURE_MPLANE;
        buf.memory      = VB2_MEMORY_MMAP;
        buf.index       = n_buffers;
        buf.m.planes	= mplanes;
        buf.length	= NUM_PLANES;

        if (-1 == xioctl(fd, VIDIOC_QUERYBUF, &buf)) {
            fprintf(stderr, "VIDIOC_QUERYBUF: error - %d\n", errno);
            return -1;
        }

        for(int j=0; j<NUM_PLANES; j++) {
            csi_buffers[n_buffers].length[j] = buf.m.planes[j].length;
            csi_buffers[n_buffers].start[j] = mmap(NULL, buf.m.planes[j].length,
                                                   PROT_READ | PROT_WRITE, /* recommended */
                                                   MAP_SHARED,             /* recommended */
                                                   fd, buf.m.planes[j].m.mem_offset);
            if (MAP_FAILED == csi_buffers[n_buffers].start[j]) {
                fprintf(stderr, "mmap: error - %d\n", errno);
                return -1;
            }
        }
    }
    return 0;
}


int YUYVQThread::init_device(int m_type)
{
    struct v4l2_format fmt;
    struct v4l2_capability cap;

    if (-1 == xioctl(fd, VIDIOC_QUERYCAP, &cap)) {
        fprintf(stderr, "VIDIOC_QUERYCAP: error - %d\n", errno);
        return -1;
    }

    if(m_type == 1){
        /* 设置采集格式 */
		qDebug()<<"usb camera";
        if(!(cap.capabilities & V4L2_CAP_VIDEO_CAPTURE)){
            fprintf(stderr, "%s is no video capture device\n",dev_name);
            return -1;
        }

        CLEAR(fmt);
        fmt.type = V4L2_BUF_TYPE_VIDEO_CAPTURE;
        if (-1  == ioctl(fd, VIDIOC_G_FMT, &fmt)) {
            qDebug("get format failed\n");
            return -1;
        }
        qDebug()<<"fmt.type:"<<fmt.type;
        qDebug()<<"fmt.fmt.pix.width:"<<fmt.fmt.pix.width;
        qDebug()<<"fmt.fmt.pix.height:"<<fmt.fmt.pix.height;
        qDebug()<<"fmt.fmt.pix.pixelformat:"<<fmt.fmt.pix.pixelformat;
        qDebug()<<"fmt.fmt.pix.colorspace:"<<fmt.fmt.pix.colorspace;
        qDebug()<<"fmt.fmt.pix.quantization:"<<fmt.fmt.pix.quantization;
        qDebug()<<"fmt.fmt.pix.xfer_func:"<<fmt.fmt.pix.xfer_func;
        qDebug()<<"fmt.fmt.pix.ycbcr_enc:"<<fmt.fmt.pix.ycbcr_enc;
		
        fmt.type = V4L2_BUF_TYPE_VIDEO_CAPTURE;
        fmt.fmt.pix.width  = 640;
        fmt.fmt.pix.height = 480;
        fmt.fmt.pix.pixelformat = V4L2_PIX_FMT_YUYV;   //选择YUYV
		
        if (ioctl(fd, VIDIOC_S_FMT, &fmt) == -1) {
            qDebug("set format failed\n");
            return -1;
        }

        /* 获取实际的帧宽高度 */
        struct v4l2_requestbuffers reqbuf;
        CLEAR(reqbuf);
        reqbuf.count = FRAMEBUFFER_COUNT;       //帧缓冲的数量
        reqbuf.type = V4L2_BUF_TYPE_VIDEO_CAPTURE;
        reqbuf.memory = V4L2_MEMORY_MMAP;
        if (0 > ioctl(fd, VIDIOC_REQBUFS, &reqbuf)) {
            qDebug("request buffer failed\n");
            return -1;
        }

        /* 建立内存映射 */
        for(n_buffers = 0;n_buffers < FRAMEBUFFER_COUNT;n_buffers++){
            struct v4l2_buffer buf;
            CLEAR(buf);
            buf.index = n_buffers;
            buf.type = V4L2_BUF_TYPE_VIDEO_CAPTURE;
            buf.memory = V4L2_MEMORY_MMAP;
            if(0 > ioctl(fd, VIDIOC_QUERYBUF, &buf)){
                qDebug("VIDIOC_QUERYBUF failed\n");
                return -1;
            }

            usb_buffers[n_buffers].length = buf.length;
            usb_buffers[n_buffers].start = mmap(NULL,buf.length,PROT_READ | PROT_WRITE, MAP_SHARED,fd, buf.m.offset);
            if (MAP_FAILED == usb_buffers[n_buffers].start) {
                qDebug("mmap error\n");
                return -1;
            }
        }
    }
    else if(m_type == 0){
        if(!(cap.capabilities & V4L2_CAP_VIDEO_CAPTURE_MPLANE)){
            fprintf(stderr, "%s is no video capture device\n",dev_name);
            return -1;
        }
        if (!(cap.capabilities & V4L2_CAP_STREAMING)) {
            fprintf(stderr, "%s does not support streaming i/o\n",dev_name);
            return -1;
        }

        CLEAR(fmt);

        fmt.type = V4L2_BUF_TYPE_VIDEO_CAPTURE_MPLANE;
        fmt.fmt.pix.width       = img_width; //replace
        fmt.fmt.pix.height      = img_height; //replace
        fmt.fmt.pix.pixelformat = V4L2_PIX_FMT_RGB24; //replace
        //fmt.fmt.pix.colorspace = V4L2_COLORSPACE_SRGB;
        fmt.fmt.pix_mp.width       = img_width; //replace
        fmt.fmt.pix_mp.height      = img_height; //replace
        fmt.fmt.pix_mp.pixelformat = V4L2_PIX_FMT_RGB24; //replace
        fmt.fmt.pix_mp.colorspace = V4L2_COLORSPACE_SRGB;
        //fmt.fmt.pix_mp.pixelformat = V4L2_PIX_FMT_SBGGR10; //replace
        fmt.fmt.pix_mp.field       = V4L2_FIELD_ANY;
        fmt.fmt.pix_mp.num_planes  = 1;
        fmt.fmt.pix_mp.plane_fmt[0].bytesperline  = img_width;
        fmt.fmt.pix_mp.plane_fmt[0].sizeimage  = img_width * img_height;

        if (-1 == xioctl(fd, VIDIOC_S_FMT, &fmt)) {
            fprintf(stderr, "VIDIOC_S_FMT: error: %d\n", errno);
            return -1;
        }

        if(init_mmap() == -1)
            return -1;
    }
    else{
        fprintf(stderr, "else %s is no video capture device\n",dev_name);
        return -1;
    }
    return 0;
}

void YUYVQThread::close_device(void)
{
    if (-1 == close(fd)) {
        fprintf(stderr, "Failed to close device\n");
    }

    fd = -1;
}

int YUYVQThread::open_device(void)
{
    fd = open(dev_name, O_RDWR /* required *//* | O_NONBLOCK*/, 0);

    if (fd == -1) {
        fprintf(stderr, "Cannot open '%s': %d\n", dev_name, errno);
        return -1;
    }
    return 0;
}

void YUYVQThread::run()
{	
    struct v4l2_buffer buf;
    struct v4l2_plane mplanes[1];
    m_type = 0;
    printf("\nvideo node: %s\n", dev_name);
    printf("frame count: %d\n", frame_count);
    printf("frame width: %d\n", img_width);
    printf("frame height: %d\n\n", img_height);

    for(int num = 0;num < 5;num++){
		if(m_type == 1){
			close_device();
			if(open_device() == -1){
				m_type = 0;
				continue;
			}
			if(init_device(m_type) == -1){
				m_type = 0;
				continue;
			}
			if(start_capturing(m_type) == -1){
				m_type = 0;
				continue;
			}
			while(1){
				ret = mainloop();
				if(ret == 0){
					qDebug("select I/O timeout\n");
					continue;
				}
				else if(ret == -1){
					qDebug("select I/O error\n");
					continue;
				}
				//帧数据处理
				unsigned char onebuf[640*480*3];
				ret = handleData(onebuf);
				if(ret == -1){
					m_type = 0;
					break;
				}
				QImage img = QImage(onebuf,640,480,QImage::Format_RGB888);
				if(!img.isNull())
					emit sign_img(img);
			}
        }
        else if(m_type == 0){
			close_device();
			if(open_device() == -1){
				m_type = 1;
				continue;
			}
			if(init_device(m_type) == -1){
				m_type = 1;
				continue;
			}
			if(start_capturing(m_type) == -1){
				m_type = 1;
				continue;
			}
			while(1){
				ret = mainloop();
				if(ret == 0){
					qDebug("select I/O timeout\n");
					continue;
				}
				else if(ret == -1){
					qDebug("select I/O error\n");
					continue;
				}
				//帧数据处理
				CLEAR(buf);
				buf.type = V4L2_BUF_TYPE_VIDEO_CAPTURE_MPLANE;
				buf.memory = V4L2_MEMORY_MMAP;
				buf.m.planes = mplanes;
				buf.length=1;
				/* 出队 */
				if(0 > ioctl(fd,VIDIOC_DQBUF,&buf)){
					qDebug("出队失败");
					m_type = 1;
					continue;
				}
				unsigned char onebuf[buf.m.planes->bytesused];
				//数据处理
				memcpy(onebuf, csi_buffers[buf.index].start[0], buf.m.planes->bytesused);
				/* 入队 */
				if(0 > ioctl(fd,VIDIOC_QBUF,&buf)){
					qDebug("入队失败");
					m_type = 1;
					break;
				}
				QImage img = QImage(onebuf,img_width,img_height,QImage::Format_RGB888);
				if(!img.isNull())
					emit sign_img(img);
			}
		}
    }
    while(1){
    }
    stop_capturing(m_type);
    uninit_device(m_type);
    close_device();
}

YUYVQThread::~YUYVQThread()
{
    exit_show();
}

int YUYVQThread::handleData(unsigned char *bufData)
{
    struct v4l2_buffer buf;
    CLEAR(buf);
    buf.type = V4L2_BUF_TYPE_VIDEO_CAPTURE;
    buf.memory = V4L2_MEMORY_MMAP;
    /* 出队 */
    if(0 > ioctl(fd,VIDIOC_DQBUF,&buf)){
        qDebug("handleData出队失败\n");
        return -1;
    }

    //数据处理
    unsigned char temp[buf.bytesused];
    memcpy(temp, usb_buffers[buf.index].start, buf.bytesused);
    yuv_to_rgb(temp, bufData);

    /* 再次入队*/
    if (0 > ioctl(fd, VIDIOC_QBUF, &buf)) {
        qDebug("handleData入队失败\n");
        return -1;
    }
    return 0;
}

void YUYVQThread::exit_show(){

}

void YUYVQThread::yuv_to_rgb(unsigned char *yuv, unsigned char *rgb){
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

    for(i = 0; i <= (PIXWIDTH * PIXHEIGHT) / 2 ;i++)
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

void YUYVQThread::set_device(QString device)
{
    strcpy(dev_name,device.toUtf8().data());
}
