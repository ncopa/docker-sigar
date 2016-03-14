FROM alpine:latest

RUN set -ex \
	&& apk add -u --no-cache --virtual .build-deps \
		git gcc libc-dev make cmake libtirpc-dev pax-utils \
	&& mkdir -p /usr/src \
	&& cd /usr/src \
	&& git clone --branch sigar-musl https://github.com/ncopa/sigar.git \
	&& mkdir sigar/build \
	&& cd sigar/build \
	&& CFLAGS="-std=gnu89" cmake .. \
	&& make -j$(getconf _NPROCESSORS_ONLN) \
	&& make install \
	&& runDeps="$( \
		scanelf --needed --nobanner --recursive /usr/local \
			| awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
			| sort -u \
			| xargs -r apk info --installed \
			| sort -u \
	)" \
	&& apk add --virtual .libsigar-rundeps $runDeps \
	&& apk del .build-deps \
	&& rm -rf /usr/src/sigar

