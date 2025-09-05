#ifndef MULTICAMERA_H
#define MULTICAMERA_H

#include "abstractcamera.h"

class MultiCamera : public AbstractCamera
{
public:
    MultiCamera();
    virtual ~MultiCamera();
    virtual int init_device(struct camera_info& in_camera) override;
    virtual void exit_device(struct camera_info& in_camera) override;
    virtual int start_capturing(struct camera_info& in_camera) override;
    virtual int stop_capturing(struct camera_info& in_camera) override;
    virtual int framebuffer_handle(struct camera_info& in_camera, struct v4l2_buffer& buf, unsigned char* framebuf) override;
private:
    int init_mmap(struct camera_info& in_camera);
};

#endif // MULTICAMERA_H
