#!/bin/bash

DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get upgrade -y
ln -fs /usr/share/zoneinfo/America/New_York /etc/localtime
apt-get install -y tzdata
dpkg-reconfigure --frontend noninteractive tzdata

# get deps
apt-get install wget\
	libgmp-dev\
	libmpfr-dev\
	libmpc-dev\
	libncurses-dev\
	texinfo\
	gcc\
	g++\
	make\
	vim\
	tmux\
	ssh\
  git\
  nano\
  emacs\
  kakoune\
  micro\
  neovim\
    -y

# Create some directories and set the PATH
mkdir -p $HOME/os161
mkdir -p $HOME/os161/toolbuild
mkdir -p $HOME/os161/tools
mkdir -p $HOME/os161/tools/bin
export PATH=$HOME/os161/tools/bin:$PATH

# Download, build and install binutils. 

cd $HOME/os161/toolbuild

wget https://archive.org/download/gcc-4.8.3os161-2.1.tar/binutils-2.24%2Bos161-2.1.tar.gz
tar -zxf binutils-2.24+os161-2.1.tar.gz

cd binutils-2.24+os161-2.1
find . -name '*.info' | xargs touch
touch intl/plural.c
cd ..

cd binutils-2.24+os161-2.1
./configure --nfp --disable-werror --target=mips-harvard-os161 --prefix=$HOME/os161/tools
make
make install
cd ..

#Download, build, and install GCC-4.8
wget https://archive.org/download/gcc-4.8.3os161-2.1.tar/gcc-4.8.3%2Bos161-2.1.tar.gz
tar -zxf gcc-4.8.3+os161-2.1.tar.gz
cd gcc-4.8.3+os161-2.1

find . -name '*.info' | xargs touch
touch intl/plural.c
cd ..

mkdir buildgcc
cd buildgcc
../gcc-4.8.3+os161-2.1/configure --enable-languages=c,lto --nfp --disable-shared --disable-threads --disable-libmudflap --disable-libssp --disable-libstdcxx --disable-nls --target=mips-harvard-os161 --prefix=$HOME/os161/tools
cd ..

cd buildgcc
make

cd ../gcc-4.8.3+os161-2.1/
find . -name '*.info' | xargs touch
touch intl/plural.c
cd ..
cd buildgcc/
../gcc-4.8.3+os161-2.1/configure --enable-languages=c,lto --nfp --disable-shared --disable-threads --disable-libmudflap --disable-libssp --disable-libstdcxx --disable-nls --target=mips-harvard-os161 --prefix=$HOME/os161/tools

#build gcc
make
make install
cd ..

#Download, build, and install gdb 7.8
wget https://archive.org/download/gcc-4.8.3os161-2.1.tar/gdb-7.8%2Bos161-2.1.tar.gz
tar -zxf gdb-7.8+os161-2.1.tar.gz

cd gdb-7.8+os161-2.1
find . -name '*.info' | xargs touch
touch intl/plural.c
cd ..

cd gdb-7.8+os161-2.1
CC="gcc -std=gnu89" ./configure --target=mips-harvard-os161 --prefix=$HOME/os161/tools
make
make install
cd ..

#Download, build, and install the simulator sys161-2.0.8 
wget https://archive.org/download/gcc-4.8.3os161-2.1.tar/sys161-2.0.8.tar.gz
tar -zxf sys161-2.0.8.tar.gz

cd sys161-2.0.8
./configure --prefix=$HOME/os161/tools mipseb
make
make install
cd ..

#Download, build, and install the simulator bmake 
wget https://archive.org/download/gcc-4.8.3os161-2.1.tar/bmake-20101215.tar.gz
wget https://archive.org/download/gcc-4.8.3os161-2.1.tar/mk-20100612.tar.gz
tar -zxf bmake-20101215.tar.gz
cd bmake
tar -zxf ../mk-20100612.tar.gz
cd ..

cd bmake
./configure --prefix=$HOME/os161/tools --with-default-sys-path=$HOME/os161/tools/share/mk
sh ./make-bootstrap.sh
mkdir -p $HOME/os161/tools/bin
mkdir -p $HOME/os161/tools/share/man/man1
mkdir -p $HOME/os161/tools/share/mk
cp bmake $HOME/os161/tools/bin/
cp bmake.1 $HOME/os161/tools/share/man/man1/
sh mk/install-mk $HOME/os161/tools/share/mk
cd ..

#Create symlinks for very long command name 
cd $HOME/os161/tools/bin
sh -c 'for f in mips-harvard-*; do nf=`echo $f | sed -e s/mips-harvard-//`; ln -s $f $nf ; done'

#Add ~/os161/tools/bin to the PATH permanently
echo "export PATH=$HOME/os161/tools/bin:$PATH" >> ~/.bashrc

#Create the OS/161 root directory 
export PATH=$HOME/os161/tools/bin:$PATH
mkdir -p $HOME/os161/root

#Download the OS/161 source code:
cd $HOME/os161/toolbuild/
wget https://archive.org/download/gcc-4.8.3os161-2.1.tar/os161-base-2.0.3.tar.gz
#Extract the source files: 
tar -zxf os161-base-2.0.3.tar.gz

#Set the PATH
export PATH=$HOME/os161/tools/bin:$PATH
mkdir -p $HOME/os161/root

#Ensure that $HOME/os161/src points to your os161 source-code tree
mv $HOME/os161/toolbuild/os161-base-2.0.3 $HOME/os161/src
cd $HOME/os161/src

#Configure userland tools
./configure --ostree=$HOME/os161/root

bmake includes
bmake depend
bmake
bmake install

#Configure kernel with the sample DUMBVM configuration
cd kern/conf/
./config DUMBVM

#Compile kernel with the DUMBVM configuration
cd ../compile/DUMBVM
bmake depend
bmake 
bmake install

# make  sys161.conf configuration file
cd ${HOME}/os161/root/ 
cp $HOME/os161/toolbuild/sys161-2.0.8/sys161.conf.sample sys161.conf

# Create two disk files of 25MB each
cd ${HOME}/os161/root/ 
disk161 create LHD0.img 25M
disk161 create LHD1.img 25M

