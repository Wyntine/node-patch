#!/bin/bash
version=$1
versionWithPrefix=v$1

if [ -z "$version" ]; then
  echo "Usage: $0 <version>"
  echo "Example: $0 24.0.2"
  exit 1
fi

rpmBuildHome=$(rpm --eval '%{_topdir}')

rpmbuild --rebuild $rpmBuildHome/SRPMS/nodejs-$version-*.src.rpm

if [ $? -ne 0 ]; then
  echo "Failed to build the RPM."
  exit 1
fi

cd ~/