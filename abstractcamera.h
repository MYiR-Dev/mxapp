#ifndef ABSTRACTCAMERA_H
#define ABSTRACTCAMERA_H

#include <QDebug>
#include <QStringList>

#include <assert.h>
#include <poll.h>
#include <stdlib.h>

#include <fcntl.h> /* low-level i/o */
#include <sys/ioctl.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <sys/time.h>
#include <sys/types.h>
#include <unistd.h>

#include <linux/videodev2.h>

#include "camera_data.h"

#define CLEAR(x) memset(&(x), 0, sizeof(x))

class AbstractCamera {
public:
  AbstractCamera();
  virtual ~AbstractCamera();
  virtual int init_device(struct camera_info &in_camera);
  virtual void exit_device(struct camera_info &in_camera);
  virtual int start_capturing(struct camera_info &in_camera);
  virtual int stop_capturing(struct camera_info &in_camera);
  virtual int framebuffer_handle(struct camera_info &in_camera,
                                 struct v4l2_buffer &buf,
                                 unsigned char *framebuf);
  int xioctl(int fh, int request, void *arg);
  int n_buffers = 0;
  QStringList pixformat_l;

private:
};

#endif // ABSTRACTCAMERA_H
