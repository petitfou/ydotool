#!/bin/bash

# Inputs
PKG_NAME=$1

set -e

[ ! -z "${PKG_NAME}" ] || exit 0
   
PKG_VER=$(dpkg-parsechangelog | sed -n 's/^Version: //p')
VERS_ARRAY=(${PKG_VER//-/ })
PKG_ORIG_VER=${VERS_ARRAY[0]}
git archive --format=tar.gz -o ${PKG_NAME}_${PKG_ORIG_VER}.orig.tar.gz v${PKG_VER}
WORK_DIR=${PACKAGE_NAME}_work_71d52e10_d335_11ed_afa1_0242ac120002
mkdir -p ${WORK_DIR}
sudo mk-build-deps -i -r
sudo rm -f ${PKG_NAME}-build-deps*
cd ${WORK_DIR}
tar xvf ../${PKG_NAME}_${PKG_ORIG_VER}.orig.tar.gz
cp -rf ../debian ./
# -sa : force inclusion of the orig source
# with some version of dpkg-dev, there is a bug that make the orig source not included into the changes file
# so use -sa flag to force it
debuild -S -us -uc -sa
cd ../

# Upload the package
DEBSIGN_MAIL=$2
PPA=$3

[ ! -z "${DEBSIGN_MAIL}" ] || exit 0
[ ! -z "${PPA}" ] || exit 0

debsign -k${DEBSIGN_MAIL} ${PKG_NAME}_${PKG_VER}_source.changes
dput -f ${PPA} ${PKG_NAME}_${PKG_VER}_source.changes
