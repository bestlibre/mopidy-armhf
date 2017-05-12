FROM bestlibre/tiny-armhf:latest
# Default configuration
RUN [ "cross-build-start" ]

RUN set -ex \
    # Official Mopidy install for Debian/Ubuntu along with some extensions
    # (see https://docs.mopidy.com/en/latest/installation/debian/ )
 && apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y \
        curl \
        gcc \
	python-crypto \
	build-essential \
	gstreamer1.0-alsa \
 && curl -L https://apt.mopidy.com/mopidy.gpg -o /tmp/mopidy.gpg \
 && curl -L https://apt.mopidy.com/mopidy.list -o /etc/apt/sources.list.d/mopidy.list \
 && apt-key add /tmp/mopidy.gpg \
 && apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y \
        mopidy \
 && curl -L https://bootstrap.pypa.io/get-pip.py | python - \
 && pip install -U six \
 && pip install \
	pyasn1==0.1.8 \
	Mopidy-MusicBox-Webclient \
        Mopidy-Moped \
        Mopidy-GMusic \
 && apt-get purge --auto-remove -y \
        curl \
        gcc \
	build-essential \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* ~/.cache 
# Limited access rights.

RUN chown mopidy:audio -R /var/lib/mopidy/.config
RUN [ "cross-build-end" ]
# Run as mopidy user
USER mopidy

VOLUME ["/mopidy/data_dir", "/mopidy/cache", "/mopidy/media", "/mopidy/playlists"]

EXPOSE 6600 6680

ENTRYPOINT ["/tini", "--"]

CMD ["/usr/bin/mopidy"]
