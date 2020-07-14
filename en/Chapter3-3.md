### 3.3 Running HMI 2.0 Applications

This chapter mainly describes the running process of MEasy HMI 2.0.

> Note: Due to the different version of qt creator used by each board, there may be a different picture from the current qt creator interface. All pictures below in this chapter are taken from the compilation environment of the MYD-C335X-GW development board used with qt Creator 4.8. 

After the compilation is complete, the compiled program can be uploaded to the development board for running. There are two methods for uploading the program to the development board.

Method One: Direct Upload Operation by Configuring Qt Creator

* Configure the remote device of Qt Creator


&emsp;&emsp;Enter the Device type selection page by selecting the menu bar `Tools->Options->Devices`, select Devices and then click the` Add..` button on the upper right corner of this page to enter the device type selection and select Generic Linux Device.
{% raw %}
<div  align="center" >
<img src="/imagech/3-3-1.png",alt="cover", width=480 >
</div>
<div align="center" >Figure 3-3-1 Create device  </div>
<p></p>
{% endraw %}

Click the `Start Wizard` button to enter the device configuration page, and configure according to the following figure. The IP address needs to be logged on the board to view. After the configuration is completed, click the` Next` button to automatically enter the device connectivity test.

{% raw %}
<div  align="center" >
<img src="/imagech/3-3-2.png",alt="cover", width=480 >
</div>
<div align="center" >Figure 3-3-2 Configuring the device  </div>
<p></p>
{% endraw %}


If the above steps have been completed, the following steps only operate when the IP address changes. By selecting the menu bar `Tools->Options->Devices`, select `myir (default for Generic Linux)` in Device, enter the development board IP in the _Type Specific_ field \(you need to log in to the development board through the serial port to view\), user name, and do not need to fill in the password. As shown in Figure 3-3-3.

{% raw %}
<div  align="center" >
<img src="/imagech/3-3-3.png",alt="cover", width=480 >
</div>
<div align="center" >Figure 3-3-3 Change setting  </div>
<p></p>
{% endraw %}  


* Test remote device connectivity

After the input is complete, click the`Apply` button, and then click the `Test`button on the right side will automatically pop up the test connection window when _Device test finished successfully_. The word means the test connection is successful. As shown in Figure 3-3-4.
{% raw %}
<div  align="center" >
<img src="/imagech/3-3-4.png",alt="cover", width=480 >
</div>
<div align="center" >Figure 3-3-4 Equipment testing </div>
<p></p>
{% endraw %}  


* Specify the program to run

After the test connection is successful, return to the main interface of Qt Creator. To specify the program you want to run, select the program that needs to run as _mxapp2_. As shown in Figure 3-3-5.  

{% raw %}
<div  align="center" >
<img src="/imagech/3-3-5.png",alt="cover", width=480 >
</div>
<div align="center" >Figure 3-3-5 Select the program to run </div>
<p></p>
{% endraw %}  
* Specify the parameters for the program to run

> This step is required for running on the MYD-C335X-GW development board, and is not required for other platforms.

After specifying the program to be run, you also need to specify the program's operating parameters. Click `Projects->mxapp2->Build & Run ->myir->Run` to pull down to the Run configuration column and write in the Arguments input box_ --platform linuxfb_, which completes the specification of the program's operating parameters. As shown in Figure 3-3-6.  

{% raw %}
<div  align="center" >
<img src="/imagech/3-3-6-1.jpg",alt="cover", width=480 >
</div>
<div align="center" >Figure 3-3-6  Program operating parameters </div>
<p></p>
{% endraw %}  

After specifying the program that needs to be run, you also need to specify the running parameters of the program. Click the `Projects`->`mxapp2`->`Build & Run`;` myir`->`Run` drop down to the Run Enviroment configuration bar Click the Details button, and then click the add button to add the following environment variables in sequence. The addition can be verified using the `Fetch Device Enviroment` button. As shown in Figure 3-3-7.
```
QT_QPA_EGLFS_INTEGRATION=none
QT_QPA_EGLFS_PHYSICAL_HEIGHT=120
QT_QPA_EGLFS_PHYSICAL_WIDTH=200
QT_QPA_EGLFS_TSLIB=1
QT_QPA_PLATFORM=eglfs
QT_WAYLAND_SHELL_INTEGRATION=xdg-shell-v5
TSLIB_TSDEVICE=/dev/input/event0
```

{% raw %}
<div  align="center" >
<img src="/imagech/3-3-6.png",alt="cover", width=480 >
</div>
<div align="center" >Figure 3-3-7 Program running environment variables </div>
<p></p>
{% endraw %}  

* Kill the running MEasy HMI 2.0 related program on the development board

After specifying the running parameters, you need to login in to the development board and kill the currently running MEasy HMI 2.0 related program. The operation is as follows:

`# killall mxapp2`

* Upload the program to the development board and run

Click the Run button in the lower left corner, or click the menu bar `Build->Run` to upload mxapp to the development board and run it. On the 7-inch screen, you can see the MEasy HMI 2.0 interface. The running debugging information can be seen in _3 Application Output_, as shown in Figure 3-3-8.



{% raw %}
<div  align="center" >
<img src="/imagech/3-3-7.png",alt="cover", width=480 >
</div>
<div align="center" >Figure 3-3-8 Application Output </div>
<p></p>
{% endraw %}  




Method two: directly copy the compiled program to the development board

Click the `Projects`button on the left, you can see the project's compilation and configuration. The _Build directory_ in the General column shows the path of the mxapp2 project's compiled output . You can copy the program directly to the development board from here. As shown in Figure 3-3-9.

{% raw %}
<div  align="center" >
<img src="/imagech/3-3-8.png",alt="cover", width=480 >
</div>
<div align="center" >Figure 3-3-9 Project compilation output </div>
<p></p>
{% endraw %}  


Open the compile output directory, you can copy the mxapp2 application to the development board through the network, U disk, SD card. The operation method is as follows:


To run on the MYD-C335X-GW development board, you need to specify environment variables and operating parameters.

```
# source /etc/qt_env.sh
#./mxapp2 --plugin tslib:$TSLIB_TSDEVICE

QStandardPaths: XDG_RUNTIME_DIR not set, defaulting to '/tmp/runtime-root'
qml: index=0
qml: currentIndex=0
qml: index=0
net_status 1
libpng warning: iCCP: known incorrect sRGB profile
libpng warning: iCCP: known incorrect sRGB profile
libpng warning: iCCP: known incorrect sRGB profile
libpng warning: iCCP: known incorrect sRGB profile
libpng warning: iCCP: known incorrect sRGB profile
libpng warning: iCCP: known incorrect sRGB profile
libpng warning: iCCP: known incorrect sRGB profile
```
Other series of development boards run directly according to the following parameters.

```
# ./mxapp2
qt.qpa.input: X-less xkbcommon not available, not performing key mapping
qml: index=0
qml: currentIndex=0
qml: index=0
net_status 1
libpng warning: iCCP: known incorrect sRGB profile
libpng warning: iCCP: known incorrect sRGB profile
libpng warning: iCCP: known incorrect sRGB profile
libpng warning: iCCP: known incorrect sRGB profile
libpng warning: iCCP: known incorrect sRGB profile
libpng warning: iCCP: known incorrect sRGB profile
libpng warning: iCCP: known incorrect sRGB profile
libpng warning: iCCP: known incorrect sRGB profile
libpng warning: iCCP: known incorrect sRGB profile
libpng warning: iCCP: known incorrect sRGB profile
libpng warning: iCCP: known incorrect sRGB profile
```

