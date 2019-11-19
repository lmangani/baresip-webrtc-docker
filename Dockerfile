# Baresip Docker (GIT)

FROM phusion/baseimage:latest
MAINTAINER L. Mangani <lorenzo.mangani@gmail.com>

# Set correct environment variables.
ENV DEBIAN_FRONTEND noninteractive 
ENV HOME /root
ENV TMP /tmp

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

# Set locale to UTF8
RUN locale-gen --no-purge en_US.UTF-8 && update-locale LANG=en_US.UTF-8 && dpkg-reconfigure locales
ENV LANGUAGE en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8

# Use baseimage-docker's init system.
# CMD ["/sbin/my_init"]

# Set software versions to install
ENV WEB http://www.creytiv.com/pub
ENV LIBRE re-0.6.1
ENV LIBREM rem-0.6.0 
ENV BARESIP baresip-0.6.4
ENV BARESIPGIT https://github.com/alfredh/baresip.git
ENV BARESIPRTC https://github.com/alfredh/baresip-webrtc

# Update Apt
RUN apt-get update \
 
# Installing required packages
&& apt-get -y install build-essential git wget curl \

# Enable audio I/O (alsa, sndfile, gst)
&& apt-get -y install libasound2-dev libasound2 libasound2-data module-init-tools libsndfile1-dev gstreamer0.10-alsa \
# RUN sudo modprobe snd-dummy
# RUN sudo modprobe snd-aloop

# Install GStreamer
&& apt-get -y install gstreamer0.10-alsa gstreamer0.10-tools gstreamer0.10-x gstreamer0.10-plugins-base gstreamer0.10-plugins-good libgstreamer-plugins-base0.10-0 libgstreamer-plugins-base0.10-dev libgstreamer0.10-0 libgstreamer0.10-dev

# Install Libre
RUN cd $TMP && wget $WEB/$LIBRE.tar.gz && tar zxvf $LIBRE.tar.gz && cd $LIBRE && make && make install 

# Install Librem
RUN cd $TMP && wget $WEB/$LIBREM.tar.gz && tar zxvf $LIBREM.tar.gz && cd $LIBREM && make && make install 

# Install Baresip from GIT
RUN cd $TMP && git clone $BARESIPGIT baresip && cd baresip && make && make install 

# Install Configuration from self
RUN cd $HOME && mkdir baresip && chmod 775 baresip \
&& cd $TMP && git clone https://github.com/QXIP/baresip-docker.git \
&& cp -R $TMP/baresip-docker/.baresip $HOME/ \
&& cp $TMP/baresip-docker/.asoundrc $HOME/ \
&& rm -rf $TMP/baresip-docker 

# Test Baresip to initialize default config and Exit
RUN ldconfig && baresip -t -f $HOME/.baresip

# Install Baresip-webrtc from GIT
RUN cd / && git clone $BARESIPGIT rtc && cd rtc \
  && make install-dev -C ../baresip \
  && make && make install 

# Clean up
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Ports for Service (SIP,RTP) and Control (HTTP,TCP)
EXPOSE 5060 5061 10000-10020 8000 5555 9000
WORKDIR /rtc

# Default Baresip run command arguments
# CMD ["baresip", "-d","-f","/root/.baresip"]
CMD["./baresip-webrtc"]
