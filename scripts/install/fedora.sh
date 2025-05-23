#!/bin/bash
sudo dnf update -y
sudo dnf install -y \
  python3 \
  python3-pip \
  gcc-c++ \
  make \
  rpmdevtools \
  ccache \
  ninja-build