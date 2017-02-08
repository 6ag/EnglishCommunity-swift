# 自学英语社区

使用 `swift3.0` 编写的一个英语学习社区app，后台采用牛逼的PHP框架 `laravel 5.2` 开发。

## 相关连接

- APP仓库 [EnglishCommunity-swift](https://github.com/6ag/EnglishCommunity-swift)
- 后台仓库 [EnglishCommunity-laravel](https://github.com/6ag/EnglishCommunity-laravel) 
- API接口文档 [apidoc](http://english.6ag.cn/apidoc/) 

## AppStore

<a target='_blank' href='https://itunes.apple.com/app/id1146271758'>
<img src='http://ww2.sinaimg.cn/large/0060lm7Tgw1f1hgrs1ebwj308102q0sp.jpg' width='144' height='49' />
</a>

## 开发环境

- swift3.0
- Xcode8.2.1
- cocoapods 1.1.0.beta.2
- mac os 10.12.2

## 如何使用

- 拷贝项目到本地，【翻墙后】在项目根目录执行 `pod install` 安装项目依赖库。
- 本app使用  `ijkplayer` 封装的 `JFPlayer` 或 `BMPlayer`，如果使用 `BMPlayer` 需要自己删除 `JFPlayer` ，反之亦然。
-  （默认是这个）如果使用 `BMPlayer` 则无需导入 `JFPlayer` ，只需要把下载下来的 `BMPlayer` 文件夹里的文件导入项目即可。
- 如果要使用 `JFPlayer` ，则需要导入 `JFPlayer` 目录到项目中，并替换 `JFPlayerViewController.swift` 文件。百度网盘: [百度网盘](https://pan.baidu.com/s/1o84Klz8) 提取密码: `svcf` 。
## 提醒

- 为什么要翻墙？`Podfile` 文件中 `pod 'Firebase/AdMob'` 这个依赖包是 `admob` 广告SDK，需要翻墙才能安装。如果没有翻墙工具，请移除这个包和相关代码（没几行的）。
- `ijkplayer` 播放本地 `m3u8` 流媒体视频会出现缓冲计算不精确的bug，应该是本地服务器的问题，系统自带的 `AVPlayer` 则不存在这个问题。

## 效果预览

### 首页

![image](https://github.com/6ag/EnglishCommunity-swift/blob/master/Show/home.PNG)

### 发布动态、支持多图、表情键盘、@人

![image](https://github.com/6ag/EnglishCommunity-swift/blob/master/Show/publish.PNG)

### 动态模块，自适应cell高度、支持多图、图片模态放大浏览

![image](https://github.com/6ag/EnglishCommunity-swift/blob/master/Show/tweet.PNG)

### 个人中心 常规的，高钙的

![image](https://github.com/6ag/EnglishCommunity-swift/blob/master/Show/profile.PNG)

### 设置、使用继承架构实现

![image](https://github.com/6ag/EnglishCommunity-swift/blob/master/Show/setting.PNG)

### 7个分类，布局一样的

![image](https://github.com/6ag/EnglishCommunity-swift/blob/master/Show/category.PNG)

### 播放列表，支持本地缓存，离线学习

![image](https://github.com/6ag/EnglishCommunity-swift/blob/master/Show/playlist.PNG)

### 视频下载

![image](https://github.com/6ag/EnglishCommunity-swift/blob/master/Show/download.PNG)

### 全屏播放，限制屏幕旋转

![image](https://github.com/6ag/EnglishCommunity-swift/blob/master/Show/fullscreen.PNG)

## 许可

[MIT](http://opensource.org/licenses/MIT) © [六阿哥](https://github.com/6ag)


