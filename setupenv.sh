#!/bin/bash
#############################################################
# Simple bash script to rebuild my rpm build environment    #
# Might be of use to other people.                          #
#                                                           #
# Expects a clean env and pulls down data from github.      #
#############################################################

CENTOS_REPO="https://github.com/DamianZaremba/rpm-centos.git";
BASE_DIR="/home/rpmbuild"

function initial_check {
	cd $BASE_DIR
	echo "--> We are going to install into $(pwd)"

	echo "Is this ok? [y/n]"
	read rep

	if [ "$rep" == "y" ];
	then
		return
	else
		echo "Exiting";
		exit 1;
	fi
}

function setup_rpm_stuff {
	echo "Setting up rpm env"
	cat > "$BASE_DIR/.rpmmacros" <<EOF
%_topdir $BASE_DIR/rpmbuild
%packager Damian Zaremba <damian@damianzaremba.co.uk>
EOF

	test -d "$BASE_DIR/rpmbuild" || mkdir "$BASE_DIR/rpmbuild/"
	test -d "$BASE_DIR/rpmbuild/BUILD" || mkdir "$BASE_DIR/rpmbuild/BUILD/"
	test -d "$BASE_DIR/rpmbuild/RPMS" || mkdir "$BASE_DIR/rpmbuild/RPMS/"
	test -d "$BASE_DIR/rpmbuild/SOURCES" || mkdir "$BASE_DIR/rpmbuild/SOURCES/"
	test -d "$BASE_DIR/rpmbuild/SPECS" || mkdir "$BASE_DIR/rpmbuild/SPECS/"
	test -d "$BASE_DIR/rpmbuild/SRPMS" || mkdir "$BASE_DIR/rpmbuild/SRPMS/"
}

function setup_centos {
	setup_rpm_stuff

	if [ -d "$BASE_DIR/rpm-centos" ];
	then
		cd "$BASE_DIR/rpm-centos"
		git pull
	else
		cd $BASE_DIR
		git clone $CENTOS_REPO
		cd "$BASE_DIR/rpm-centos"
	fi

	cd "$BASE_DIR/rpm-centos"
	for pkg in *;
	do
		test -d "$BASE_DIR/rpm-centos/$pkg" || continue;
		cd "$BASE_DIR/rpm-centos/$pkg";
		echo "Starting $pkg"
			echo ".... Copying specs for $pkg"
			find "$BASE_DIR/rpm-centos/$pkg/" -type f -iname *.spec -exec cp {} $BASE_DIR/rpmbuild/SPECS/ \;

			echo ".... Copying srpms for $pkg"
			find "$BASE_DIR/rpm-centos/$pkg/" -type f -iname *.srpm -exec cp {} $BASE_DIR/rpmbuild/SRPMS/ \;

			echo ".... Copying sources for $pkg"
			find "$BASE_DIR/rpm-centos/$pkg/" -type f ! -iname *.spec ! -iname *.srpm ! -iname *.rpm -exec cp {} $BASE_DIR/rpmbuild/SOURCES/ \;

			echo ""
	done
}

if [ -z "$1" ] || [ "$1" == "--help" ];
then
	echo "##################################################"
	echo "# RPM Build Env Builder                          #"
	echo "#                                                #"
	echo "# Usage: buildenv.sh [--help | --setup-centos]   #"
	echo "#                                                #"
	echo "# --help                                         #"
	echo "#     Prints out this message                    #"
	echo "#                                                #"
	echo "# --setup-centos                                 #"
	echo "#     Sets up a centos build env                 #"
	echo "#                                                #"
	echo "# ---------------------------------------------- #"
	echo "# WARNING                                        #"
	echo "#     This will over write stuff                 #"
	echo "##################################################"

else if [ "$1" == "--setup-centos" ];
then
	initial_check

	echo "Starting setup";	
	setup_centos

else
	echo "I have no idea what you want me to do";
	exit 1;
fi
fi
