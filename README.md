# 导航代码使用文档
## 环境配置
**系统配置**
- Ubuntu22.04
- ROS Humble (desktop-full)

**库依赖**
- LIVOX-SDK2
- Libpcl-ros-dev
- eigen、pcl、opencv、ceres等

**硬件配置**
- 3D雷达（mid360）
- 2D雷达（lakibeam1）

**安装依赖**
```
sudo apt-get update
sudo apt install ros-humble-serial-driver
sudo apt install ros-humble-urdf-tutorial
sudo apt-get install libeigen3-dev libpcl-ros-dev
sudo apt install ros-humble-navigation2 ros-humble-nav2-*
sudo apt install -y ros-humble-pcl-ros ros-humble-pcl-conversions ros-humble-tf2* libgoogle-glog-dev ros-humble-libpointmatcher
```


**安装Livox-SDK2**
```
git clone https://ghproxy.com/https://github.com/Livox-SDK/Livox-SDK2.git
cd ./Livox-SDK2/
mkdir build
cd build
cmake .. && make -j
sudo make install
```

**编译**
```
colcon build
```

## 配置参数
**mid360配置**
- 修改rm_sensors/livox_ros_driver2/config/MID360_config.json
将雷达ip改成192.168.1.1xx   （xx为雷达广播码后两位）
```
"host_net_info" : {
      "cmd_data_ip" : "192.168.1.50",  # host ip
      "cmd_data_port": 56000,
      "push_msg_ip": "",
      "push_msg_port": 0,
      "point_data_ip": "192.168.1.50",  # host ip
      "point_data_port": 57000,
      "imu_data_ip" : "192.168.1.50",  # host ip
      "imu_data_port": 58000,
      "log_data_ip" : "",
      "log_data_port": 59000
    }
  },
  "lidar_configs" : [
    {
      "ip" : "192.168.1.106",  # 修改为192.168.1.1+广播码后两位
      "pcl_data_type" : 1,
      "pattern_mode" : 0,
      "blind_spot_set" : 50,
      "extrinsic_parameter" : {
        "roll": 0.0,
        "pitch": 0.0,
        "yaw": 0.0,
        "x": 0,
        "y": 0,
        "z": 0
      }
```

- 修改有线连接ip
（修改ubuntu有线连接IPv4，修改如下图，地址与1.1中用户IP相同）
![Alt text](https://github.com/Lzc2003/ROS2_Nav_Implement/blob/master/doc/3.png)


**lakibeam1  2d雷达配置**

- 当使用USB Type-C连接时，LakiBeam1(L/S)的IP地址默认为192.168.8.2，计算机的IP地址配置为192.168.8.1。PC的静态IP不需要设置，输入雷达的ip地址：192.168.8.2到浏览器。然后设置主机IP：192.168.8.1，并设置为DHCP模式。雷达将在几秒钟延迟后重置网络配置。在雷达的web服务器上通过USBType-C连接雷达进行的IP配置如下图所示：

![Alt text](https://github.com/Lzc2003/ROS2_Nav_Implement/blob/master/doc/1.png)


## 运行
- 修改文件参数
修改rm_perception/icp_localization_ros2/config/node_params.yaml中的点云图路径
```
/icp_localization:
  ros__parameters:
    pcd_file_path: "/home/ace/ace_nav/test.pcd"  # 需要修改点云图路径
```
- 修改rm_navigation/launch/bringup_launch.py中的地图文件路径
```
# 需要修改的地图文件
declare_map_yaml_cmd = DeclareLaunchArgument(
        'map',
        default_value= os.path.join(bringup_dir,'map', 'map.yaml'), # 需要修改yaml文件
        description='Full path to map yaml file to load')
```


## 建图
```
. mapping.sh
```
- 保存地图，运行rqt，选择/map_save服务，点击call保存点云pcd图
```
rqt
```
![Alt text](https://github.com/Lzc2003/ROS2_Nav_Implement/blob/master/doc/2.png)


- 再运行nav2_map_server功能包的map_saver_cli节点保存，加上-f参数，保存在当前运行命令的文件夹下，map为保存的地图名字
```
ros2 run nav2_map_server map_saver_cli -f map
```


## 导航
```
. nav.sh
sudo chmod 777 /dev/ttyACM0
ros2 launch rm_serial_driver serial_driver.launch.py
```

# 修改代码参数
## 雷达外参
- 若3d雷达有倒置、倾斜等放置姿态需求，需要修改rm_sensors/livox_ros_driver2/config/MID360_config.json中的extrinsic_parameter
```
"lidar_configs" : [
    {
      "ip" : "192.168.1.106",
      "pcl_data_type" : 1,
      "pattern_mode" : 0,
      "extrinsic_parameter" : {
        "roll": 0.0,
        "pitch": 27.0,
        "yaw": 0.0,
        "x": 0,
        "y": 0,
        "z": 0
      }
    }
  ]
```
- 需要修改3d雷达的离地高度，在rm_perception/linefit_ground_segementation_ros2/linefit_ground_segmentation_ros/launch/segmentation_params.yaml 中修改

```
ground_segmentation:
  ros__parameters:
    sensor_height: 0.23         # sensor height above ground.

```

- 机器人外参
在rm_navigation/params/nav2_params.yaml 中修改local_costmap和global_costmap的机器人半径
```
local_costmap:
  local_costmap:
    ros__parameters:
      robot_radius: 0.2
      
      
global_costmap:
  global_costmap:
    ros__parameters:
      robot_radius: 0.20
```
