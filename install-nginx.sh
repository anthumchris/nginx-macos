#!/usr/bin/env bash

# Exit on errors
set -e

# INSTALLATION DESTINATION - All files will be installed at the path below and
# self-contained within that folder, including config, logs, etc.
#
#INSTALL_PREFIX=/usr/local/nginx
INSTALL_PREFIX=$PWD/build/nginx

echo -e "Nginx will build and install at the location below. This should complete in < 5 minutes.\n"
echo -e "    $INSTALL_PREFIX\n"

# EXIT without confirmation
while [[ ! $REPLY =~ ^[nNyY]$ ]] ; do read -rp "Start installation? [y/n] "; done
[[ $REPLY =~ ^[nN]$ ]] && exit 0

# Install required Git submodules
if [[ ! (-e nginx/.git && -e nginx-njs/.git && -e openssl/.git) ]] ; then
  echo -e "\nInitializing Git submodules...\n"
  git submodule update --init

  echo -e "\nUpdating Git submodules to latest versions...\n"
  # Update submodules to latest version and print version
  git submodule foreach 'git submodule update --remote --merge; git describe --tags; echo'
fi

echo -e "\nConfiguring Nginx...\n"
cd nginx
ln -sf auto/configure configure
./configure \
  --add-module=../nginx-njs/nginx \
  --prefix=$INSTALL_PREFIX \
  --with-cc-opt='-O2 -pipe -fPIE -fPIC -Werror=format-security -D_FORTIFY_SOURCE=2' \
  --with-compat \
  --with-http_ssl_module \
  --with-http_v2_module \
  --with-openssl=../openssl \
  --with-threads \
  ;

echo -e "\nBuilding (a few minutes may pass with no output)...\n"
make 1>/dev/null --quiet  --jobs=`sysctl -n hw.ncpu` # Faster, parallel build using number of cores

echo -e "\nInstalling..."
make --quiet install

cd .. 

# Remove newly-created submodule files that Git detects as "Changes not staged for commit"
# Disable cleanup for repeated builds or changes in Nginx ./configure
echo -e "Cleaning up...\n"
git submodule foreach git clean -qfd 1>/dev/null

RELATIVE_PATH=${INSTALL_PREFIX#$PWD/}
cat <<ENDGINX
╔═══════════════════════════════════════════════════════════════════════════════
║
║   🎉  Nginx was built successfully. Test command:
║
║           $RELATIVE_PATH/sbin/nginx -t
║
╚═══════════════════════════════════════════════════════════════════════════════
ENDGINX
