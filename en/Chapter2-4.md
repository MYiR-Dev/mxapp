### 2.4 Public Service

This chapter demonstrates the use of the ticket machine application under the public service category in MEasy HMI 2.0 to simulate the process of ticket collection. For details, please refer to the source code.

**Software Environment：**

* Ticket machine application

**Hardware Environment：**

* A MYIR development board supporting MEasy HMI 2.0


**UI Description：**

{% raw %}
<div  align="center" >
<img src="/imagech/2-4-1.png",alt="cover", width=480 >
</div>
<div align="center" > Figure 2-4-1 Ticket machine interface </div>
<p></p>
{% endraw %}  

{% raw %}
<div  align="center" >
<img src="/imagech/2-4-2.png",alt="cover", width=480 >
</div>
<div align="center" > Figure 2-4-2 Successful ticket issuance interface </div>
<p></p>
{% endraw %} 
{% raw %}
<div  align="center" >
<img src="/imagech/2-4-3.png",alt="cover", width=480 >
</div>
<div align="center" > Figure 2-4-3 Ticket Failure Interface </div>
<p></p>
{% endraw %}   

> Note:
> 1. The default ticket collection code is MYIR2020
> 2. Scanning for ticket collection is only a static display, no actual function.

**Test steps:**

* Click the ticket machine application on the main interface to enter the ticket machine interface.
* Click on the soft keyboard on the screen, enter the ticket collection code myir2020, and click confirm to pick up the ticket after input.
* If you enter the correct ticket code, a successful animation will pop up. After 15 seconds, you will automatically quit. You can also click the upper right button to quit If the ticket code is entered incorrectly, a pop-up failure animation will pop up. It will automatically exit after 10 seconds, or you can click the button in the upper right corner to exit.
* Click the button in the upper left corner to exit the ticket machine application.



