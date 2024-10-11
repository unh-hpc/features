#!/usr/bin/env bash
set -x
set -e

echo "Installing ADIOS2"
echo "The provided version is: ${VERSION}"

if [ "$(id -u)" -ne 0 ]; then
    echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

apt_get_update() {
    if [ "$(find /var/lib/apt/lists/* | wc -l)" = "0" ]; then
        echo "Running apt-get update..."
        apt-get update -y
    fi
}

# Checks if packages are installed and installs them if not
check_packages() {
    if ! dpkg -s "$@" >/dev/null 2>&1; then
        apt_get_update
        apt-get -y install --no-install-recommends "$@"
    fi
}

export DEBIAN_FRONTEND=noninteractive

check_packages curl ca-certificates tar cmake libopenmpi-dev

curl -sLo adios2.tar.gz https://github.com/ornladios/ADIOS2/archive/refs/tags/v${VERSION}.tar.gz
tar zxvf adios2.tar.gz

mkdir build-adios2
cmake -B build-adios2 -S ADIOS2-${VERSION}
cmake --build build-adios2
cmake --install build-adios2

rm -rf adios2.tar.gz ADIOS2-${VERSION} build-adios2