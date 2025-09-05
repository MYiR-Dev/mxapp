#ifndef CAMERA_QTHREAD_H
#define CAMERA_QTHREAD_H

#include <QObject>
#include <QThread>
#include <QDebug>
#include <QImage>

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include <poll.h>
#include <atomic>

#include <fcntl.h>              /* low-level i/o */
#include <unistd.h>
#include <errno.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <sys/time.h>
#include <sys/mman.h>
#include <sys/ioctl.h>
#include "camera_data.h"
#include "multicamera.h"
#include "abstractcamera.h"

#include <linux/videodev2.h>

using namespace std;

class Camera_qthread : public QThread
{
    Q_OBJECT
public:
    static Camera_qthread* getInstance();
    void run() override;
    static AbstractCamera* camera_handle;
    class Autorealse{
    public:
        Autorealse() = default;
        ~Autorealse();
    };

    int xioctl(int fh, int request, void *arg);
    bool set_device(QString device, int in_width = 640, int in_height = 480);
    bool isMultiCamera(int fd);
    void exit_camera();
signals:
    void sign_img(QImage images);

private:
    explicit Camera_qthread();
    static Camera_qthread* CameraHandleSingle;
    static pthread_mutex_t camera_mutex;
    Autorealse ar;
    struct camera_info m_camera;
    unsigned int n_buffers;
    atomic<bool> frameLoop{false};

    int handleData(unsigned char *bufData);
    int start_capturing();
    void stop_capturing();
    int init_device(int camera_fd, int &m_type);
    void exit_device();
    int init_mmap(int camera_fd);
    void close_device(void);
    int open_device(char* dev_name);
    void yuv_to_rgb(unsigned char *yuv, unsigned char *rgb);
};

#endif // CAMERA_QTHREAD_H
