#!/bin/bash
version=$1
versionWithPrefix=v$1

if [ -z "$version" ]; then
  echo "Usage: $0 <version>"
  echo "Example: $0 24.0.2"
  exit 1
fi

startDir=$(pwd)
patchDir="$startDir/patches"

tempDir=$(mktemp -d)

patchFile="node-$version.patch"
tarFile="node-$versionWithPrefix.tar.gz"

localPatchFile="$patchDir/$patchFile"
rpmBuildHome=$(rpm --eval '%{_topdir}')

if [ ! -d "$tempDir" ]; then
  echo "Failed to create temporary directory."
  exit 1
fi

echo "Temporary directory created at $tempDir"
trap 'echo "Cleaning up..."; rm -rf "$tempDir"' EXIT
cd $tempDir

if [ $? -ne 0 ]; then
  echo "Failed to create or change to temp directory."
  exit 1
fi

rpmdev-setuptree

if [ $? -ne 0 ]; then
  echo "Failed to set up RPM build tree."
  exit 1
fi

if [ -f $localPatchFile ]; then
  echo "Continuing with current patch file."
else
  echo "Local patch file not found."
  echo "Exiting..."
  exit 1
fi

curl -O https://nodejs.org/dist/$versionWithPrefix/node-$versionWithPrefix.tar.gz

if [ $? -ne 0 ]; then
  echo "Failed to download the source code."
  exit 1
fi

cp $localPatchFile $patchFile

sh $startDir/lib/fedora/createSpec.sh $version

cp node-$version.spec $rpmBuildHome/SPECS/
cp $tarFile $rpmBuildHome/SOURCES/
cp $patchFile $rpmBuildHome/SOURCES/

rpmbuild -bs node-$version.spec
cd $startDir