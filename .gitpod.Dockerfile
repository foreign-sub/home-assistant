FROM docker

FROM gitpod/workspace-full

USER root

RUN apt-get update

RUN apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
RUN add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

RUN apt-get update \
    && apt-get install -y docker-ce

RUN usermod -a -G docker gitpod
RUN newgrp docker
RUN service docker restart
RUN docker run hello-world
RUN curl -L --fail https://github.com/docker/compose/releases/download/1.24.1/run.sh -o /usr/local/bin/docker-compose
RUN chmod +x /usr/local/bin/docker-compose
#RUN docker run homeassistant/home-assistant

#FROM python:3.7

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        libudev-dev \
        libavformat-dev \
        libavcodec-dev \
        libavdevice-dev \
        libavutil-dev \
        libswscale-dev \
        libswresample-dev \
        libavfilter-dev \
        git \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /usr/src



# Setup hass-release
RUN git clone --depth 1 https://github.com/home-assistant/hass-release \
    && cd hass-release \
    && pip3 install -e .


WORKDIR /workspaces

USER root
# Install Python dependencies from requirements
COPY requirements_test.txt requirements_test_pre_commit.txt homeassistant/package_constraints.txt ./
RUN pip3 install -r requirements_test.txt -c package_constraints.txt \
    && rm -f requirements_test.txt requirements_test_pre_commit.txt package_constraints.txt

RUN pip3 install tox colorlog pre-commit

COPY requirements_all.txt ./
RUN pip3 install -r requirements_all.txt \
    && rm -f requirements_all.txt

# Set the default shell to bash instead of sh
ENV SHELL /bin/bash

USER gitpod

