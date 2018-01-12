FROM selenium/standalone-firefox

USER root

ENV GEOMETRY="$SCREEN_WIDTH""x""$SCREEN_HEIGHT""x""$SCREEN_DEPTH"

# Install Mysql
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update -qqy \
  && apt-get -qqy install \
    mysql-server \
    libmysqlclient-dev

# Install git
RUN apt-get -qqy \
  install git

# Install nodejs
RUN apt-get update -qqy \
  && apt-get -qqy install \
    nodejs \
    npm \
  && ln -s /usr/bin/nodejs /usr/bin/node

# Update to firefox nightly
ARG FIREFOX_DOWNLOAD_URL=https://download.mozilla.org/?product=firefox-nightly-latest-ssl&lang=en-US&os=linux64
RUN wget --no-verbose -O /tmp/firefox.tar.bz2 $FIREFOX_DOWNLOAD_URL \
  && apt-get -y purge firefox \
  && rm -rf /opt/firefox \
  && tar -C /opt -xjf /tmp/firefox.tar.bz2 \
  && rm /tmp/firefox.tar.bz2 \
  && mv /opt/firefox /opt/firefox-nightly \
  && ln -fs /opt/firefox-nightly/firefox /usr/bin/firefox

# Install python
RUN apt-get update -qqy \
  && apt-get -qqy install \
    python-pip \
    python-dev \
    build-essential \
  && pip install --upgrade pip

# Install Tox
RUN pip install tox

# VNC
RUN apt-get update -qqy \
  && apt-get -qqy install \
    x11vnc \
  && rm -rf /var/lib/apt/lists/* /var/cache/apt/*

# fluxbox
# A fast, lightweight and responsive window manager
RUN apt-get update -qqy \
  && apt-get -qqy install \
    fluxbox \
  && rm -rf /var/lib/apt/lists/* /var/cache/apt/*

USER seluser

# Generating the VNC password as seluser
# So the service can be started with seluser

RUN mkdir -p ~/.vnc \
  && x11vnc -storepasswd secret ~/.vnc/passwd

WORKDIR /code

RUN DISPLAY=$DISPLAY \
  xvfb-run -n $SERVERNUM --server-args="-screen 0 $GEOMETRY -ac +extension RANDR" \
  java ${JAVA_OPTS} -jar /opt/selenium/selenium-server-standalone.jar \
  ${SE_OPTS} & \
  fluxbox -display $DISPLAY & \
  x11vnc -forever -usepw -shared -rfbport 5900 -display $DISPLAY &

USER root

EXPOSE 4444
EXPOSE 5900
