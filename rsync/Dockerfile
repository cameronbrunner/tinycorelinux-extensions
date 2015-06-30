FROM tiny_dev:submit
VOLUME /scratch
# Need the openssl package to get certificate bundle
RUN tce-load -wci openssl-1.0.0
COPY build-rsync.sh /scratch/
COPY rsync.tcz.info.tmpl /scratch/
USER tc
CMD ["/bin/sh", "-c", "cd /scratch; /bin/sh ./build-rsync.sh"]
