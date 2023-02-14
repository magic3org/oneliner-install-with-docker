#!/bin/bash
# 
# Script Name: build_env.sh
#
# Version:      1.0
# Author:       Naoki Hirata
# Date:         2023-02-14
# Usage:        build_env.sh [-test]
# Options:      -test      test mode execution with the latest source package
# Description:  This script builds Docker server environment with the one-liner command.
# Version History:
#               1.0  (2023-02-14) initial version
# License:      MIT License

# Define macro parameter
readonly GITHUB_USER="magic3org"
readonly GITHUB_REPO="oneliner-install-with-docker"
readonly WORK_DIR=/root/${GITHUB_REPO}_work
readonly PLAYBOOK="docker_env"

# check root user
readonly USERID=`id | sed 's/uid=\([0-9]*\)(.*/\1/'`
echo $USERID;
if [ $USERID -ne 0 ]
then
    echo "error: can only excute by root"
    exit 1
fi

# Check os version
declare OS="unsupported os"
declare DIST_NAME="not ditected"

if [ "$(uname)" == 'Darwin' ]; then
    OS='Mac'
    uname -a
    exit 1
elif [ "$(expr substr $(uname -s) 1 5)" == 'Linux' ]; then
    RELEASE_FILE=/etc/os-release
    if grep '^NAME="CentOS' ${RELEASE_FILE} >/dev/null; then
        OS="CentOS"
        DIST_NAME="CentOS"
        OS_VERSION=$(. /etc/os-release; echo $VERSION_ID)
    elif grep '^NAME="Amazon' ${RELEASE_FILE} >/dev/null; then
        OS="Amazon Linux"
        DIST_NAME="Amazon Linux"
        uname -a
        exit 1
    elif grep '^NAME="Ubuntu' ${RELEASE_FILE} >/dev/null; then
        OS="Ubuntu"
        DIST_NAME="Ubuntu"
    else
        echo "Your platform is not supported."
        uname -a
        exit 1
    fi
elif [ "$(expr substr $(uname -s) 1 6)" == 'CYGWIN' ]; then
    OS='Cygwin'
    uname -a
    exit 1
else
    echo "Your platform is not supported."
    uname -a
    exit 1
fi

echo "########################################################################"
echo "# $DIST_NAME"
echo "# START BUILDING ENVIRONMENT"
echo "########################################################################"

# Get test mode
if [ "$1" == '-test' ]; then
    readonly TEST_MODE="true"

    echo "################# START TEST MODE #################"
else
    readonly TEST_MODE="false"
fi

declare INSTALL_PACKAGE_CMD=""
if [ $OS == 'CentOS' ]; then
    INSTALL_PACKAGE_CMD="yum -y install"

    # Install required command
    $INSTALL_PACKAGE_CMD tar

    if [ $((OS_VERSION)) -ge 9 ]; then
        $INSTALL_PACKAGE_CMD ansible-core
    else
        # Repository update for latest ansible
        $INSTALL_PACKAGE_CMD epel-release
    fi
elif [ $OS == 'Ubuntu' ]; then
    if ! type -P ansible >/dev/null ; then
        INSTALL_PACKAGE_CMD="apt -y install"

        # Repository update for ansible
        apt -y update
        apt -y upgrade
        apt -y install software-properties-common
        apt-add-repository --yes --update ppa:ansible/ansible
    fi
fi

# Install ansible command if not exists
if [ "$INSTALL_PACKAGE_CMD" != '' ]; then
    $INSTALL_PACKAGE_CMD ansible
    $INSTALL_PACKAGE_CMD git
fi

# Download the latest repository archive
if [ $TEST_MODE == 'true' ]; then
    url="https://github.com/${GITHUB_USER}/${GITHUB_REPO}/archive/master.tar.gz"
    version="new"
else
    url=`curl -s "https://api.github.com/repos/${GITHUB_USER}/${GITHUB_REPO}/tags" | grep "tarball_url" | \
        sed -n '/[ \t]*"tarball_url"/p' | head -n 1 | \
        sed -e 's/[ \t]*".*":[ \t]*"\(.*\)".*/\1/'`
    version=`basename $url | sed -e 's/v\([0-9\.]*\)/\1/'`
fi
filename=${GITHUB_REPO}_${version}.tar.gz
filepath=${WORK_DIR}/$filename

# Set current directory
mkdir -p ${WORK_DIR}
cd ${WORK_DIR}
savefilelist=`ls -1`

# Download archived repository
echo "########################################################################"
echo "Download GitHub repository ${GITHUB_USER}/${GITHUB_REPO}"
echo "########################################################################"
curl -s -o ${filepath} -L $url

# Remove old files
for file in $savefilelist; do
    if [ ${file} != ${filename} ]
    then
        rm -rf "${file}"
    fi
done

# Get archive directory name
destdir=`tar tzf ${filepath} | head -n 1`
destdirname=`basename $destdir`

# Unarchive repository
tar xzf ${filename}
find ./ -type f -name ".gitkeep" -delete
mv ${destdirname} ${GITHUB_REPO}
echo ${filename}" unarchived"

# launch ansible
cd ${WORK_DIR}/${GITHUB_REPO}/playbooks/${PLAYBOOK}
ansible-galaxy install --role-file=requirements.yml --roles-path=/etc/ansible/roles --force
ansible-playbook -i localhost, main.yml
