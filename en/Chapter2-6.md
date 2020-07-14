### 2.6 Sysgtem

This chapter demonstrates the use of system information, system settings, and file manager under the system category in MEasy HMI 2.0.

You can view basic system information, network information, and copyright information through the system information application.

The system time and date can be set through the system setting application, the network ip, netmask, gateway, dns, wifi switch, scan, connect, disconnect.

Browse the file system directory of the development board through the file browser application.

**Software Environment：**

* System information application
* System setting application
* File browser application.

**Hardware Environment：**

* A MYIR development board supporting MEasy HMI 2.0

**UI Description：**

***
System Message

{% raw %}
<div  align="center" >
<img src="/imagech/2-6-1.png",alt="cover", width=480 >
</div>
<div align="center" > Figure 2-6-1 Basic information interface </div>
<p></p>
{% endraw %}  

{% raw %}
<div  align="center" >
<img src="/imagech/2-6-2.png",alt="cover", width=480 >
</div>
<div align="center" > Figure 2-6-2 Network information interface </div>
<p></p>
{% endraw %}  

{% raw %}
<div  align="center" >
<img src="/imagech/2-6-3.png",alt="cover", width=480>
</div>
<div align="center" > Figure 2-6-3 Copyright Information Interface </div>
<p></p>
{% endraw %}  

***
System Settings

{% raw %}
<div  align="center" >
<img src="/imagech/2-6-4.png",alt="cover", width=480 >
</div>
<div align="center" > Figure 2-6-4 Time setting interface </div>
<p></p>
{% endraw %}  

{% raw %}
<div  align="center" >
<img src="/imagech/2-6-5.png",alt="cover", width=480 >
</div>
<div align="center" > Figure 2-6-5 Ethernet setting interface </div>
<p></p>
{% endraw %}  

{% raw %}
<div  align="center" >
<img src="/imagech/2-6-6.png",alt="cover", width=480 >
</div>
<div align="center" > Figure 2-6-6 WIFI setting interface </div>
<p></p>
{% endraw %}  

***
File Browser

{% raw %}
<div  align="center" >
<img src="/imagech/2-6-7.png",alt="cover", width=480 >
</div>
<div align="center" > Figure 2-6-7 File browser interface </div>
<p></p>
{% endraw %}  

***

**Test steps:**

***
system message
* Click the system information application on the main interface to enter the system information interface. By default, the basic information interface will be displayed.
* Select the network information and copyright information in the left navigation bar to switch to the network information and copyright information interface.
* Click the back button in the upper left corner to exit the system information interface.

***
System settings

* Click the system setting application on the main interface to enter the system setting interface. By default, the time setting interface will be displayed.
* Select the Ethernet settings on the left navigation bar, wifi settings can be switched to the Ethernet settings interface, wifi settings interface.
* In the time setting interface, select the time and date you want to set through the selection box, and then click the save button, the time and date will be set to the system, the calendar needs to exit the system settings application and enter again to be refreshed.
* In the network setting interface, click the ip address, subnet mask, gateway, dns input box to pop up the soft keyboard. The soft keyboard can only be input according to the IPV4 format, otherwise the input is invalid.

* Click the slide switch in the upper right corner of the wifi setting interface to turn on wifi and automatically scan nearby wifi hotspots and display them on the interface. Before clicking the connect button, you need to enter the password through the password input box. WiFi without a password can be directly connected.
* Click the back button in the upper left corner to exit the system setting interface.

***
File browser

* Click the file browser application on the main interface to enter the file browser interface.
* Click on the folder picture to enter the next directory, click the <button to return to the previous directory.
* Click the back button in the upper left corner to exit the file browser application.

***



