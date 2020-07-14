### 2.2 Mutilmedia

This chapter demonstrates how to use the multimedia application in MEasy HMI 2.0 to control the development board for camera screen capture / photographing, video playback, music playback, picture browsing and other functions.

**Software Environment：**

* Camera application
* Player app
* Music app
* Picture application

Hardware Environment**：**

* A MYIR development board supporting MEasy HMI 2.0
* One USB camera



**UI Description：**

{% raw %}
<div  align="center" >
<img src="/imagech/2-2-1.png",alt="cover", width=480 >
</div>
<div align="center" > Figure 2-2-1 Camera application interface </div>
<p></p>
{% endraw %}  

> Note: The development board connected to the USB camera will automatically display the screen captured by the camera.

{% raw %}
<div  align="center" >
<img src="/imagech/2-2-2.png",alt="cover", width=480 >
</div>
<div align="center" > Figure 2-2-2 Video player interface </div>
<p></p>
{% endraw %}  

> Note: The pre-stored video files of the development board are located in the development board/usr/share/myir/Video directory. After opening the video player application, a video file will be automatically selected. Users can add videos to this directory by themselves. It is recommended that the video resolution should not be greater than 480p , Otherwise it will cause the playback to freeze.

{% raw %}
<div  align="center" >
<img src="/imagech/2-2-3.png",alt="cover", width=480 >
</div>
<div align="center" > Figure 2-2-3 Music player interface. </div>
<p></p>
{% endraw %}  

> Note: The pre-stored audio files of the development board are located in the development board/usr/share/myir/Music directory. After opening the music player application, an audio file will be automatically selected. Users can add audio files to this directory by themselves. Some development boards do not have audio chips, so they cannot hear sound.

{% raw %}
<div  align="center" >
<img src="/imagech/2-2-4.png",alt="cover", width=480 >
</div>
<div align="center" > Figure 2-2-4 Picture browser interface </div>
<p></p>
{% endraw %}  

> Note: The pre-stored picture files of the development board are located in the development board/usr/share/myir/Capture directory, and users can add picture files to this directory by themselves.

**Test steps:**

Camera application

* Insert the USB camera into the USB port of the development board, and then enter the camera application.
* Click the camera application on the main interface to enter the camera interface and you can see the real-time screen output of the camera. Click the origin button below to take a picture.
* Open all the photo buttons in the upper right corner to browse the pictures taken.
* Click the back button in the upper left corner to exit the camera application.
***

Player application

* Click the player application on the main interface to enter the player interface. By default, a pre-stored video will be selected.
* Click the middle play button to start the video playback, click again to pause the video playback.
* Click the bottom button to fast forward, rewind, pause, stop, play the previous one, and play the next one.
* Click on the open file in the upper right corner to go to the video list for selection.
* Click the back button in the upper left corner to exit the player application.

***
Music app
* Click the music application on the main interface to enter the music interface. By default, a pre-stored audio file will be selected.
* Click the bottom button to fast forward, rewind, pause, stop, play the previous one, and play the next one.
* Click on the open file in the upper right corner to go to the video list for selection.
* Click the back button in the upper left corner to exit the music application

***
Picture application

* Click the picture application on the main interface to enter the picture interface, you can see the thumbnails of the pre-stored pictures.
* Click a thumbnail, the picture will be enlarged for full screen display, click the left and right arrow buttons to switch the picture. Click the all pictures button in the upper right corner to return to the thumbnail display. Click the delete picture button to delete the picture.
* In the thumbnail interface, click the open file in the upper right corner to enter the path of the pre-stored pictures.
* Click the back button in the upper left corner to exit the music application
***



