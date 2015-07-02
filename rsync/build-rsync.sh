#!/bin/bash
set -e
set -x

WORK_DIR="/scratch"
BUNDLE_DIR="$WORK_DIR/bundle"
RSYNC_BASE="https://download.samba.org/pub/rsync"
RSYNC_ARCHIVE="rsync-3.1.1.tar.gz"
RSYNC_URL="$RSYNC_BASE/$RSYNC_ARCHIVE"
RSYNC_DIR=`echo $RSYNC_ARCHIVE | sed 's/\.tar\.gz//'`

sudo chown -R tc: /scratch

cd $WORK_DIR
wget $RSYNC_URL -O $RSYNC_ARCHIVE
tar xzvf $RSYNC_ARCHIVE

cd $RSYNC_DIR

# Tiny core linux recommended args (from http://wiki.tinycorelinux.net/wiki:creating_extensions)
export CFLAGS="-mtune=generic -Os -pipe"
export CXXFLAGS="-mtune=generic -Os -pipe"
export LDFLAGS="-Wl,-O1"

# Build with recommended prefix
./configure --prefix=/usr/local
make
make test
make DESTDIR=/tmp/package install

# Strip as recommended
cd /tmp/package
find . | xargs file | grep "executable" | grep ELF | grep "not stripped" | cut -f 1 -d : | xargs strip --strip-unneeded 2> /dev/null || find . | xargs file | grep "shared object" | grep ELF | grep "not stripped" | cut -f 1 -d : | xargs strip -g 2> /dev/null

# Build FS
cd /tmp
mksquashfs package rsync.tcz 
cd /tmp/package
find usr -not -type d > rsync.tcz.list

# Stage out
mkdir -p $BUNDLE_DIR
mv /tmp/package/rsync.tcz.list $BUNDLE_DIR
mv /tmp/rsync.tcz $BUNDLE_DIR
cd $BUNDLE_DIR
# Generate deps
echo "acl.tcz" > rsync.tcz.dep
echo "attr.tcz" >> rsync.tcz.dep


# MD5 Sum for submission
md5sum rsync.tcz > rsync.tcz.md5.txt
SIZE=`du -h rsync.tcz | awk '{ print $1 }'`
sed  "s/%%SIZE%%/$SIZE/" $WORK_DIR/rsync.tcz.info.tmpl > $BUNDLE_DIR/rsync.tcz.info

# See if we can loopback mount...
TMPDIR=`mktemp -d`
if sudo mount -o loop -t squashfs $BUNDLE_DIR/rsync.tcz $TMPDIR; then
   sudo umount $TMPDIR
   sudo submitqc5
else
   echo "Skipping submit tests since --privileged was not specified"
fi
