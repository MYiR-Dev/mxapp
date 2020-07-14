### 4.1 AM335X系列开发板上集成MEasy HMI 2.0应用 

&emsp;&emsp;MEasy HMI 2.0在MYD-C335X-GW开发板上运行需要包含mxapp2应用程序、QT5运行库、eglfs库、字体文件、音视频以及图片等资源文件。这些资源文件最终都由Buildoot整合为文件系统。Buildroot中包含由MYIR提供的预存文件和由Buildroot编译生成的文件。

&emsp;&emsp;由MYIR提供的文件放在`myir-buildroot/board/myir/common/HMI2.0`目录下面。
```
├── etc
│   ├── modules-load.myir
│   │   └── postboot
│   ├── network
│   │   └── interfaces
│   └── qt_env.sh
├── home
│   └── myir
│       └── mxapp2
└── usr
    ├── lib
    │   └── fonts
    │       └── msyh.ttc
    └── share
        └── myir
            ├── Capture
            │   ├── image1.png
            │   ├── image2.png
            │   ├── image3.png
            │   ├── image4.jpg
            │   ├── image5.jpg
            │   └── image6.jpg
            ├── ecg.dat
            ├── Music
            │   ├── Ascended Vibrations.mp3
            │   ├── Born a Stranger.mp3
            │   ├── John Dreamer - Rise - Epic Music.mp3
            │   └── Nuvole Bianche.mp3
            ├── resp.text
            └── Video
                ├── HistoryOfTIAV-480p.mp4
                ├── HistoryOfTIAV-WQVGA.mp4
                └── HistoryOfTIAV-WVGA.mp4

```
&emsp;&emsp;以上这些文件都会buildroot在编译过程中执行`myir-buildroot/board/myir/myd_c335x_gw/post-build.sh`脚本拷贝至目标文件系统。
```
...
if grep -Eq "^BR2_PACKAGE_MEASY_HMI2.0=y$" ${BR2_CONFIG}; then
    echo "\"include measy_hmi\""
	cp -a board/myir/common/HMI2/*  output/target
else
    echo "\" not include measy_hmi2.0\""
fi
...
```

&emsp;&emsp;由buildroot生成的文件都在myd_c335x_gw_hmi2.0_defconfig里面被配置，编译结束后输入到`myir-buildroot/output/target`目录。最终由buildroot根据配置生成各种文件系统位于`myir-buildroot/output/images`目录。

&emsp;&emsp;在buildroot目录执行下面两行命令即可完成目标板运行MEasy HMI 2.0文件系统的编译。
```
make myd_c335x_gw_hmi2.0_defconfig
make
```

&emsp;&emsp;第一次编译比较耗时间，编译完成后参考MYD-C335X-GW Linux 4.14.67开发手册.pdf的第6章烧写将文件系统烧写到开发板。





