#!/bin/bash
#############################################################
# Simple bash script to update the repos from git           #
#############################################################

BASE_REPO="git://github.com/DamianZaremba/rpm.git";
BASE_DIR="/var/www/vhosts/repo.nodehost.co.uk/";
DUMP_DIR="/home/rpms/%%-TYPE-%%/"
REPOS=( "CentOS-5" );

for repo in ${REPOS[@]};
do
	MY_DUMP_DIR=$(echo $DUMP_DIR | sed "s/%%-TYPE-%%/$repo/g");
	mkdir -p "$(echo $DUMP_DIR | sed "s/%%-TYPE-%%/$repo/g")../";
	test -d "$BASE_DIR/$repo" || mkdir -p "$BASE_DIR/$repo";

	if [ -d $MY_DUMP_DIR/.git ];
	then
		cd $MY_DUMP_DIR
		git pull
	else
		git clone --quiet --progress $BASE_REPO -b $repo $MY_DUMP_DIR;
		if [ "$?" != "0" ];
		then
			# This happens when the branch doesn't exist
			rm -rf $MY_DUMP_DIR;
		fi
	fi

	ls $MY_DUMP_DIR
	if [ -d $MY_DUMP_DIR/RPMS/ ];
	then
		cd $MY_DUMP_DIR/RPMS/;
		
		for arch in *;
		do
			test -d "$MY_DUMP_DIR/RPMS/$arch" || continue;
			cd "$MY_DUMP_DIR/RPMS/$arch";

			echo "Starting $arch";
			rsync -vr --delete *.rpm "$BASE_DIR/$repo/$arch/";

			echo "Running createrepo for $repo->$arch"
			createrepo -d "$BASE_DIR/$repo/$arch"

			echo "Running repoview for $repo->$arch"
			repoview -t "$repo - $arch" "$BASE_DIR/$repo/$arch";

			echo "Fixing access stuff"
			chown -R www-server:www-data "$BASE_DIR/$repo/$arch";
			find "$BASE_DIR/$repo/$arch" -type f -exec chmod 640 {} \;
			find "$BASE_DIR/$repo/$arch" -type d -exec chmod 750 {} \;
		done
	fi
done
