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
		echo ".. Starting $arch";

		test -d "$BASE_DIR/$arch/" || mkdir -p "$BASE_DIR/$arch/";

		echo ".... Copying rpms for $pkg ($arch)";
		cd "$TMP_DIR/$pkg/$arch";
		cp -v *.rpm "$BASE_DIR/$arch/";
	
		echo ""
	done
done
rm -rf $TMP_DIR
cd "$BASE_DIR"

for arch in *;
do
	test -d "$BASE_DIR/$arch" || continue;
	cd "$BASE_DIR/$arch";
	createrepo "$BASE_DIR/$arch";
done
chown -R www-server:www-data "$BASE_DIR";
