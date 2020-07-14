### 2.4 公共服务

&emsp;&emsp;本章节演示使用MEasy HMI 2.0中的公共服务类别下面的取票机应用来模拟进行取票的过程，详情请参考源码。

**软件环境:**

* 取票机应用

**硬件环境：**

* 支持MEasy HMI 2.0的MYIR开发板一块


**界面介绍：**

{% raw %}
<div  align="center" >
<img src="/imagech/2-4-1.png",alt="cover", width=480 >
</div>
<div align="center" > 图2-4-1 取票机界面 </div>
<p></p>
{% endraw %}  

{% raw %}
<div  align="center" >
<img src="/imagech/2-4-2.png",alt="cover", width=480 >
</div>
<div align="center" > 图2-4-2 出票成功界面 </div>
<p></p>
{% endraw %} 
{% raw %}
<div  align="center" >
<img src="/imagech/2-4-3.png",alt="cover", width=480 >
</div>
<div align="center" > 图2-4-3 出票失败界面 </div>
<p></p>
{% endraw %}   

> 注意： 
> 1.默认取票码为MYIR2020 <br>
> 2.扫描取票只是一个静态显示，没有实际的功能。  


**测试步骤：**

* 主界面点击取票机应用进入取票机界面。
* 点击屏幕上的软键盘，输入取票码myir2020，输入完成后点击确认取票。
* 取票码输入正确就会弹出票成功的动画，15秒后自动退出，也可点击右上角按钮退出。取票码输入错误会弹出出票失败的动画，10秒后自动退出，也可点击右上角按钮退出。
* 点击左上角的按钮退出取票机应用。




