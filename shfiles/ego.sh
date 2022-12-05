roslaunch ego_planner single_run_in_exp.launch & sleep 2;

gnome-terminal -t "rviz" -x bash -c "roslaunch ego_planner rviz.launch;exec bash;"

wait;