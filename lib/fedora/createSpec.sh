#!/bin/bash
version=$1
versionWithPrefix=v$1

if [ -z "$version" ]; then
  echo "Usage: $0 <version>"
  echo "Example: $0 24.0.1"
  exit 1
fi

cat > node-$version.spec <<EOF
Name:           nodejs
Epoch:          1
Version:        ${version}
Release:        1%{?dist}
Summary:        Node.js JavaScript runtime

License:        MIT
URL:            https://nodejs.org/
Source0:        node-${versionWithPrefix}.tar.gz
Patch0:         patches/node-${version}.patch

ExclusiveArch:  x86_64

%description
Node.js is a JavaScript runtime built on Chrome's V8 JavaScript engine.

%global optflags %{nil}
%global __global_cflags %{nil}
%global __global_cxxflags %{nil}
%global __global_ldflags %{nil}
%global _hardened_build 0
%global _lto_cflags %{nil}

%global __requires_exclude ^/usr/bin/pwsh$

%prep
%autosetup -n node-${versionWithPrefix} -p0

%build
export CFLAGS=""
export CXXFLAGS=""
export LDFLAGS=""
./configure --prefix=/usr --ninja
make

%install
%make_install

%files
%{_bindir}/*
%{_exec_prefix}/lib/node_modules/*
%{_mandir}/man1/node.1*
%{_exec_prefix}/include/node/*
%doc README.md CHANGELOG.md
%license LICENSE

%exclude %{_docdir}/node
EOF
