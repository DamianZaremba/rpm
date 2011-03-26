#!/bin/bash
#############################################################
# Simple bash script to update the repo from git            #
#                                                           #
#############################################################

CENTOS_REPO="https://github.com/DamianZaremba/rpm-centos.git";
BASE_DIR="/var/www/vhosts/repo.nodehost.co.uk/centos/"
TMP_DIR=$(mktemp -d /tmp/repoupdate.XXXXX)

mkdir -p $TMP_DIR
git clone $CENTOS_REPO $TMP_DIR
cd $TMP_DIR

echo $TMP_DIR
for pkg in *;
do
	test -d "$TMP_DIR/$pkg" || continue;
	cd "$TMP_DIR/$pkg";
	echo "Starting $pkg"
	for arch in *;
	do
		test -d "$TMP_DIR/$pkg/$arch" || continue;
		cd "$TMP_DIR/$pkg/$arch";
		echo ".. Starting $arch"

		test -d "$BASE_DIR/$arch/" || mkdir -p "$BASE_DIR/$arch/"

		echo ".... Copying rpms for $pkg ($arch)"
		find "$TMP_DIR/$pkg/$arch/" -type f -iname *.rpm -exec cp {} $BASE_DIR/$arch/ \;
	
		echo ""
	done
done
rm -rf $TMP_DIR
