FROM cognipilot/dream:airy-20240111
USER user

###### MIRROR FIX ###### 
RUN sudo curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg
RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null
RUN sudo apt update

###### CONFIGURE WORKSPACE AND BUILD FOXGLOVE ###### 
RUN echo "Configuring Workspace"
WORKDIR /home/user/cognipilot

RUN source /opt/ros/humble/setup.bash && \
  source /home/user/.bashrc && \
  source /etc/profile && \
  source /home/user/.profile && \
  printf "n\n1\n" | build_workspace

COPY ./build_foxglove /home/user/bin/build_foxglove
RUN sudo chmod +x /home/user/bin/build_foxglove

RUN source /opt/ros/humble/setup.bash && \
  source /home/user/.bashrc && \
  source /etc/profile && \
  source /home/user/.profile && \
  printf "n\n1\n" | build_foxglove

###### SETUP NXP_AIM_INDIA_2025 and YOLOv5 ######
RUN echo "Setup NXP AIM 2025 and YOLOv5" && \
  git clone https://github.com/NXPHoverGames/NXP_AIM_INDIA_2025 /home/user/cognipilot/cranium/src/NXP_AIM_INDIA_2025 && \
  git clone https://github.com/NXPHoverGames/B3RB_YOLO_OBJECT_RECOG.git /tmp/B3RB_YOLO_OBJECT_RECOG && \
  cd /tmp/B3RB_YOLO_OBJECT_RECOG && \
  git checkout nxp_aim_india_2025 && \
  mv resource/coco.yaml /home/user/cognipilot/cranium/src/NXP_AIM_INDIA_2025/resource/ && \
  mv resource/yolov5n-int8.tflite /home/user/cognipilot/cranium/src/NXP_AIM_INDIA_2025/resource/ && \
  mv b3rb_ros_aim_india/b3rb_ros_object_recog.py /home/user/cognipilot/cranium/src/NXP_AIM_INDIA_2025/b3rb_ros_aim_india/ && \
  cd /home/user/cognipilot && \
  rm -rf /tmp/B3RB_YOLO_OBJECT_RECOG && \
  sed -i -e '12s/^\([[:space:]]*\)#/\1/' \
  -e '13s/^\([[:space:]]*\)#/\1/' \
  -e '28s/^\([[:space:]]*\)#/\1/' \
  /home/user/cognipilot/cranium/src/NXP_AIM_INDIA_2025/setup.py 

###### ENVIRONMENT SETUP AND CRANIUM SETUP ######
RUN echo "Environment Setup CRANIUM" && \
  cd /home/user/cognipilot/cranium/src/ && \
  rm -rf dream_world synapse_msgs b3rb_simulator && \
  git clone https://github.com/NXPHoverGames/dream_world.git && \
  cd dream_world && git checkout nxp_aim_india_2025 && cd .. && \
  git clone https://github.com/NXPHoverGames/synapse_msgs.git && \
  cd synapse_msgs && git checkout nxp_aim_india_2025 && cd .. && \
  git clone https://github.com/NXPHoverGames/b3rb_simulator.git && \
  cd b3rb_simulator && git checkout nxp_aim_india_2025

###### INSTALL PYTHON DEPS ######
RUN echo "Installing python deps" && \
  python3 -m pip install --no-cache-dir \
  torch==2.3.0 \
  torchvision==0.18.0 \
  numpy==1.26.4 \
  opencv-python==4.11.0.86 \
  scipy==1.15.1 \
  scikit-learn==1.5.2 \
  tk==0.1.0 \
  pyzbar==0.1.9 \
  matplotlib==3.5.1 \
  pyyaml==6.0.2 \
  tflite-runtime==2.14.0

###### BUILD WORKSPACE AND LAUNCH ######
RUN echo "Build Workspace and Preparing Launch?" && \
  cd /home/user/cognipilot/cranium/ && \
  source /opt/ros/humble/setup.bash && \
  source /home/user/.bashrc && \
  source /etc/profile && \
  source /home/user/.profile && \
  colcon build && \
  source /home/user/cognipilot/cranium/install/setup.bash

CMD ["/bin/bash"]
