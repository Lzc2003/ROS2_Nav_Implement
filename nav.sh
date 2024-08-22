colcon build
cmds=(
	"ros2 launch urdf_tutorial display.launch.py model:=urdf/09.urdf"
	"ros2 launch livox_ros_driver2 msg_MID360_launch.py"
	"ros2 launch linefit_ground_segmentation_ros segmentation.launch.py" 
	"ros2 launch fast_lio mapping.launch.py"
	"ros2 launch pointcloud_to_laserscan pointcloud_to_laserscan_launch.py"
	"ros2 launch icp_localization_ros2 bringup.launch.py"
	"ros2 launch rm_navigation bringup_launch.py"
	)

for cmd in "${cmds[@]}";
do
	echo Current CMD : "$cmd"
	gnome-terminal -- bash -c "cd $(pwd);source install/setup.bash;$cmd;exec bash;"
	sleep 0.5
done
