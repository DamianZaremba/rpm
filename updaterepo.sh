#!/bin/bash
#############################################################
# Simple bash script to update the repo from git            #
#                                                           #
#############################################################

BASE_REPO="git://github.com/DamianZaremba/rpm-%%type%%.git";
BASE_DIR="/var/www/vhosts/repo.nodehost.co.uk/";
REPOS=( "centos" "fedora" );

for repo in ${REPOS[@]};
do
	TMP_DIR=$(mktemp -d /tmp/repoupdate.XXXXX);
	test -d "$BASE_DIR/$repo" || mkdir -p "$BASE_DIR/$repo";

	git clone --quiet --progress $(echo $BASE_REPO | sed "s/%%type%%/$repo/") $TMP_DIR;
	if [ -d $TMP_DIR ];
	then
		cd $TMP_DIR;
		for pkg in *;
		do
			test -d "$TMP_DIR/$pkg" || continue;
			cd "$TMP_DIR/$pkg";
			echo "Starting $pkg";
			for arch in *;
			do
				test -d "$TMP_DIR/$pkg/$arch" || continue;
				cd "$TMP_DIR/$pkg/$arch";
				echo ".. Starting $arch";
		
				test -d "$BASE_DIR/$repo/$arch/" || mkdir -p "$BASE_DIR/$repo/$arch/";
		
				echo ".... Copying rpms for $pkg ($arch)";
				cd "$TMP_DIR/$pkg/$arch";
				rsync -vr --delete *.rpm "$BASE_DIR/$repo/$arch/";
			
				echo "";
			done
		done
	fi

	test -d $TMP_DIR && rm -rf $TMP_DIR;
	cd "$BASE_DIR/$repo";

	for arch in *;
	do
		test -d "$BASE_DIR/$repo/$arch" || continue;
		cd "$BASE_DIR/$repo/$arch";

		createrepo -d "$BASE_DIR/$repo/$arch";
		repoview -t "$repo - $arch" "$BASE_DIR/$repo/$arch";
	done
done
chown -R www-server:www-data "$BASE_DIR";
