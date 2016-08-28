# 自学英语社区

使用 `swift2.2` 编写的一个英语学习社区app，后台采用牛逼的PHP框架 `laravel 5.2` 开发。

## 相关连接

- 后台仓库地址 [EnglishCommunity-laravel](https://github.com/6ag/EnglishCommunity-laravel) 
- API接口文档 [apidoc](http://english.6ag.cn/apidoc/) 

## 如何使用

- 拷贝项目到本地，并在项目根目录执行 `pod install` 安装项目依赖库。
- 由于 `ShareSDK` 和 `JPush` 实在是太大了，如果需要请自行下载并导入项目，否则请删除相关代码即可。 
- 还由于项目使用了 `ijkplayer` 框架，这个框架也太大了，如果需要使用这个播放器请自行下载 `IJKMediaFramework.framework` 并引入项目中。
- 框架仓库： [ijkplayer](https://github.com/Bilibili/ijkplayer)。已经打包好的 `framework` 网盘下载地址: [百度网盘](https://pan.baidu.com/s/1jInVYke) 提取密码: `2uam`
- 后台和app我花了快一个月的业余时间开发，目前还有些bug，求一起搞基一起改bug。

## 效果预览

### 首页 tableView 嵌套 collectionView

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

### 播放列表，封装B站开源框架ijkplayer

![image](https://github.com/6ag/EnglishCommunity-swift/blob/master/Show/playlist.PNG)

### 视频下载 目前还没实现，视频不是我的。。

![image](https://github.com/6ag/EnglishCommunity-swift/blob/master/Show/download.PNG)

### 全屏播放，限制屏幕旋转

![image](https://github.com/6ag/EnglishCommunity-swift/blob/master/Show/fullscreen.PNG)

## 许可

[MIT](http://opensource.org/licenses/MIT) © [六阿哥](https://github.com/6ag)


