# GNS3 安装指南

## 操作系统
window 10

## 使用的软件及版本
1. GNS3 version 2.2.0。 推荐从[官方网站](https://www.gns3.com/software)下载.
2. GNS3 VM 2.2.0。 推荐从[官方网站](https://www.gns3.com/software/download-vm)下载. 
后面会使用VMware player来跑这个GNS3 VM，所以需要下载"VMware Workstation and Fusion"版本的。

![picture](https://github.com/nokia-t1zhou/segment-routing-step-by-step/blob/master/GNS3%E5%AE%89%E8%A3%85/GNS3%20VM.png)

3. VMware player 12
4. VMware-VIX 1.15.0

因为最新的免费的VMWare VIX只能支持到VMWare player 12， 所以我们只用12这个版本，等以后VIX有新版本了，对于的player也可以用新的。
注意： 如果你的电脑是AMD CPU，那么请安装GNS3 2.3.0，GNS3 VM 2.3.0 （参考https://github.com/GNS3/gns3-vm/issues/130）

## 1 安装VMware player 12
没有特别的步骤，一路next到底。

## 2 安装VMware-VIX 1.15.0
没有特别的步骤，一路next到底。

## 3 安装GNS3
没有特别的步骤，一路next到底。

## 4 设置GNS3 VM
请先下载好GNS3 VM，这是一个后缀名是ova的image。

### 启动VMWare player，选择“打开虚拟机”

![none](https://github.com/nokia-t1zhou/segment-routing-step-by-step/blob/master/GNS3%E5%AE%89%E8%A3%85/wmplayer1.png)

### 为虚拟机命名“GNS3 VM”

![none](https://github.com/nokia-t1zhou/segment-routing-step-by-step/blob/master/GNS3%E5%AE%89%E8%A3%85/wmplayer2.png)

### 导入完成后，做一些必要的配置
需要注意： 
- 内存尽可能多分配，我这里给了6G；
- 处理器选项页中的“虚拟化Inter VT-x/EPT 或AMD-V/RVI(V)"必须选上，这个选项允许GNS3 VM支持KVM。
- 配置2个网络，一个设置为”仅主机模式“，另一个为”NAT”模式。

![none](https://github.com/nokia-t1zhou/segment-routing-step-by-step/blob/master/GNS3%E5%AE%89%E8%A3%85/wmplayer3.png)

![none](https://github.com/nokia-t1zhou/segment-routing-step-by-step/blob/master/GNS3%E5%AE%89%E8%A3%85/wmplayer4.png)

## 启动GNS3 VM
可以看到如下图所示，GNS3 VM已经运行

![none](https://github.com/nokia-t1zhou/segment-routing-step-by-step/blob/master/GNS3%E5%AE%89%E8%A3%85/wmplayer5.png)

从上图看出，GNS3 VM使用的IP地址是192.168.142.128.

查看电脑的网络，可以看到VM player创建的网络接口分配的网段是192.168.142.0/24。

![none](https://github.com/nokia-t1zhou/segment-routing-step-by-step/blob/master/GNS3%E5%AE%89%E8%A3%85/wmplayer6.png)

## 配置GNS3
上面的步骤已经配置好了GNS3 VM， 下面我们开始让GNS3连接上VM中的GNS3 server。

（注意：在这一步前，请先关闭GNS3 VM）第一次打开GNS3，会自动跳出setup向导，也可以以后在菜单中找到。

![none](https://github.com/nokia-t1zhou/segment-routing-step-by-step/blob/master/GNS3%E5%AE%89%E8%A3%85/GNS3-1.jpg)

按照下命的步骤来配置GNS3：

![none](https://github.com/nokia-t1zhou/segment-routing-step-by-step/blob/master/GNS3%E5%AE%89%E8%A3%85/GNS3-2.png)

下图中IP地址选择VMWare player的IP地址（上面步骤中已经从电脑中查出）

![none](https://github.com/nokia-t1zhou/segment-routing-step-by-step/blob/master/GNS3%E5%AE%89%E8%A3%85/GNS3-3.png)

这一步后，GNS3会调用VMWare player来启动GNS3 VM。

选择VMWare为虚拟机的软件，等待一会，直到下拉框中出现刚才配置的GNS3 VM的名字

![none](https://github.com/nokia-t1zhou/segment-routing-step-by-step/blob/master/GNS3%E5%AE%89%E8%A3%85/GNS3-4.png)

![none](https://github.com/nokia-t1zhou/segment-routing-step-by-step/blob/master/GNS3%E5%AE%89%E8%A3%85/GNS3-5.png)

如果没有error弹框，恭喜你，GNS3已经配置完毕，下面就可以使用了！