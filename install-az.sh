# make sure system is up-to-date
yum update

# get compilers and related tools
yum groupinstall -y "development tools"

# get libraries needed during compilation to enable all features of Python
yum install -y zlib-devel bzip2-devel openssl-devel ncurses-devel sqlite-devel readline-devel tk-devel gdbm-devel db4-devel libpcap-devel xz-devel expat-devel

# download python
wget http://python.org/ftp/python/2.7.13/Python-2.7.13.tar.xz
tar xf Python-2.7.13.tar.xz
cd Python-2.7.13
./configure --prefix=/usr/local --enable-unicode=ucs4 --enable-shared LDFLAGS="-Wl,-rpath /usr/local/lib"

# build
make && make altinstall

# download pip
wget https://bootstrap.pypa.io/get-pip.py
/usr/local/bin/python2.7 get-pip.py

# use pip to install az
/usr/local/bin/pip2.7 install azure-cli

# set the paths
echo '/usr/local/bin/python2.7 -Esm azure.cli "$@"' > /usr/bin/az
chmod +x /usr/bin/az
echo '/usr/local/bin/python2.7 -Esm azure.cli "$@"' > /usr/local/bin/az
