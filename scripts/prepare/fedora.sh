#!/bin/bashversion=$1
version=$1
versionWithPrefix=v$1

if [ -z "$version" ]; then
  echo "Usage: $0 <version>"
  echo "Example: $0 24.0.2"
  exit 1
fi

startDir=$(pwd)
patchDir="$startDir/patches"
srcDir="$startDir/src"

tempDir=$(mktemp -d)

patchFile="node-$version.patch"
tarFile="node-$versionWithPrefix.tar.gz"
repoDir="node-$versionWithPrefix"

localTarFile="$srcDir/$tarFile"
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

if [ -f $localTarFile ]; then
  echo "Using local tar file: $localTarFile"
  tar -xzf $localTarFile

  if [ $? -ne 0 ]; then
    echo "Failed to extract local tar file."
    exit 1
  fi
else
  echo "Local tar file not found."
  exit 1
fi

if [ -f $localPatchFile ]; then
  echo "Continuing with current patch file."
else
  echo "Local patch file not found."
  exit 1
fi

cp $localPatchFile $patchFile

echo "Cleaning git files..."
rm -rf $repoDir/.git $repoDir/.github $repoDir/.gitignore

echo "Compressing the source code to $tarFile"
tar -czf $tarFile $repoDir

if [ $? -ne 0 ]; then
  echo "Failed to compress the source code."
  exit 1
fi

sh $startDir/lib/fedora/createSpec.sh $version

cp node-$version.spec $rpmBuildHome/SPECS/
cp $tarFile $rpmBuildHome/SOURCES/
cp $patchFile $rpmBuildHome/SOURCES/

rpmbuild -bs node-$version.spec