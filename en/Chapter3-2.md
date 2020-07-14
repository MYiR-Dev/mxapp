### 3.2 Compiling HMI 2.0 Applications

This chapter mainly describes the compilation process of MEasy HMI 2.0.
> Note: Due to the different version of qt creator used by each board, there may be a different picture from the current qt creator interface. All pictures below in this chapter are taken from the compilation environment of the MYD-C335X-GW development board used with qt Creator 4.8.

We provide MEasy HMI 2.0 source code located in the /04-Linux\_Source/MEasy\_HMI2.0/mxapp2.tar.gz directory on the CD-ROM. Copy mxapp2.tar.gz to the ubuntu directory working directory and extract it.

The following describes how to import mxapp2 project into Qt Creator, open QT Creator, click `File`-&gt;`Open File or Project` in the menu bar and then pop up the box as shown in Figure 3-2-1, enter mxapp2 project directory, click `mxapp2.pro` and click the `Open` button to open the mxapp2 project.

{% raw %}
<div  align="center" >
<img src="/imagech/3-2-1.png",alt="cover", width=480 >
</div>
<div align="center" > Figure 3-2-1 Project selection box </div>
<p></p>
{% endraw %}  


After opening the project, enter the configuration page, select the compilation tool chain, directly select the kits configured in Chapter 3.1, click the `Configure Project` button, and then enter the project directory.
{% raw %}
<div  align="center" >
<img src="/imagech/3-2-2.png",alt="cover", width=480 >
</div>
<div align="center" > Figure 3-2-2  Config kits </div>
<p></p>
{% endraw %}  


After entering the mxapp2 project, you can see the directory structure of the entire project, as shown in Figure 3-2-3. Then you can compile the project, before compiling can choose to compile the output mode, here we choose Release mode, and then you can select the right lower corner of the small hammer icon to compile the entire project, or by clicking on the menu bar `Build-`&gt; `Build Project "mxapp2"` to compile the entire project.

{% raw %}
<div  align="center" >
<img src="/imagech/3-2-3.png",alt="cover", width=480 >
</div>
<div align="center" > Figure 3-2-3 Project Directory </div>
<p></p>
{% endraw %} 


The compilation process can be seen from the bottom of the Table column `4 Compile Output`, as shown in Figure 3-2-4.

{% raw %}
<div  align="center" >
<img src="/imagech/3-2-4.png",alt="cover", width=480 >
</div>
<div align="center" > Figure 3-2-4 Compile Output </div>
<p></p>
{% endraw %}  


The errors and warnings that appear in the compilation can be seen from the bottom of the Table column `1 Issues`, as shown in Figure 3-2-5. If the compile error can be output from here for analysis problems.

{% raw %}
<div  align="center" >
<img src="/imagech/3-2-5.png",alt="cover", width=480 >
</div>
<div align="center" > Figure 3-2-5 Issues Output </div>
<p></p>
{% endraw %}  


