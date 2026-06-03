#ifndef CAMERA_DATA_H
#define CAMERA_DATA_H

#include <sys/types.h>
#include <linux/videodev2.h>
//默认申请4个buffer
#define FRAMEBUFFER_COUNT 4
#define CLEAR(x) memset(&(x), 0, sizeof(x))
#define v4l2_fourcc_i(a, b, c, d)\
((__u32)(a) | ((__u32)(b) << 8) | ((__u32)(c) << 16) | ((__u32)(d) << 24))
//多平面
struct csi_buffer {
    void **  start;     //多平面内存映射的地址数组
    size_t*  length;
};
//单平面
struct usb_buffer{
    void *  start;      //单平面内存映射的地址
    size_t  length;
};

struct camera_info {
    char dev_name[32];              // 摄像头节点
    int fd;
    int width;
    int height;
    unsigned int capabilities;      //相机能力（单平面还是多平面）
    enum v4l2_buf_type type;        //申请buffer的格式
    __u32 pixelformat;              //编码格式
    int NUM_PLANES;
    size_t frame_length;            //一帧数据大小，用于创建数组
    union {
        struct csi_buffer multi_plane[FRAMEBUFFER_COUNT];
        struct usb_buffer simple_plane[FRAMEBUFFER_COUNT];
    } caputure_type;
};

#endif // CAMERA_DATA_H
