#!/bin/bash
#############################################################
# Simple bash script to rebuild my rpm build environment    #
# Might be of use to other people.                          #
#                                                           #
# Expects a clean env and pulls down data from github.      #
#############################################################

BASE_REPO="https://github.com/DamianZaremba/rpm.git";
INSTALL_DIR="/home/rpmbuilder"

function initial_check {
	cd $INSTALL_DIR
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
	cat > "$INSTALL_DIR/.rpmmacros" <<EOF
%_topdir $INSTALL_DIR/rpmbuild
%packager Damian Zaremba <damian@damianzaremba.co.uk>
EOF

	echo "Setting up git stuff"
	cat > "$INSTALL_DIR/.gitconfig" <<EOF
[user]
	email = damian@damianzaremba.co.uk
	name = Damian Zaremba
EOF
}

function setup {
	type=$1
	setup_rpm_stuff

	if [ -d "$BASE_DIR/rpmbuild" ];
	then
		echo "We are already setup - bailing!";
		exit 1;
	else
		cd $BASE_DIR
		git clone $BASE_REPO -b $type
		cd "$INSTALL_DIR/rpmbuild"
	fi
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
	echo "# --setup <type>                                 #"
	echo "#     Sets up a <type> build env                 #"
	echo "#                                                #"
	echo "# ---------------------------------------------- #"
	echo "# WARNING                                        #"
	echo "#     This will over write stuff                 #"
	echo "##################################################"

else if [ "$1" == "--setup" && "$2" -ne "" ];
then
	initial_check

	echo "Starting setup";	
	setup $2
	exit 0;
else
	echo "I have no idea what you want me to do";
	exit 1;
fi
fi
