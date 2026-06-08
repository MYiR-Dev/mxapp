cmake_minimum_required(VERSION 3.16)

project(mxapp2 LANGUAGES CXX)

# =========================================================
# C++ 标准（Qt6 建议 C++17）
# =========================================================
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# =========================================================
# Qt 自动处理
# =========================================================
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

# =========================================================
# 查找 Qt6 模块
# =========================================================
find_package(Qt6 REQUIRED COMPONENTS
    Core
    Gui
    Widgets
    Quick
    Qml
    QuickControls2
    Multimedia
    MultimediaWidgets
    Network
    PrintSupport
    Svg
    Test
    LinguistTools
)

# Qt6 标准工程设置
qt_standard_project_setup()

# =========================================================
# 编译宏
# =========================================================
add_compile_definitions(
    QT_DEPRECATED_WARNINGS
    QT_QCAMERA_V4L2
)

# Qt6 推荐：启用更严格的警告
if(CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
    add_compile_options(
        -Wall
        -Wextra
        -Wpedantic
    )
endif()

# =========================================================
# 源文件
# =========================================================
set(SOURCES
    Charge104.cpp
    ChargeManage.cpp
    ClearCache.cpp
    abstractcamera.cpp
    camera_qthread.cpp
    cameraimageprovider.cpp
    iec104_class.cpp
    logmsg.cpp
    main.cpp
    mediapipeline.cpp
    multicamera.cpp

    qcustomplot.cpp
    qiec104.cpp
    qmlplot.cpp
    common.cpp
    myfunction.cpp
    qmlprocess.cpp
    translator.cpp
)

# =========================================================
# 头文件
# =========================================================
set(HEADERS
    Charge104.h
    ChargeManage.h
    ClearCache.h
    abstractcamera.h
    camera_data.h
    camera_qthread.h
    cameraimageprovider.h
    iec104_class.h
    iec104_types.h
    logmsg.h
    mediapipeline.h
    multicamera.h

    qcustomplot.h
    qiec104.h
    qmlplot.h
    common.h
    myfunction.h
    qmlprocess.h
    translator.h
)

# =========================================================
# Qt Resource
# =========================================================
set(RESOURCES
    qml.qrc
)

# =========================================================
# 翻译文件
# =========================================================
set(TS_FILES
    languages/language_zh.ts
    languages/language_en.ts
)

# =========================================================
# 创建可执行程序
# =========================================================
qt_add_executable(${PROJECT_NAME}
    MANUAL_FINALIZATION
    ${SOURCES}
    ${HEADERS}
    ${RESOURCES}
)

# =========================================================
# Qt 翻译支持
# =========================================================
qt_add_translations(${PROJECT_NAME}
    TS_FILES ${TS_FILES}
)

# =========================================================
# include 目录
# =========================================================
target_include_directories(${PROJECT_NAME} PRIVATE
    .
)

# =========================================================
# 链接 Qt 库
# =========================================================
target_link_libraries(${PROJECT_NAME} PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Widgets
    Qt6::Quick
    Qt6::Qml
    Qt6::QuickControls2
    Qt6::Multimedia
    Qt6::MultimediaWidgets
    Qt6::Network
    Qt6::PrintSupport
    Qt6::Svg
    Qt6::Test
)

# =========================================================
# QML 导入路径设置
# =========================================================
set_target_properties(${PROJECT_NAME} PROPERTIES
    QML_IMPORT_PATH "${CMAKE_CURRENT_SOURCE_DIR}"
    QML2_IMPORT_PATH "${CMAKE_CURRENT_SOURCE_DIR}"
)

# =========================================================
# Linux 安装路径
# =========================================================
install(TARGETS ${PROJECT_NAME}
    RUNTIME DESTINATION bin
)

# =========================================================
# 静态编译支持
# =========================================================
if(NOT BUILD_SHARED_LIBS)

    target_compile_definitions(${PROJECT_NAME} PRIVATE
        QT_STATICPLUGIN
    )

    # 对应 qmake:
    # QTPLUGIN += qtvirtualkeyboardplugin
    qt_import_plugins(${PROJECT_NAME}
        INCLUDE Qt6::QVirtualKeyboardPlugin
    )

endif()

# =========================================================
# Qt6 Finalize
# =========================================================
qt_finalize_executable(${PROJECT_NAME})