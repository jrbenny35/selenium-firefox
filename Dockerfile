FROM selenium/standalone-firefox

USER root

# Install Mysql
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get -y install mysql-server
RUN apt-get install -y libmysqlclient-dev

# Install git
RUN apt-get install -y git

# Install nodejs
RUN apt-get install -y nodejs
RUN apt-get install -y npm
RUN ln -s /usr/bin/nodejs /usr/bin/node

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
RUN apt-get install -y python-pip python-dev build-essential
RUN pip install --upgrade pip

# Install Tox
RUN pip install tox

WORKDIR /code

