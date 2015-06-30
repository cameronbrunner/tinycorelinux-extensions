# Rsync Extenstion

Builds a container to build a 64 bit rsync extension.  Downloads
rsync-3.1.1 and follows recommended TCL build procedure.  Requires
the images in the `../dev-images/` directory.

## Build docker image
`./build-image.sh`

## Build rsync

If you plan on doing a submission first update rsync.tcz.info.tmpl with your TCL user name.

* If you want to run the submission tests
`mkdir bundle`
`docker run -t -i  -v `pwd`/bundle:/scratch/bundle --privileged tiny_dev:rsync`

* If you want to run the submission tests somewhere else or don't want --privileged
`mkdir bundle`
`docker run -t -i  -v `pwd`/bundle:/scratch/bundle tiny_dev:rsync`

The output files will be in '`pwd`/bundle'.
