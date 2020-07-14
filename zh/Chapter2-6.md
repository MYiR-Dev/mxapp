### 2.6 系统

&emsp;&emsp;本章节演示使用MEasy HMI 2.0中的系统类别下面的系统信息，系统设置，文件管理器。

&emsp;&emsp;通过系统信息应用可以来查看系统基本信息，网络信息，版权信息。

&emsp;&emsp;通过系统设置应用可以设置系统时间和日期，网络的ip、netmask、gateway、dns，wifi的开关、扫描、连接、断开。

&emsp;&emsp;通过文件浏览器应用来浏览开发板的文件系统目录。

**软件环境:**

* 系统信息应用
* 系统设置应用
* 文件浏览器应用


**硬件环境：**

* 支持MEasy HMI 2.0的MYIR开发板一块

**界面介绍：**
***
系统信息

{% raw %}
<div  align="center" >
<img src="/imagech/2-6-1.png",alt="cover", width=480 >
</div>
<div align="center" > 图2-6-1 基本信息界面 </div>
<p></p>
{% endraw %}  

{% raw %}
<div  align="center" >
<img src="/imagech/2-6-2.png",alt="cover", width=480 >
</div>
<div align="center" > 图2-6-2 网络信息界面 </div>
<p></p>
{% endraw %}  

{% raw %}
<div  align="center" >
<img src="/imagech/2-6-3.png",alt="cover", width=480>
</div>
<div align="center" > 图2-6-3 版权信息界面 </div>
<p></p>
{% endraw %}  

***
系统设置
{% raw %}
<div  align="center" >
<img src="/imagech/2-6-4.png",alt="cover", width=480 >
</div>
<div align="center" > 图2-6-4 时间设置界面 </div>
<p></p>
{% endraw %}  

{% raw %}
<div  align="center" >
<img src="/imagech/2-6-5.png",alt="cover", width=480 >
</div>
<div align="center" > 图2-6-5 以太网设置界面 </div>
<p></p>
{% endraw %}  

{% raw %}
<div  align="center" >
<img src="/imagech/2-6-6.png",alt="cover", width=480 >
</div>
<div align="center" > 图2-6-6 WIFI设置界面 </div>
<p></p>
{% endraw %}  

***
文件浏览器

{% raw %}
<div  align="center" >
<img src="/imagech/2-6-7.png",alt="cover", width=480 >
</div>
<div align="center" > 图2-6-7 文件浏览器界面 </div>
<p></p>
{% endraw %}  

***

**测试步骤：**

***
系统信息
* 点击主界面系统信息应用进入系统信息界面，默认会显示基本信息的界面。
* 选择左侧导航栏的网络信息，版权信息，可切换进入网络信息，版权信息的界面。
* 点击左上角的返回按钮可退出系统信息界面。

***
系统设置

* 点击主界面系统设置应用进入系统设置界面，默认会显示时间设置的界面。
* 选择左侧导航栏的以太网设置，wifi设置可切换进入以太网设置界面，wifi设置界面。
* 在时间设置界面通过选择框选择想要设置的时间和日期，然后点击保存按钮，时间和日期就会设置到系统，日历需要退出系统设置应用再次进入才会被刷新。
* 在网络设置界面点击ip地址、子网掩码、网关、dns输入框会弹出软键盘，软键盘只能按照IPV4的格式进行输入，否则输入无效。

* 在wifi设置界面点击右上角的滑动开关，可开启wifi,并自动扫描附近的wifi热点并显示到界面。点击连接按钮前需要通过密码输入框输入密码，没有设置密码的wifi可以直接连接。
* 点击左上角的返回按钮可退出系统设置界面。

***
文件浏览器

* 点击主界面文件浏览器应用进入文件浏览器界面。
* 点击文件夹图片可进入下一级目录，点击<按钮可返回上一级目录。
* 点击左上角得返回按钮，可退出文件浏览器应用。

***