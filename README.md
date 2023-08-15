# localizationshell
这个shell脚本主要为是了解决iOS项目中多语言内容设置机械重复的问题，在此之前基本上是开发者根据运营或者产品给的excel文件，手动一个一个内容复制到多语言的.strings文件中。也曾尝试找一些开源工具，但都没有找到一个合适的。借着之前有用过shell编写[iOS打包脚本](https://github.com/lbininhbl/AutoPackageScript)的经验，基于shell写一个工具，来解放开发者的生产力。

## 一些约定

虽然能很大程度上解决生产力的问题，但shell脚本还是有其自身的局限性，不像cocoapods，fastlane等一些ruby或者其他一些python编写的工具，所以在使用这个脚本的时候需要你做一些约定的东西。

1. 首先假定你是有 shell 的基础知识，因为要适合各个不同的项目，或者你自定义的一些内容，可能需要你在这个脚本中做一点修改；

2. 该脚本依赖一个开源工具[xlsx2csv](https://github.com/dilshod/xlsx2csv)，是将excel表格转换成csv文件的，所以使用之前，请先安装这个工具；

3. 假设你的项目结构大概是这样子的

   ```
   Project_dir
   ├── ......
   ├── shell dir(这里是存放这个shell的文件夹)
   ├── your project name.xcodeproj
   └── your project name
       └── Localzation 
         ├── en.lproj
         ├── zh-Hans.lproj
         ├── ......
         └── ar.lproj
           ├── a.strings
           ├── b.strings
           ├── ....
           └── xxx.strings
   ```

4. 假设你的excel表格是如下格式

   | key(.strings文件中的key) | 标题(文案对应位置) | en   | zh-Hans | ja   | ko   | ...  | ar   |
   | ------------------------ | ------------------ | ---- | ------- | ---- | ---- | ---- | ---- |
   | key1                     | 图标               | xx   | xx      | xx   | xx   | xx   | xx   |
   | key2                     | 按钮               | xx   | xx      | xx   | xx   | xx   | xx   |
   | key3                     | 标题               | xx   | xx      | xx   | xx   | xx   | xx   |
   | key4                     | 副标题             | xx   | xx      | xx   | xx   | xx   | xx   |

5. 由于可能存在多个excel对应有多个.strings文件，所以对文件名也要和shell脚本里的对应，你可以自行定义规则，然后改写"配置相关"一栏里的配置；

6. excel内容中原则上建议一行一个文案，如果一个位置的文案一定要用到换行，则建议和编写excel的人员协定好，建议直接使用"\n"，或者使用其他符号替换换行，然后在shell脚本中`NEWLINE=xxx`一行改成你想要的符号，这里默认是`#@@#`。



## 使用

```shell
$ ./localization.sh
```

如果提示没有权限，则先使用 `chmod` 修改一下权限。

## 示例

在 `Demo` 目录下，有简单的demo展示。首先打开终端 `cd` 到 `Demo/Demo/shell` 目录，然后执行 `./localization.sh` 回车。或者直接把脚本文件拖到终端上回车，则可以查看效果，具体在 `Demo/Demo/Demo/Localization` 目录下。

## 常见问题

1. 安装了xlsx2csv还提示 `command not found`

   如果的是 `bash`，你需要把 `PATH="$PATH:$(python3 -m site --user-base)/bin"` 这行配置添加到你的 `.bash_profile` 文件中
如果是 `zsh`，则相应的配置在 `.zshrc` 中

   如果是 Intel 芯片的机器，则把路径设置为 `PATH="/Library/Frameworks/Python.framework/Versions/3.9/bin:${PATH}"` , 其中按你系统中所安装的 python 版本来进行修改.

## 最后

虽然上面提到一些约定，当然如果你也有shell的经验，完全可以自己在这上面做修改，以达到符合你的业务需求。或者，你有比这个更好的工具，请分享给我，谢谢啦~

