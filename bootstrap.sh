#! /bin/bash

##########################################################
# This function is simply a banner to introduce the script
##########################################################
banner()
{
	echo "|------------------------------------------|"
	echo "|----- Welcome to the redox bootstrap -----|"
	echo "|------------------------------------------|"
}

###################################################################################
# This function takes care of installing a dependency via package manager of choice
# for building redox on MacOS.
# @params:    $1 package manager
#            $2 package name
#            $3 binary name (optional)
###################################################################################
install_macos_pkg()
{
    PKG_MANAGER=$1
    PKG_NAME=$2
    BIN_NAME=$3
    if [ -z "$BIN_NAME" ]; then
        BIN_NAME=$PKG_NAME
    fi

    BIN_LOCATION=$(which $BIN_NAME || true)
    if [ -z "$BIN_LOCATION" ]; then
        echo "$PKG_MANAGER install $PKG_NAME"
        $PKG_MANAGER install "$PKG_NAME"
    else
        echo "$BIN_NAME already exists at $BIN_LOCATION, no need to install $PKG_NAME..."
    fi
}

install_macports_pkg()
{
    install_macos_pkg "sudo port" "$1" "$2"
}

install_brew_pkg()
{
    install_macos_pkg "brew" $@
}

install_brew_cask_pkg()
{
    install_macos_pkg "brew cask" $@
}

###############################################################################
# This function checks which of the supported package managers
# is available on the OSX Host.
# If a supported package manager is found, it delegates the installing work to
# the relevant function.
# Otherwise this function will exit this script with an error.
###############################################################################
osx()
{
    echo "Detected OSX!"

    if [ ! -z "$(which brew)" ]; then
        osx_homebrew $@
    elif [ ! -z "$(which port)" ]; then
        osx_macports $@
    else
        echo "Please install either Homebrew or MacPorts, if you wish to use this script"
        echo "Re-run this script once you installed one of those package managers"
        echo "Will not install, now exiting..."
        exit 1
    fi
}

###############################################################################
# This function takes care of installing all dependencies using MacPorts
# for building redox on Mac OSX
# @params:    $1 the emulator to install, virtualbox or qemu
###############################################################################
osx_macports()
{
    echo "Macports detected! Now updating..."
    sudo port -v selfupdate

    echo "Installing missing packages..."

    install_macports_pkg "git"

    if [ "$1" == "qemu" ]; then
        install_macports_pkg "qemu" "qemu-system-x86_64"
    else
        install_macports_pkg "virtualbox"
    fi

    install_macports_pkg "coreutils"
    install_macports_pkg "findutils"
    install_macports_pkg "nasm"
    install_macports_pkg "pkgconfig"
    install_macports_pkg "osxfuse"
    install_macports_pkg "cmake"
    install_macports_pkg "wget"
}

###############################################################################
# This function takes care of installing all dependencies using Homebrew
# for building redox on Mac OSX
# @params:    $1 the emulator to install, virtualbox or qemu
###############################################################################
osx_homebrew()
{
    echo "Homebrew detected! Now updating..."
    brew update

    echo "Installing missing packages..."

    install_brew_pkg "git"

    if [ "$1" == "qemu" ]; then
        install_brew_pkg "qemu" "qemu-system-x86_64"
    else
        install_brew_pkg "virtualbox"
    fi

    install_brew_pkg "coreutils"
    install_brew_pkg "findutils"
    install_brew_pkg "nasm"
    install_brew_pkg "pkg-config"
    install_brew_pkg "cmake"
    install_brew_cask_pkg "osxfuse"
    install_brew_pkg "wget"

	# the gcc contrib script makes use of the unprefixed name
	ln -sf $(brew --prefix)/bin/gsha1sum $(brew --prefix)/bin/sha1sum
	ln -sf $(brew --prefix)/bin/gsha224sum $(brew --prefix)/bin/sha224sum
	ln -sf $(brew --prefix)/bin/gsha256sum $(brew --prefix)/bin/sha256sum
	ln -sf $(brew --prefix)/bin/gsha384sum $(brew --prefix)/bin/sha384sum
	ln -sf $(brew --prefix)/bin/gsha512sum $(brew --prefix)/bin/sha512sum
}

