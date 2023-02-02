# 安装依赖包

> 由于Tesseract-ocr依赖一些包，而Linux上默认没有，因此需要先使用以下命令来安装依赖包

```sh
yum install autoconf automake libtool libjpeg-devel libpng-devel libtiff-devel zlib-devel gcc gcc-c++
```

# 安装Ieptonica

> 因为 Tesseract 必须使用 Leptonica 库 来打开输入图像（例如不是像 pdf 这样的文档）。所以我们需要下载，安装，使用内置支持zlib、 png和 tiff（用于多页 tiff）的 leptonica。

下载压缩包

```sh
http://www.leptonica.org/source/leptonica-1.83.0.tar.gz
```

解压

```sh
tar -zxvf leptonica-1.83.0.tar.gz
```

进入解压后的文件夹

```sh
cd leptonica-1.83.0
```

顺序执行以下命令来进行编译、安装

```sh
./autogen.sh
./configure
make
make install
```

为Ieptonica配置环境变量

```sh
vim /etc/profile
```

在结尾插入以下内容

```sh
export LD_LIBRARY_PATH=/usr/local/lib
export LIBLEPT_HEADERSDIR=/usr/local/include
export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig
```

退出并保存，按下`ESC`键，输入`:wq`，按下`Enter`键确认

刷新配置

```sh
source /etc/profile
```

# 安装Tesseract-OCR

下载压缩包

```sh
https://github.com/tesseract-ocr/tesseract/archive/refs/tags/5.2.0.tar.gz
```

解压

```sh
tar -zxvf 5.3.0.tar.gz
```

进入解压后的文件夹

```sh
cd tesseract-5.3.0
```

顺序执行以下命令来进行编译、安装

```sh
./autogen.sh
./configure
make
make install
```

# 测试使用

运行命以下令，格式: `tesseract` `图片完整路径` `输出文件路径` `-l` `语言`

```sh
tesseract /root/1.png /root/result -l eng
```

# 添加语言包支持

用Xftp打开语言包存放路径`/usr/local/share/tessdata`，将训练好的文件放入其中即可

官方提供的训练文件下载地址：`https://github.com/tesseract-ocr/tessdata`

# 训练自己的字库(windows下)

> 由于训练用的工具是用java开发，所以要事先安装好Java运行环境，另外，训练时为了方便，建议在window进行。
> 
> window安装tesseract-ocr，只需要下载exe`https://digi.bib.uni-mannheim.de/tesseract/`，无脑安装。
> 
> 为了方便，需要配置环境变量，新增变量，名称`tesseract`，值`D:\Tesseract-OCR\tesseract`；修改变量，名称`path`，新增值为`D:\Tesseract-OCR`，其中`D:\Tesseract-OCR`为安装路径

1. 下载jTessBoxEditor，链接`https://sourceforge.net/projects/vietocr/files/jTessBoxEditor/`，完成后解压
2. 准备一个文件夹，存放n张用于训练的图片素材，同时将写好的bat脚本文件放入该文件夹内
3. 打开解压的文件夹，双击运行train.bat文件来打开JTessBoxEditor，点击`Tools`，`Ctrl + M`，找到第2步准备的文件夹，将文件类型改为`All Image Files`，再使用`Ctrl`键全选图片，点击`打开`，随便取一个名字，最后点击`保存`，便会在文件夹内生成一个后缀为tif的文件
4. 打开第2步准备的文件夹，编辑bat脚本文件，将`name`、`font`和`lang`这三个值修改，并将其按照格式拼接成一个文件名，用这个文件名把第3步中后缀为tif的文件重命名。
5. 双击运行bat脚本，生成一个后缀为box的文件
6. 打开jTessBoxEditor，点击`Box Editor`，点击`Open`，找到第5步中后缀名为box的文件，手动调整每一页的每一个字符的`Word`、`X`、`Y`、`W`、`H`，最后点击`Save`，然后就可以关闭jTessBoxEditor
7. 再次双击运行bat脚本，即可生成后缀名为trainieddata的文件

**附件：bat脚本内容**

```batchfile
@echo *********************************************
@echo 欢迎使用训练脚本
@echo *********************************************
@pause

@set name=chi_my
@set font=font

: :	中文写chi_sim， 英文或数字填eng
@set lang=chi_sim

:: 	tif的名字
:: 	chi_my.font.exp0.tif

@if not exist %name%.%font%.exp0.box ( goto LABLE_MAKEBOX ) else ( goto LABLE_TRIAN )


:LABLE_MAKEBOX
@echo ==========第1步开始==========
tesseract %name%.%font%.exp0.tif %name%.%font%.exp0 -l %lang% --psm 7 batch.nochop makebox
@echo ==========第1步结束==========
exit


:LABLE_TRIAN
@if exist *.traineddata ( del.\*.traineddata /f /s /q /a )

@echo ==========第2步开始==========
echo "%font% 0 0 0 0 0"> %font%_properties
@echo ==========第2步结束==========

@echo ==========第3步开始==========
tesseract %name%.%font%.exp0.tif %name%.%font%.exp0 nobatch box.train
@echo ==========第3步结束==========

@echo ==========第4步开始==========
unicharset_extractor %name%.%font%.exp0.box
@echo ==========第4步结束==========

@echo ==========第5步开始==========
mftraining -F font_properties -U unicharset -O %name%.unicharset %name%.%font%.exp0.tr
@echo ==========第5步结束==========


@echo ==========第6步开始==========
cntraining %name%.%font%.exp0.tr
@echo ==========第6步开始==========

@echo ==========第7步开始==========
@rename normproto   %name%.normproto
@rename inttemp     %name%.inttemp
@rename pffmtable   %name%.pffmtable
@rename shapetable  %name%.shapetable
@echo ==========第7步结束==========

@echo ==========第8步开始==========
combine_tessdata %name%.
@echo ==========第8步结束==========

@echo ==========第9步开始==========
del .\*.tr /f /s /q /a
del .\*.normproto /f /s /q /a
del .\*.inttemp /f /s /q /a
del .\*.pffmtable /f /s /q /a
del .\*.unicharset /f /s /q /a
del .\*.shapetable /f /s /q /a
del .\font_properties /f /s /q /a
del .\unicharset /f /s /q /a
@echo ==========第9步结束==========
```

# SpringBoot + Tesseract-OCR实现图片文字识别

1. 导入Maven坐标
   ```java
   <!-- https://mvnrepository.com/artifact/net.sourceforge.tess4j/tess4j -->
   <dependency>
       <groupId>net.sourceforge.tess4j</groupId>
       <artifactId>tess4j</artifactId>
       <version>5.6.0</version>
   </dependency>
   ```

2. 在Service层编写代码
   ```java
   try {
       //获取本地图片
       File file = new File("D:\\test.png");
       //创建Tesseract对象
       ITesseract tesseract = new Tesseract();
       //设置字体库路径
       tesseract.setDatapath("D:\\workspace\\tessdata");
       //设置使用的语言名称(后缀为trainieddata的文件的名称)
       tesseract.setLanguage("chi_sim");
       //执行ocr识别
       String result = tesseract.doOCR(file);
       //自定义字符串结果处理
       result = result.replaceAll("\\r|\\n","-").replaceAll(" ","");
       System.out.println("识别的结果为："+result);
       } catch (Exception e) {
       e.printStackTrace();
   }
   ```
