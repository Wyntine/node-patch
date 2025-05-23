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
srcDir="$startDir/src"

tempDir=$(mktemp -d)

patchFile="node-$version.patch"
tarFile="node-$versionWithPrefix.tar.gz"
repoDir="node-$versionWithPrefix"

localTarFile="$srcDir/$tarFile"
localPatchFile="$patchDir/$patchFile"

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

if [ -f $localTarFile ]; then
  echo "Using local tar file: $localTarFile"
  tar -xzf $localTarFile

  if [ $? -ne 0 ]; then
    echo "Failed to extract local tar file."
    exit 1
  fi
else
  echo "Local tar file not found, cloning from GitHub..."
  git clone --branch $versionWithPrefix https://github.com/nodejs/node.git $repoDir --depth 1

  if [ $? -ne 0 ]; then
    echo "Failed to clone the repository."
    exit 1
  fi

  echo "Saving backup of the original source code..."
  tar -czf $localTarFile $repoDir
fi


fileSize=$(du -sb $repoDir | cut -f1)

if [ $fileSize -lt 1000000 ]; then
  echo "File size is less than 1MB, download might have failed."
  exit 1
fi

openPatchEditor () {
  echo "Close the editor after patching to save patches and continue."
  code --new-window --wait "./$repoDir"

  if [ $? -ne 0 ]; then
    echo "Failed to open $repoDir in editor."
    return 1
  fi

  git -C $repoDir diff --relative --no-prefix > $patchFile
  cp $patchFile $localPatchFile

  if [ $? -ne 0 ]; then
    echo "No changes made to the source code."
    echo "Operation cancelled."
    return 1
  fi

  return 0
}

if [ -f $localPatchFile ]; then
  echo "Do you want to overwrite the existing patch file? (y/N)"
  read -r overwrite

  if [ "$overwrite" != "y" ]; then
    echo "Continuing with current patch file."
    cp $localPatchFile $patchFile
  else
    openPatchEditor
  fi
else
  openPatchEditor
fi

if [ $? -ne 0 ]; then
  echo "Failed to create or apply the patch."
  exit 1
fi