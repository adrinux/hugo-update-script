#!/bin/bash
# Version 0.21.0  8:26 PST, Nov 9, 2018
# inspried from this forum post  https://discourse.gohugo.io/t/script-to-install-latest-hugo-release-on-macos-and-ubuntu/14774/10
# if you have run into github api anonymous access limits which happens during debugging/dev then add user and token here or sourced from a separate file
# . ~/githubapitoken
#GITHUB_USER=""
#GITHUB_TOKEN=""

if [ "$GITHUB_TOKEN" != "" ]; then
echo using access token with script
echo $GITHUB_USER $GITHUB_TOKEN
fi

EXTENDED=false
FORCE=false
EFILE=""


# options
# e - download and install the extended version
# c - use 'hugoe' as the install command for extended version otherwise 'hugo' will launch extended version
# f - force download/overwrite of same version


while getopts 'ecf' OPTION; do
  case "$OPTION" in
    e)
      echo "installing extended hugo"
      EXTENDED=true
      ;;
    c)
        if [ $EXTENDED = true ]; then
        EFILE="e"
        echo using hugoe for extended command
      fi
        ;;
    f)
        echo "FORCING download/overwrite"
        FORCE=true
      ;;
  esac
done

shift $(( OPTIND - 1 ))

DEFAULT_BIN_DIR="/usr/local/bin"
# Single optional argument is directory in which to install hugo
BIN_DIR=${1:-"$DEFAULT_BIN_DIR"}

BIN_PATH="$(which hugo$EFILE)"
declare -A ARCHES
ARCHES=( ["arm64"]="ARM64" ["aarch64"]="ARM64"  ["x86_64"]="64bit" ["arm32"]="ARM"  ["armhf"]="ARM" )
ARCH=$(arch)

if [ -z "${ARCHES[$ARCH]}" ]; then
  echo  Your machine kernel architecture $ARCH is not supported by this script, aborting
  exit 1
fi


INSTALLED="$(hugo$EFILE version 2>/dev/null | cut -d'v' -f2 | cut -c 1-6)"
CUR_VERSION=${INSTALLED:-"None"}
echo $(curl -u $GITHUB_USER:$GITHUB_TOKEN -s https://api.github.com/repos/gohugoio/hugo/releases/latest | grep tag_name)
NEW_VERSION="$(curl -u $GITHUB_USER:$GITHUB_TOKEN -s https://api.github.com/repos/gohugoio/hugo/releases/latest  \
             | grep tag_name \
             | cut -d'v' -f2 | cut -c 1-6)"

echo "Hugo `[ $EXTENDED == true ] && echo "Extended"`: Current  Version : $CUR_VERSION => New Version: $NEW_VERSION"

if [ -z "$NEW_VERSION" ]; then
  echo  Unable to retrieve new version number - Likely you have reached github anonymous limit
  echo  set environment variable `$GITHUB_USER` and `$GITHUB_TOKEN` and try again
  exit 1
fi

if ! [ $NEW_VERSION = $CUR_VERSION ] || [ $FORCE = true ]; then

  pushd /tmp/ > /dev/null

  URL=$(curl -u $GITHUB_USER:$GITHUB_TOKEN -s https://api.github.com/repos/gohugoio/hugo/releases/latest \
  | grep "browser_download_url.*hugo.*._Linux-${ARCHES[$ARCH]}\.tar\.gz" \
  | \
  if [ $EXTENDED = true ]; then
    grep "_extended"
  else
    grep -v "_extended"
  fi \
  | cut -d ":" -f 2,3 \
  | tr -d \" \
  )

  echo $URL

  echo "Installing version $NEW_VERSION `[ $EXTENDED == true ] && echo "Extended"`  "
  echo "This machine's architecture is $ARCH"
  echo "Downloading Tarball $URL"

   wget --user=-u $GITHUB_USER --password=$GITHUB_TOKEN -q $URL

   TARBALL=$(basename $URL)
  # TARBALL="$(find . -name "*Linux-${ARCHES[$ARCH]}.tar.gz" 2>/dev/null)"
  echo Expanding Tarball, $TARBALL
  tar -xzf $TARBALL hugo

  chmod +x hugo

if [ -w $BIN_DIR ]; then
  echo "Installing hugo to $BIN_DIR"
  mv hugo -f $BIN_DIR/hugo$EFILE
else
    echo "installing hugo to $BIN_DIR (sudo)"
    sudo mv -f hugo $BIN_DIR/hugo$EFILE
fi

rm $TARBALL

  popd > /dev/null

  echo Installing hugo `[ $EXTENDED == true ] && echo "extended"` as hugo$EFILE

  BIN_PATH="$(which hugo$EFILE)"
  if [ -z "$BIN_PATH" ]; then
  printf "WARNING: Installed Hugo Binary in $BIN_DIR is not in your environment path\nPATH=$PATH\n"
else
  if [ "$BIN_DIR/hugo$EFILE" != "$BIN_PATH" ]; then
  echo "WARNING: Just installed Hugo binary hugo$EFILE to, $BIN_DIR , conflicts with existing Hugo in $BIN_PATH"
  echo "add $BIN_DIR to path and delete $BIN_PATH"
else
  echo "--- Installation Confirmation ---"
  printf "New Hugo binary version at $BIN_PATH is\n $($BIN_PATH version)\n"
  fi
fi

else
  echo Latest version already installed at $BIN_PATH
fi