###############################################################################
# This function takes care of installing all dependencies for building redox on
# Arch linux
# @params:	$1 the emulator to install, virtualbox or qemu
###############################################################################
archLinux()
{
	echo "Detected Arch Linux"
	packages="cmake fuse git gperf perl-html-parser nasm wget"
	if [ "$1" == "qemu" ]; then
		packages="$packages qemu"
	elif [ "$1" == "virtualbox" ]; then
		packages="$packages virtualbox"
	fi

	echo "Updating system..."
	sudo pacman -Syu

	echo "Installing packages $packages..."
	sudo pacman -S --needed $packages
}

###############################################################################
# This function takes care of installing all dependencies for building redox on
# debian based linux
# @params:	$1 the emulator to install, virtualbox or qemu
# 		$2 the package manager to use
###############################################################################
ubuntu()
{
	echo "Detected Ubuntu/Debian"
	echo "Updating system..."
	sudo "$2" update
	echo "Installing required packages..."
	sudo "$2" install build-essential libc6-dev-i386 nasm curl file git libfuse-dev fuse pkg-config cmake autopoint autoconf libtool m4 syslinux-utils genisoimage flex bison gperf libpng-dev libhtml-parser-perl
	if [ "$1" == "qemu" ]; then
		if [ -z "$(which qemu-system-x86_64)" ]; then
			echo "Installing QEMU..."
			sudo "$2" install qemu-system-x86 qemu-kvm
		else
			echo "QEMU already installed!"
		fi
	else
		if [ -z "$(which virtualbox)" ]; then
			echo "Installing Virtualbox..."
			sudo "$2" install virtualbox
		else
			echo "Virtualbox already installed!"
		fi
	fi
}

###############################################################################
# This function takes care of installing all dependencies for building redox on
# fedora linux
# @params:	$1 the emulator to install, virtualbox or qemu
###############################################################################
fedora()
{
	echo "Detected Fedora"
	if [ -z "$(which git)" ]; then
		echo "Installing git..."
		sudo dnf install git-all
	fi
	if [ "$1" == "qemu" ]; then
		if [ -z "$(which qemu-system-x86_64)" ]; then
			echo "Installing QEMU..."
			sudo dnf install qemu-system-x86 qemu-kvm
		else
			echo "QEMU already installed!"
		fi
	else
		if [ -z "$(which virtualbox)" ]; then
			echo "Installing virtualbox..."
			sudo dnf install virtualbox
		else
			echo "Virtualbox already installed!"
		fi
	fi
	# Use rpm -q <package> to check if it's already installed
	PKGS=$(for pkg in gcc gcc-c++ glibc-devel.i686 nasm make fuse-devel cmake; do rpm -q $pkg > /dev/null; [ $? -ne 0 ] && echo $pkg; done)
	# If the list of packages is not empty, install missing
	COUNT=$(echo $PKGS | wc -w)
	if [ $COUNT -ne 0 ]; then
					echo "Installing necessary build tools..."
					sudo dnf install $PKGS
	fi
}

###############################################################################
# This function takes care of installing all dependencies for building redox on
# *suse linux
# @params:	$1 the emulator to install, virtualbox or qemu
###############################################################################
suse()
{
	echo "Detected SUSE Linux"
	if [ -z "$(which git)" ]; then
		echo "Installing git..."
		zypper install git
	fi
	if [ "$1" == "qemu" ]; then
		if [ -z "$(which qemu-system-x86_64)" ]; then
			echo "Installing QEMU..."
			sudo zypper install qemu-x86 qemu-kvm
		else
			echo "QEMU already installed!"
		fi
	else
		if [ -z "$(which virtualbox)" ]; then
			echo "Please install Virtualbox and re-run this script,"
			echo "or run with -e qemu"
			exit
		else
			echo "Virtualbox already installed!"
		fi
	fi
	echo "Installing necessary build tools..."
	sudo zypper install gcc gcc-c++ glibc-devel-32bit nasm make fuse-devel cmake
}

