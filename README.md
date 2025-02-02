# Docker - 115浏览器Linux版_v35.3.0.2
![预览图](https://github.com/kin-w/115-Liunx/blob/main/image.jpg)

## 拉取镜像
```bash
docker pull ikimi/115-linux:latest
```
## Docker-Compose.yaml
```yaml
version: '3.8'  # 指定 Docker Compose 文件的版本

services: # 定义服务
  115-Linux:  # 服务名称
    image: ikimi/115-linux:latest  # latest
    container_name: 115-Linux
    user: "0:0"  # 以 root 用户身份运行
    volumes:
      - '/:/opt/Downloads' #上传/下载目录
      # - './115:/etc/115' #数据目录
    ports:
      - '1150:1150'  # WEB访问端口后加/vnc.html即VNC访问
      # - '1152:1152'
    environment:  # 环境变量
      - PASSWORD=0  # VNC密码(必须项)
      - DISPLAY_WIDTH=1440  # 显示宽度
      - DISPLAY_HEIGHT=720  # 显示高度
      - TZ=Asia/Shanghai  # 时区
      # 添加Cookie（非必要，可删）
      - CID=
      - KID=
      - SEID=
      - UID=
```
## Web访问
通过以下链接访问 115 浏览器的 Web 界面：
[http://localhost:1150/vnc.html](http://localhost:1150/vnc.html)
|名称|描述|
|:---------:|:---------:|
|`localhost`|设备的地址|
|`1150`|设置的端口|
|`/vnc.html`|VNC页面访问|

## 环境变量

|名称|描述|必须|
|:---------:|:---------:|:---------:|
|PASSWORD|VNC密码|◯|
|DISPLAY_WIDTH|窗口宽度|╳|
|DISPLAY_HEIGHT|窗口高度|╳|
|TZ|时区|╳|
|CID|Cookie|╳|
|SEID|Cookie|╳|
|UID|Cookie|╳|
|KID|Cookie|╳|

## 挂载目录

|路径|描述|必须|
|:---------:|:---------:|:---------:|
|/etc/115|115浏览器数据目录|╳|
|/opt/Downloads|上传/下载目录|╳|

## 端口占用
|端口|描述|必须|
|:---------:|:---------:|:---------:|
|1150|WEB端口|◯|
|1152|VNC端口|╳|

