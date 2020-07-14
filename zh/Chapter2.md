## 2. HMI 2.0使用介绍

---

&emsp;&emsp;本节主要介绍MEasy HMI 2.0中每个APP的使用及使用过程中注意的细节。

**软件环境：**

* u-boot
* linux-4.x.x
* 带QT5运行环境的文件系统
* MEasy HMI V2.0应用程序


**硬件环境：**

* MY-TFT070CV2电容屏/HDMI显示屏
* MYIR AM335X, i.MX6UL, STM32MP157系列开发板 

> 默认出厂程序只支持LCD显示和HDMI显示，用户选择使用LCD还是HDMI，需要根据对应板卡的文档进行设置。

**硬件连接方式:**

{% raw %}
<div align="center" > 表2-1 开发板显示屏接口 </div>
{% endraw %}  

| 开发板 | LCD接口 |
| :--- | :--- |
| MYD-C335X-GW | J14 LCD |
| MYD-Y6ULX | J3 LCD |
| MYS-6ULX | J8 LCD |
| MYD-YA157 | J18 LCD /J10 HDMI|