##############################################################################
# This function takes care of installing all dependencies for building redox on
# gentoo linux
# @params:	$1 the emulator to install, virtualbox or qemu
##############################################################################
gentoo()
{
	echo "Detected Gentoo Linux"
	if [ -z "$(which nasm)" ]; then
		echo "Installing nasm..."
		sudo emerge dev-lang/nasm
	fi
	if [ -z "$(which git)" ]; then
		echo "Installing git..."
		sudo emerge dev-vcs/git
	fi
	if [ -z "$(which fusermount)" ]; then
		echo "Installing fuse..."
		sudo emerge sys-fs/fuse
	fi
	if [ "$2" == "qemu" ]; then
		if [ -z "$(which qemu-system-x86_64)" ]; then
			echo "Please install QEMU and re-run this script"
			echo "Step1. Add QEMU_SOFTMMU_TARGETS=\"x86_64\" to /etc/portage/make.conf"
			echo "Step2. Execute \"sudo emerge app-emulation/qemu\""
		else
			echo "QEMU already installed!"
		fi
	fi
	if [ -z "$(which cmake)" ]; then
		echo "Installing cmake..."
		sudo emerge dev-util/cmake
	fi
}

##############################################################################
# This function takes care of installing all dependencies for building redox on
# SolusOS
# @params:	$1 the emulator to install, virtualbox or qemu
##############################################################################
solus()
{
	echo "Detected SolusOS"

	if [ "$1" == "qemu" ]; then
		if [ -z "$(which qemu-system-x86_64)" ]; then
			sudo eopkg it qemu
		else
			echo "QEMU already installed!"
		fi
	else
		if [ -z "$(which virtualbox)" ]; then
			echo "Please install Virtualbox and re-run this script,"
			echo "or run with -e qemu"
			exit
		else
			echo "Virtualbox already installed!"
		fi
	fi

	echo "Installing necessary build tools..."
	#if guards are not necessary with eopkg since it does nothing if latest version is already installed
	sudo eopkg it fuse-devel git gcc g++ libgcc-32bit libstdc++-32bit nasm make cmake
}

######################################################################
# This function outlines the different options available for bootstrap
######################################################################
usage()
{
	echo "------------------------"
	echo "|Redox bootstrap script|"
	echo "------------------------"
	echo "Usage: ./bootstrap.sh"
	echo "OPTIONS:"
	echo
	echo "   -h,--help      Show this prompt"
	echo "   -u [branch]    Update git repo and update rust"
	echo "                  If blank defaults to master"
	echo "   -s             Check the status of the current travis build"
	echo "   -e [emulator]  Install specific emulator, virtualbox or qemu"
	echo "   -p [package    Choose an Ubuntu package manager, apt-fast or"
	echo "       manager]   aptitude"
	echo "   -d             Only install the dependencies, skip boot step"
	echo "EXAMPLES:"
	echo
	echo "./bootstrap.sh -e qemu"
	exit
}

####################################################################################
# This function takes care of everything associated to rust, and the version manager
# That controls it, it can install rustup and uninstall multirust as well as making
# sure that the correct version of rustc is selected by rustup
####################################################################################
rustInstall() {
	# Check to see if multirust is installed, we don't want it messing with rustup
	# In the future we can probably remove this but I believe it's good to have for now
	if [ -e /usr/local/lib/rustlib/uninstall.sh ] ; then
		echo "It appears that multirust is installed on your system."
		echo "This tool has been deprecated by the maintainer, and will cause issues."
		echo "This script can remove multirust from your system if you wish."
		printf "Uninstall multirust (y/N):"
		read multirust
		if echo "$multirust" | grep -iq "^y" ;then
			sudo /usr/local/lib/rustlib/uninstall.sh
		else
			echo "Please manually uninstall multirust and any other versions of rust, then re-run bootstrap."
			exit
		fi
	else
		echo "Old multirust not installed, you are good to go."
	fi
	# If rustup is not installed we should offer to install it for them
	if [ -z "$(which rustup)" ]; then
		echo "You do not have rustup installed."
		echo "We HIGHLY recommend using rustup."
		echo "Would you like to install it now?"
		echo "*WARNING* this involves a 'curl | sh' style command"
		printf "(y/N): "
		read rustup
		if echo "$rustup" | grep -iq "^y" ;then
			#install rustup
			curl https://sh.rustup.rs -sSf | sh -s -- --default-toolchain nightly
			# You have to add the rustup variables to the $PATH
			echo "export PATH=\"\$HOME/.cargo/bin:\$PATH\"" >> ~/.bashrc
			# source the variables so that we can execute rustup commands in the current shell
			source ~/.cargo/env
			rustup default nightly
		else
			echo "Rustup will not be installed!"
		fi
	fi
	#
	if [ -z "$(which rustc)" ]; then
		echo "Rust is not installed"
		echo "Please either run the script again, accepting rustup install"
		echo "or install rustc nightly manually (not recommended) via:"
		echo "\#curl -sSf https://static.rust-lang.org/rustup.sh | sh -s -- --channel=nightly"
		exit
	fi
	# If the system has rustup installed then update rustc to the latest nightly
	if hash 2>/dev/null rustup; then
		rustup update nightly
		rustup default nightly
	fi
	# Check to make sure that the default rustc is the nightly
	if echo "$(rustc --version)" | grep -viq "nightly" ;then
		echo "It appears that you have rust installed, but it"
		echo "is not the nightly version, please either install"
		echo "the nightly manually (not recommended) or run this"
		echo "script again, accepting the rustup install"
		echo
	else
		echo "Your rust install looks good!"
		echo
	fi
}

