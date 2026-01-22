#!/usr/bin/env bash
# download.sh
#
# Download a variable number of URLs into ./output
# Automatically chooses wget (preferred) or curl.
#
# Usage:
#   ./download.sh URL1 URL2 ... URLN
#
# Examples:
#   ./download.sh https://example.com/file1.zip https://example.com/file2.tgz
#   ./download.sh "https://example.com/some file.pdf"
#

if [ "$HIWEFAI_ROOT" == "" ]
then
  echo "HIWEFAI_ROOT not defined!"
  exit -1
fi

THISDIR=`pwd`
mkdir -p $THISDIR/data 2>/dev/null

# echo $@ > errors.log

for url in "$@"
do
    echo "$url"
    wget "$url" --directory-prefix=data --quiet --no-check-certificate
done

exit 0
