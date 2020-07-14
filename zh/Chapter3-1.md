### 3.1 环境搭建

&emsp;&emsp;本章讲述的MEasy HMI2.0的环境包含开发板上的QT5运行环境和ubuntu主机端的的qmake及交叉编译工具链。AM335X系列开发板上的QT5运行环境和ubuntu主机端的qmake及交叉编译工具链是通过buildroot编译生成的。i.MX6UL系列和STM32MP1系列开发板上的QT5运行环境和ubuntu主机端的qmake和交叉编译工具链是通过yocto编译生成的，具体操作参见对应产品的软件开发手册。

{% raw %}
<div align="center" > 表3-1-1 AM335X,i.MX6UL,STM32MP1系列开发板编译QT开发环境和运行环境 </div>
<p></p>
{% endraw %} 

| 开发板 | 文档章节 |
| :--- | :--- |
| MYD-C335X-GW | MYD-C335X-GW Linux 4.14.67 开发手册.pdf  3.4编译QT |
| MYD-Y6ULX | MYD-Y6ULX-LinuxDevelopmentGuide_zh  3.3构建文件系统-构建GUI Qt5版的系统|
| MYS-6ULX | MYS-6ULX-LinuxDevelopmentGuide_zh.pdf  3.3构建文件系统-构建GUI Qt5版的系统|
| MYD-YA157C | MYD-YA157C Linux 软件开发手册.pdf  4.5.2 构建文件系统|

&emsp;&emsp;QT5开发工具QT Creator的安装过程直接参考其文档的章节具体如下表：
{% raw %}
<div align="center" > 表3-1-2 AM335X,i.MX6UL,STM32MP1安装QT Creator </div>
<p></p>
{% endraw %} 

| 开发板 | 文档章节 |
| :--- | :--- |
| MYD-C335X-GW  | MYD-C335X-GW Linux 4.14.67开发手册.pdf  5.1安装QT Creator |
| MYD-Y6ULX | MYD-Y6ULX-LinuxDevelopmentGuide_zh  5.1安装QT Creator |
| MYS-6ULX | MYS-6ULX-LinuxDevelopmentGuide_zh.pdf  5.1安装QT Creator |
| MYD-YA157C | MYD-YA157C Linux 软件开发手册.pdf  8.2安装QT Creator|

&emsp;&emsp;QT5开发工具QT Creator的配置过程直接参考其文档的章节具体如下表：
{% raw %}
<div align="center" > 表3-1-3  AM335X,i.MX6UL,STM32MP1系列开发板配置QT Creator </div>
<p></p>
{% endraw %} 

| 开发板 | 文档章节 |
| :--- | :--- |
| MYD-C335X-GW  | MYD-C335X-GW Linux 4.14.67开发手册.pdf  5.2配置QT Creator |
| MYD-Y6ULX | MYD-Y6ULX-LinuxDevelopmentGuide_zh  5.2配置QT Creator |
| MYS-6ULX | MYS-6ULX-LinuxDevelopmentGuide_zh.pdf  5.2配置QT Creator |
| MYD-YA157C | MYD-YA157C Linux 软件开发手册.pdf  8.3配置交叉编译环境|