####################################################################
# This function gets the current build status from travis and prints
# a message to the user
####################################################################
statusCheck() {
	for i in $(echo "$(curl -sf https://api.travis-ci.org/repositories/redox-os/redox.json)" | tr "," "\n")
	do
		if echo "$i" | grep -iq "last_build_status" ;then
			if echo "$i" | grep -iq "0" ;then
				echo
				echo "********************************************"
				echo "Travis reports that the last build succeeded!"
				echo "Looks like you are good to go!"
				echo "********************************************"
			elif echo "$i" | grep -iq "null" ;then
				echo
				echo "******************************************************************"
				echo "The Travis build did not finish, this is an error with its config."
				echo "I cannot reliably determine whether the build is succeeding or not."
				echo "Consider checking for and maybe opening an issue on gitlab"
				echo "******************************************************************"
			else
				echo
				echo "**************************************************"
				echo "Travis reports that the last build *FAILED* :("
				echo "Might want to check out the issues before building"
				echo "**************************************************"
			fi
		fi
	done
}

###########################################################################
# This function is the main logic for the bootstrap; it clones the git repo
# then it installs the rust version manager and the latest version of rustc
###########################################################################
boot()
{
	echo "Cloning gitlab repo..."
	git clone https://gitlab.redox-os.org/redox-os/redox.git --origin upstream --recursive
	rustInstall
	if [[ "`cargo install --list`" != *"xargo"* ]]; then
		cargo install xargo
	else
		echo "You have xargo installed already!"
	fi
	echo "Cleaning up..."
	rm bootstrap.sh
	echo
	echo "---------------------------------------"
	echo "Well it looks like you are ready to go!"
	echo "---------------------------------------"
	statusCheck
	echo "Run the following commands to build redox:"
	echo "cd redox"
	echo "make all"
	echo "make virtualbox or qemu"
	echo
	echo "      Good luck!"

	exit
}

if [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
	usage
elif [ "$1" == "-u" ]; then
	git pull upstream master
	git submodule update --recursive --init
	rustup update nightly
	exit
elif [ "$1" == "-s" ]; then
	statusCheck
	exit
fi

emulator="qemu"
defpackman="apt-get"
dependenciesonly=false
while getopts ":e:p:d" opt
do
	case "$opt" in
		e) emulator="$OPTARG";;
		p) defpackman="$OPTARG";;
		d) dependenciesonly=true;;
		\?) echo "I don't know what to do with that option, try -h for help"; exit;;
	esac
done

banner
if [ "Darwin" == "$(uname -s)" ]; then
	osx "$emulator"
else
	# Here we will use package managers to determine which operating system the user is using.

	# Arch linux
	if hash 2>/dev/null pacman; then
		archLinux "$emulator"
	# Suse and derivatives
	elif hash 2>/dev/null zypper; then
		suse "$emulator"
	# Debian or any derivative of it
	elif hash 2>/dev/null apt-get; then
		ubuntu "$emulator" "$defpackman"
	# Fedora
	elif hash 2>/dev/null dnf; then
		fedora "$emulator"
	# Gentoo
	elif hash 2>/dev/null emerge; then
		gentoo "$emulator"
	# SolusOS
	elif hash 2>/dev/null eopkg; then
		solus "$emulator"
	fi


fi

if [ "$dependenciesonly" = false ]; then
	boot
fi
