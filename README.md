# armv5-OpenSSH
Dynamically & statically linked Portable OpenSSH for armv5

# Building

Run below commands in Colab (for very small binaries size):

```
%%writefile compile.sh

apt-get update
apt install autoconf build-essential ca-certificates -y

cd /content

curl -O https://uclibc.org/downloads/binaries/0.9.30/cross-compiler-armv5l.tar.bz2
tar xf cross-compiler-armv5l.tar.bz2
export PATH=/content/cross-compiler-armv5l/bin/:$PATH

git clone https://github.com/openssh/openssh-portable
cd openssh-portable
autoreconf

./configure CC=armv5l-gcc LD=armv5l-ld --host=armv5l --with-zlib=no --with-openssl=no
sed -i 's/\-fstack\-protector//g' Makefile
make
```

Or running below commands in Colab is better (different compiler and options):

```
%%writefile compile.sh

apt-get update
apt install autoconf build-essential gcc-arm-linux-gnueabi ca-certificates

cd /content

wget https://www.openssl.org/source/old/1.1.0/openssl-1.1.0j.tar.gz
tar -xvf openssl-1.1.0j.tar.gz
cd openssl-1.1.0j
./Configure gcc -static -no-shared --prefix=/home/user --cross-compile-prefix=arm-linux-gnueabi-
make
make install

cd /content

git clone https://github.com/openssh/openssh-portable
cd openssh-portable
autoreconf

./configure --target=arm-linux-gnueabi --host=arm-linux-gnueabi --with-ldflags=-static --with-zlib=no --with-ssl-dir=/home/user
make
```

Then run:

```
!chmod -c 755 compile.sh
!./compile.sh
```

# Releases

Statically linked OpenSSH binaries for armv5 by means of building with second Colab commands are compressed in OpenSSH-binaries-beta.zip file, In case if it is encouraged with `No user exist for uid xxxxxx` error then compile it with PAM libraries again and maybe it will work

Dynamically linked OpenSSH binaries for armv5 by means of building with second Colab commands without `--with-ldflags=-static` switch are compressed in Dynamically-Linked-OpenSSH-binaries.zip file which is tested and will work 

Note*: if you use dynamically linked OpenSSH place below shared libraries (for arm architecture) in "/lib" folder:

```
ld-linux.so.3
libc.so.6
libdl.so.2
libresolv.so.2
```

Or simply place shared libraries in same folder with binaries, And load shared libraries for each binary by running below command for example:
```
./ld-linux.so.3 --library-path . ./ssh
```

![image](https://github.com/marzban2030/armv5-OpenSSH/raw/main/Screenshot.jpg)

# Usage 

In read-only filesystem devices (squashfs firmware cameras) there is no write access to `/lib` folder to placing shared libraries and there is no write access to home or root directory to creating `.ssh` folder and its contents by OpenSSH to authorizing hosts and keys inorder to remote port forwarding and so on, So after generating and authorizing the keys from any system to remote host, Put the private key from `~/.ssh/id_rsa` to `/mnt/mtd` folder in read-only filesystem device and place the dynamically linked OpenSSH binaries with shared libraries from releases to an inserted microSD card into device and run below command under `/mnt/sdcard` working path directory:

`./ld-linux.so.3 --library-path . ./ssh -R 23:127.0.0.1:23 -R 21:127.0.0.1:21 -i /mnt/mtd/id_rsa -o UserKnownHostsFile=/mnt/mtd/known_hosts root@REMOTE_HOST_ADDRESS -p 22`

The above command load shared libraries which are located in same folder with OpenSSH binaries and execute the `ssh` command with its arguments. 

Above arguments for `ssh` command forward telnet and ftp ports (23 and 21) from device to remote host, Also identify via private key which is at `/mnt/mtd/id_rsa` without asking password everytime. And above arguments use `/mnt/mtd/known_hosts` path instead of its default `~/.ssh/known_hosts` path for verifying remote host keys fingerprint by asking once time only (you can use `-o StrictHostKeyChecking=no` switch and option to disable checking remote host key fingerprint).

So device will be accessible in remote host, Or it will be visible in the internet behind NAT by running above command everytime.

You can use the -f switch to requesting ssh to run in background just before command execution.

In addition the -N switch can be omitted, as it doesn't enable ssh command execution, it's there to be useful when forwarding ports. And -tt switch can be used for bash script environment for ssh command.

*Hint: In this remote port forwarding argument`-R 0.0.0.0:23:127.0.0.1:23`, The local device will be accessible from all IP addresses of remote server.

*Note: options list under `-o` switch for `ssh` command is available in `ssh_config` file at portable OpenSSH source https://github.com/openssh/openssh-portable
