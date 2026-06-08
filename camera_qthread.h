#ifndef CAMERA_QTHREAD_H
#define CAMERA_QTHREAD_H

#include <QObject>
#include <QThread>
#include <QDebug>
#include <QImage>

#include <assert.h>
#include <poll.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <atomic>

#include <errno.h>
#include <fcntl.h> /* low-level i/o */
#include <sys/ioctl.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <sys/time.h>
#include <sys/types.h>
#include <unistd.h>

#include <linux/videodev2.h>

#include "camera_data.h"
#include "multicamera.h"
#include "abstractcamera.h"

class Camera_qthread : public QThread
{
    Q_OBJECT
public:
    static Camera_qthread* getInstance();
    void run() override;
    int xioctl(int fh, int request, void *arg);
    bool set_device(QString device, int in_width = 1280, int in_height = 720);
    bool isMultiCamera(int fd);
    void exit_camera();

    class AutoRelease{
    public:
        AutoRelease() = default;
        ~AutoRelease();
    };

signals:
    void sign_img(QImage images);

private:
    explicit Camera_qthread();
    static Camera_qthread* CameraHandleSingle;
    static pthread_mutex_t camera_mutex;
    static AbstractCamera* camera_handle;
    AutoRelease ar;
    struct camera_info m_camera;
    unsigned int n_buffers;
    std::atomic<bool> frameLoop{false};
    unsigned char *onebuf = nullptr;

    int open_device(char* dev_name);
    void yuv_to_rgb(unsigned char *yuv, unsigned char *rgb);
    void nv12_to_rgb(unsigned char *nv12, unsigned char *rgb);
};

#endif // CAMERA_QTHREAD_H
