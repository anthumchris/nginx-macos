#!/usr/bin/env bash

# Exit on errors
set -e

PREFIX=$PWD/build
PREFIX_OPENSSL=$PREFIX/openssl
MAKE_JOBS=`sysctl -n hw.ncpu` # Faster, parallel build using number of cores

# INSTALLATION DESTINATION - All files will be installed at the path below and
# self-contained within that folder, including config, logs, etc.
#PREFIX_NGINX=/usr/local/nginx
PREFIX_NGINX=$PREFIX/nginx

echo -e "Nginx will build and install at the location below. This should complete in < 5 minutes.\n"
echo -e "    $PREFIX_NGINX\n"

# EXIT without confirmation
while [[ ! $REPLY =~ ^[nNyY]$ ]] ; do read -rp "Start installation? [y/n] "; done
[[ $REPLY =~ ^[nN]$ ]] && exit 0

echo -e "\nInitializing Git submodules...\n"
git submodule update --init
git submodule --quiet foreach 'printf "%-10s %s\n" $name: `git describe --tags 2>/dev/null || echo -`'

# Build Openssl once
if [[ ! (-e $PREFIX_OPENSSL/include/openssl) ]] ; then
  echo -e "\nOpenssl configuring...\n"
  cd src/openssl
  ./config --prefix=$PREFIX_OPENSSL no-shared no-threads
  echo -e "\nOpenssl building...\n"
  make 1>/dev/null --quiet --jobs=$MAKE_JOBS
  echo -e "\nOpenssl installing...\n"
  make --quiet install_sw
  cd ../..
fi

echo -e "\nNginx configuring...\n"
cd src/nginx
ln -sf auto/configure configure
./configure \
  --add-module=../nginx-njs/nginx \
  --prefix=$PREFIX_NGINX \
  --with-cc-opt="-I$PREFIX_OPENSSL/include -O2 -pipe -fPIE -fPIC -Werror=format-security -D_FORTIFY_SOURCE=2" \
  --with-ld-opt="-L$PREFIX_OPENSSL/lib" \
  \
  --with-http_ssl_module \
  --with-http_v2_module \
  ;

echo -e "\nNginx building (a few minutes may pass with no output)...\n"
make 1>/dev/null --quiet --jobs=$MAKE_JOBS

echo -e "\nNginx nstalling..."
make --quiet install

cd ../..

# Remove newly-created submodule files that Git detects as "Changes not staged for commit"
# Disable cleanup for repeated builds or changes in Nginx ./configure
echo -e "Cleaning up...\n"
git submodule foreach git clean -qfd 1>/dev/null

RELATIVE_PATH=${PREFIX_NGINX#$PWD/}
cat <<ENDGINX
╔═══════════════════════════════════════════════════════════════════════════════
║
║   🎉  Nginx was built successfully. Test commands:
║
║           $RELATIVE_PATH/sbin/nginx -t
║           $RELATIVE_PATH/sbin/nginx -V
║
╚═══════════════════════════════════════════════════════════════════════════════
ENDGINX
