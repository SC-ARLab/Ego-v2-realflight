<font size=6> **真机复现MINCO版Ego-planner** </font>

本文档是基于[ZJU-FAST-Lab](https://github.com/ZJU-FAST-Lab)的开源项目[Fast-Drone-250](https://github.com/ZJU-FAST-Lab/Fast-Drone-250),视频教程[从零制作自主空中机器人](https://www.bilibili.com/video/BV1WZ4y167me?p=1)

整体流程参考上述链接，本项目只涉及无人机起飞流程



## 飞控设置与试飞

* 烧录本git项目下的`/firmware/px4_fmu-v5_default.px4`固件

* 在飞控的sd卡的根目录下创建`/etc/extras.txt`，写入

  ```
  mavlink stream -d /dev/ttyACM0 -s ATTITUDE_QUATERNION -r 200
  mavlink stream -d /dev/ttyACM0 -s HIGHRES_IMU -r 200
  ```
  
  以提高imu发布频率
  
* 修改机架类型为 `Generic 250 Racer`，代指250mm轴距机型。如果是其他尺寸的机架，请根据实际轴距选择机架类型

* 修改`dshot_config`为dshot600

* 修改`CBRK_SUPPLY_CHK`为894281 *执行这步跳过了电源检查，因此左侧栏的电池设置部分就算是红的也没关系*

* 修改`CBRK_USB_CHK`为197848

* 修改`CBRK_IO_SAFETY`为22027

* 修改`SER_TEL1_BAUD`为921600

* 修改`SYS_USE_IO`为0（搜索不到则不用管）

* <font color="#dd0000">检测电机转向前确保没有安装螺旋桨！！！！</font>

* 修改电机转向：进入mavlink控制台

  ```
  dshot reverse -m 1
  dshot save -m 1
  ```

  修改`1`为需要反向的电机序号

## Ubuntu20.04的安装

* 镜像站地址：`http://mirrors.aliyun.com/ubuntu-releases/20.04/` 下载 `ubuntu-20.04.4-desktop-amd64.iso`
* 烧录软件UltraISO官网：`https://cn.ultraiso.net/`
* 分区设置：
  * EFI系统分区（主分区）512M
  * 交换空间（逻辑分区）16000M（内存大小的两倍）
  * 挂载点`/`（主分区）剩余所有容量
  * <font color="#dd0000">笔记本上也需要安装ubuntu，推荐装20.04版本。虚拟机或双系统都可以，如果有长期学习打算推荐双系统</font>
## 机载电脑的环境配置

* ROS安装
  * 建议自行安装，也可以使用[一键安装](https://fishros.org.cn/forum/topic/20/%E5%B0%8F%E9%B1%BC%E7%9A%84%E4%B8%80%E9%94%AE%E5%AE%89%E8%A3%85%E7%B3%BB%E5%88%97?lang=en-US)
  
* 测试ROS
  * 打开三个终端，分别输入
  * `roscore`
  * `rosrun turtlesim turtlesim_node`
  * `rosrun turtlesim turtle_teleop_key`
  
* realsense驱动安装
  * `sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-key  F6E65AC044F831AC80A06380C8B3A55A6F3EFCDE || sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-key  F6E65AC044F831AC80A06380C8B3A55A6F3EFCDE`
  * `sudo add-apt-repository "deb https://librealsense.intel.com/Debian/apt-repo $(lsb_release -cs) main" -u`
  * `sudo apt-get install librealsense2-dkms`
  * `sudo apt-get install librealsense2-utils`
  * `sudo apt-get install librealsense2-dev`
  * `sudo apt-get install librealsense2-dbg`
  * 测试：`realsense-viewer`
  * <font color="#dd0000">注意测试时左上角显示的USB必须是3.x，如果是2.x，可能是USB线是2.0的，或者插在了2.0的USB口上（3.0的线和口都是蓝色的）</font>
  
* 安装mavros
  * `sudo apt-get install ros-noetic-mavros`
  * `cd /opt/ros/noetic/lib/mavros`
  * `sudo ./install_geographiclib_datasets.sh`
  
* 安装ceres与glog与ddyanmic-reconfigure
  * 解压`3rd_party.zip`压缩包
  * 进入glog文件夹打开终端
  * `./autogen.sh && ./configure && make && sudo make install`
  * `sudo apt-get install liblapack-dev libsuitesparse-dev libcxsparse3 libgflags-dev libgoogle-glog-dev libgtest-dev`
  * 进入ceres文件夹打开终端
  * `mkdir build`
  * `cd build`
  * `cmake ..`
  * `sudo make -j4`
  * `sudo make install`
  * `sudo apt-get install ros-noetic-ddynamic-reconfigure`
  
* 下载ego-planner源码并编译
  * `git clone https://github.com/SC-ARLab/Ego-v2-realflight`
  
  * `cd Ego-v2-realflight`
  
  * `catkin_make`
  
  * `source devel/setup.bash`
  
  * `roslaunch ego_planner rviz.launch`
  
    新窗口启动：`source devel/setup.bash` 
  
    ​			  		 `roslaunch ego_planner single_drone_interactive.launch  ` 
  
  * 在Rviz内按下键盘G键，再单击鼠标左键以点选无人机目标点

## VINS的参数设置与外参标定
* 检查飞控mavros连接正常
  * `ls /dev/tty*`，确认飞控的串口连接正常。一般是`/dev/ttyACM0`
  * `sudo chmod 777 /dev/ttyACM0`，为串口附加权限
  * `roslaunch mavros px4.launch`
  * `rostopic hz /mavros/imu/data_raw`，确认飞控传输的imu频率在200hz左右
* 检查realsense驱动正常
  * `roslaunch realsense2_camera rs_camera.launch`
  * 进入远程桌面，`rqt_image_view`
  * 查看`/camera/infra1/image_rect_raw`,`/camera/infra2/image_rect_raw`,`/camera/depth/image_rect_raw`话题正常
* VINS参数设置
  * 进入`realflight_modules/VINS_Fusion/config/`
  
  * 驱动realsense后，`rostopic echo /camera/infra1/camera_info`，把其中的K矩阵中的fx,fy,cx,cy填入`left.yaml`和`right.yaml`
  
  * 在home目录创建`vins_output`文件夹(如果你的用户名不是fast-drone，需要修改config内的vins_out_path为你实际创建的文件夹的绝对路径)
  
  * 修改`fast-drone-250.yaml`的`body_T_cam0`和`body_T_cam1`的`data`矩阵的第四列为你的无人机上的相机相对于飞控的实际外参，单位为米，顺序为x/y/z，第四项是1，不用改
* VINS外参精确自标定
  * `sh shfiles/rspx4.sh`
  * `rostopic echo /vins_fusion/imu_propagate`
  * 拿起飞机沿着场地<font color="#dd0000">尽量缓慢</font>地行走，场地内光照变化不要太大，灯光不要太暗，<font color="#dd0000">不要使用会频闪的光源</font>，尽量多放些杂物来增加VINS用于匹配的特征点
  * 把`vins_output/extrinsic_parameter.txt`里的内容替换到`fast-drone-250.yaml`的`body_T_cam0`和`body_T_cam1`
  * 重复上述操作直到走几圈后VINS的里程计数据偏差收敛到满意值（一般在0.3米内）
* 建图模块验证
  * `sh shfiles/rspx4.sh`
  * `sh shfiles/ego.sh`

## Ego-Planner-v2的实验
* 自动起飞：

  * `sh shfiles/rspx4.sh`
  * `rostopic echo /drone_0_imu_propagate`
  * 拿起飞机进行缓慢的小范围晃动，放回原地后确认没有太大误差
  * 遥控器5通道拨到内侧，六通道拨到下侧，油门打到中位
  * `roslaunch px4ctrl run_ctrl.launch`
  * `sh shfiles/takeoff.sh`，如果飞机螺旋桨开始旋转，但无法起飞，说明`hover_percent`参数过小；如果飞机有明显飞过1米高，再下降的样子，说明`hover_percent`参数过大
  * 遥控器此时可以以类似大疆飞机的操作逻辑对无人机进行位置控制
  * `sh shfiles/land.sh`，自动降落，降落时把油门打到最低，等无人机降到地上后，把5通道拨到中间，左手杆打到左下角上锁
* Ego-Planner-v2实验
  * 自动起飞
  * `sh shfiles/record.sh`
  * 进入远程桌面 `sh shfiles/ego.sh `
  * 按下G键加鼠标左键点选目标点使无人机飞行
  * 自动降落`sh shfiles/land.sh`
* <font color="#dd0000">如果实验中遇到意外怎么办！！！</font>
  * `case 1`: VINS定位没有飘，但是规划不及时/建图不准确导致无人机规划出一条可能撞进障碍物的轨迹。如果飞手在飞机飞行过程中发现无人机可能会撞到障碍物，在撞上前把6通道拨回上侧，此时无人机会退出轨迹跟随模式，进入VINS悬停模式，在此时把无人机安全着陆即可
  * `case 2`：VINS定位飘了，表现为飞机大幅度颤抖/明显没有沿着正常轨迹走/快速上升/快速下降等等，此时拨6通道已经无济于事，必须把5通道拨回中位，使无人机完全退出程序控制，回到遥控器的stablized模式来操控降落
  * `case 3`：无人机已经撞到障碍物，并且还没掉到地上。此时先拨6通道，看看飞机能不能稳住，稳不住就拨5通道手动降落
  * `case 4`：无人机撞到障碍物并且炸到地上了：拨5通道立刻上锁，减少财产损失
  * `case 5`：**绝招** 反应不过来哪种case，或者飞机冲着非常危险的区域飞了，直接拨7通道紧急停桨。这样飞机会直接失去动力摔下来，对飞机机身破坏比较大，一般慢速情况下不建议。


