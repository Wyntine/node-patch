#!/bin/bash
version=$1
versionWithPrefix=v$1

if [ -z "$version" ]; then
  echo "Usage: $0 <version>"
  echo "Example: $0 24.0.2"
  exit 1
fi

rpmBuildHome=$(rpm --eval '%{_topdir}')

rpmbuild --rebuild $rpmBuildHome/SRPMS/node-$version-*.src.rpm
ls $rpmBuildHome/RPMS/x86_64