#FROM armhf/debian:jessie
FROM resin/armv7hf-debian-qemu:latest
# Default configuration
RUN [ "cross-build-start" ]
COPY mopidy.conf /var/lib/mopidy/.config/mopidy/mopidy.conf

RUN set -ex \
    # Official Mopidy install for Debian/Ubuntu along with some extensions
    # (see https://docs.mopidy.com/en/latest/installation/debian/ )
 && apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y \
        curl \
        gcc \
	gstreamer0.10-alsa \
	python-crypto \
	build-essential \
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
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* ~/.cache \
    # Limited access rights.
 && chown mopidy:audio -R /var/lib/mopidy/.config


# Add Tini
ENV TINI_VERSION v0.14.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini-armhf /tini
RUN chmod +x /tini
RUN [ "cross-build-end" ]
# Run as mopidy user
USER mopidy

VOLUME ["/var/lib/mopidy/local", "/var/lib/mopidy/media"]

EXPOSE 6600 6680

ENTRYPOINT ["/tini", "--"]

CMD ["/usr/bin/mopidy"]