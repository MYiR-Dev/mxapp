### 3.3 运行MEasy HMI 2.0应用

&emsp;&emsp;本章节主要讲述MEasy HMI 2.0的运行过程。编译完成后可以将编译完成的程序上传至开发板进行运行，这里提供两个方法将程序上传至开发板。

> 注意：因各板卡的配套使用的qt creator版本不同，可能会存在图片和你当前使用qt creator界面不同。本章节下面所有图片取自qt Creator 4.8 配套使用的MYD-C335X-GW开发板的编译环境。

** 方法一：通过配置Qt Creator直接上传运行 **  

* 配置Qt Creator的远程设备


&emsp;&emsp;通过选择菜单栏`Tools`-&gt;`Options`-&gt;`Devices` 进入Devices类型选择页面，选择Devices然后在这个页面点击右上角的`Add..`按钮，进入设备类型选择，选择Generic Linux Device。
{% raw %}
<div  align="center" >
<img src="/imagech/3-3-1.png",alt="cover", width=480 >
</div>
<div align="center" >图3-3-1 创建设备  </div>
<p></p>
{% endraw %}
点击`Start Wizard`按钮，进入设备配置页面，按照下图进行配置，IP地址需要登录到板子上进行查看，配置完成点击`Next`按钮，会自动进入设备连通性测试。
{% raw %}
<div  align="center" >
<img src="/imagech/3-3-2.png",alt="cover", width=480 >
</div>
<div align="center" >图3-3-2 配置设备  </div>
<p></p>
{% endraw %}
&emsp;&emsp;如果上述步骤已完成，下面步骤只是针对IP地址改变的时候进行操作。通过选择菜单栏`Tools`-&gt;`Options`-&gt;`Devices` 在Device中选择`myir (default for Generic Linux)`，在Type Specific栏输入开发板IP（需要通过串口登录到开发板查看）、用户名，不需要填写密码。如图3-3-3所示。

{% raw %}
<div  align="center" >
<img src="/imagech/3-3-3.png",alt="cover", width=480 >
</div>
<div align="center" >图3-3-3 修改配置  </div>
<p></p>
{% endraw %}  

* 测试远端设备连通性

&emsp;&emsp;输入完毕后点击`Apply`按钮，然后点击右侧`Test`按钮会自动弹出测试连接的窗口当出现Device test finished successfully.字样意味着测试连接成功。如图3-3-4所示。
{% raw %}
<div  align="center" >
<img src="/imagech/3-3-4.png",alt="cover", width=480 >
</div>
<div align="center" >图3-3-4 设备测试 </div>
<p></p>
{% endraw %}  

* 指定运行的程序

&emsp;&emsp;测试连接成功后，返回到Qt Creator的主界面，要指定你运行的程序，选择需要Run的程序为mxapp2。如图3-3-5所示。  
{% raw %}
<div  align="center" >
<img src="/imagech/3-3-5.png",alt="cover", width=480 >
</div>
<div align="center" >图3-3-5 选择需要运行的程序 </div>
<p></p>
{% endraw %}  


* 指定程序运行的参数和环境变量

> 在MYD-C335X-GW开发板上运行需要此步骤，其他平台不需要此步骤。

&emsp;&emsp;指定完需要运行的程序以后，还需要指定程序的运行参数，依次点击左侧`Projects`-&gt;`mxapp2`-&gt;`Build & Run` -&gt;`myir`-&gt; `Run`下拉到Run配置栏，在Command line arguments输入框写入`--plugin tslib:$TSLIB_TSDEVICE`,即完成了程序运行参数的指定。如图3-3-6所示。  
{% raw %}
<div  align="center" >
<img src="/imagech/3-3-6-1.jpg",alt="cover", width=480 >
</div>
<div align="center" >图3-3-6  程序运行参数 </div>
<p></p>
{% endraw %}  

&emsp;&emsp;指定完需要运行的程序以后，还需要指定程序的运行参数，依次点击左侧`Projects`-&gt;`mxapp2`-&gt;`Build & Run` -&gt;`myir`-&gt; `Run`下拉到Run Enviroment配置栏，点击Details按钮，再点击add按钮，依次添加下列环境变量。添加完成可以使用`Fetch Device Enviroment`按钮来验证。如图3-3-7所示。  
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
<div align="center" >图3-3-7  程序运行环境变量 </div>
<p></p>
{% endraw %}  


* 杀掉开发板上正在运行的mxapp2程序

&emsp;&emsp;指定完运行的参数以后，还需要登录到开发板，杀掉当前运行的MEasy HMI 2.0相关程序，操作如下：

`# killall mxapp2`


* 上传程序到开发板并运行

&emsp;&emsp;点击左下角的运行按钮，或者点击菜单栏`Build`-&gt;`Run`就可以将mxapp2上传至开发板并运行。7寸屏幕上可以看到MEasy HMI 2.0的界面，运行调试信息可以在`3 Application Output`中看到，如图3-3-8所示。
{% raw %}
<div  align="center" >
<img src="/imagech/3-3-7.png",alt="cover", width=480 >
</div>
<div align="center" >图3-3-8 程序输出 </div>
<p></p>
{% endraw %}  


** 方法二：直接拷贝编译好的程序到开发板 **  

&emsp;&emsp;点击左侧`Projects`按钮,可以看到工程的编译配置，General栏中Build directory显示的就是mxapp2工程编译输出的路径，可以从这里直接把程序拷贝到开发板中。如图3-3-9所示。
{% raw %}
<div  align="center" >
<img src="/imagech/3-3-8.png",alt="cover", width=480 >
</div>
<div align="center" >图3-3-9 工程编译输出 </div>
<p></p>
{% endraw %}  
  
&emsp;&emsp;打开编译输出目录，可通过网络、U盘、SD卡拷贝mxapp2这个应用程序到开发板。运行方法如下：


在MYD-C335X-GW开发板上运行需要指定环境变量和运行参数，通过下面命令进行操作。
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
其他系列开发板直接按照下面参数进行运行。

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



