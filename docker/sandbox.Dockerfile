FROM ros:noetic
ENV SHELL /bin/bash

ARG DEBIAN_FRONTEND=noninteractive
ARG USERNAME=circles
ARG PASSWORD=circles
ARG ROS_WS=/home/${USERNAME}/catkin_ws

RUN apt-get update \
  && apt-get install -y ssh \
      bash-completion \
      build-essential \
      clang \
      cmake \
      g++ \
      gcc \
      gdb \
      git \
      gpsd \
      libgps-dev \
      libusb-1.0-0-dev \
      libncurses5-dev \
      python \
      rsync \
      tar \
      tree \
      vim \
      wget \
  && rm -rf /var/lib/apt/lists/*

# Adding a privileged user for CLion to SSH
RUN groupadd -r ${USERNAME}
RUN useradd -m -r -g ${USERNAME} ${USERNAME} && yes ${PASSWORD} | passwd ${USERNAME}
RUN usermod -s /bin/bash ${USERNAME} && usermod -aG sudo ${USERNAME}
RUN mkdir -p ${ROS_WS} && chown -R ${USERNAME} /home/${USERNAME}
RUN ( \
    echo 'LogLevel DEBUG2'; \
    echo 'PermitRootLogin yes'; \
    echo 'PasswordAuthentication yes'; \
    echo 'Subsystem sftp /usr/lib/openssh/sftp-server'; \
  ) > /etc/ssh/sshd_config_test_clion \
  && mkdir /run/sshd
RUN ( \
    echo 'source /opt/ros/noetic/setup.bash'; \
    echo 'ROS_MASTER_URI=http://roscore:11311'; \
  ) >> /home/circles/.bashrc
    
CMD /usr/sbin/sshd -D -e -f /etc/ssh/sshd_config_test_clion
