# Android应用框架

[创建项目](#创建项目)

[项目结构](#项目结构)

### 创建项目

[Android Developers](#https://developer.android.google.cn/?hl=zh-cn)

1. 在Android Developers官网中可以下载Android Studio、查看Kotlin文档和API文档等。
2. Android Studio(API Level 34)安装完成后，选择新建Empty Activity项目，语言为Kotlin（新版本好像更推荐Kotlin，所以就不支持Java了，但是Kotlin里依然能够使用Java）。
3. 第一次构建Kotlin/Java项目时要下载很多依赖，可能会很慢。
4. 构建完成后打开Device Manager，点击运行模拟器（应该会自带一个），手机模拟器启动后就可以运行项目了。
5. Android Studio左侧文件目录可以切换查看的文件类型，可以在“项目”里查看全部文件，也可以在“Android”里查看主要文件。也可以只查看源文件/非源文件/测试文件等。

### 项目结构

1. 在Empty Activity项目目录中，可以看到以下主要文件。

|**文件**|**作用**|
|-|-|
|app/|存放主要文件，包括源代码和资源|
|app/build/|编译和构建过程中自动生成的目录。用于存放构建过程中产生的各种文件，包括编译后的代码、资源文件、中间产物、最终生成的APK或AAB文件等|
|app/lib/|用于存放可能的第三方库、本地库等|
|app/src/main/java/|包含应用的源代码文件。它通常按包名组织，里面包含了Activity、服务等组件的实现代码。MainActivity.kt：这是一个默认的Activity类，是应用启动时用户首先看到的界面。在Empty Activity模板中，这是唯一的一个Activity。|
|app/src/main/res/|包含了所有的资源文件，如布局（layout）、字符串（strings）、图像（drawables）等。drawable：存放应用使用的图片资源。mipmap：存放应用图标的地方，不同的文件夹（如mipmap-hdpi, mipmap-mdpi等）代表不同的分辨率，以适应不同的设备屏幕。values：colors.xml：定义了应用中使用的颜色值。strings.xml：定义了应用中使用的所有字符串资源，便于本地化和修改。styles.xml：定义了应用中使用的样式和主题。|
|app/src/main/androidTest/|用于存放Instrumented测试代码。Instrumented测试是在真实设备或模拟器上执行的测试，它可以与应用程序的组件（如Activity、Service、Fragment等）进行交互。通常，这些测试用例会访问真实的Android框架和设备功能，以验证应用在实际设备上的行为是否符合预期。|
|app/src/main/test/|用于存放本地单元测试代码。本地单元测试是在本地JVM上运行的测试，它主要用于验证应用程序中较小的、独立的代码单元（如方法、类）的行为是否符合预期，而不涉及Android框架和设备功能。|
|app/src/build.gradle.kts|模块级别的Gradle构建文件，用于配置应用模块的构建参数，如应用的最小支持Android版本、依赖库等|
|build.gradle.kts|项目级别的Gradle构建文件，用于配置整个项目的构建参数，比如包含的模块、Gradle插件版本等|
|settings.gradle.kts|项目设置文件，包含项目名称等|
|.gradle/|缓存、进程信息、输出日志等|
|gradle/|构建、编译和打包工具|
|.gitignore|用于指定在版本控制系统（如Git）中哪些文件或目录应该被忽略、不加入到版本库中的文本文件|