FROM lsiobase/alpine:3.6
MAINTAINER sparklyballs

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"

# install build packages
RUN \
 apk add --no-cache --virtual=build-dependencies \
	cmake \
	ffmpeg-dev \
	g++ \
	gcc \
	git \
	jpeg-dev \
	libpng-dev \
	make \
	openjpeg-dev \
	python2-dev \
	binutils-libs \
	binutils \
	build-base \
	libgcc \
	make \
	pkgconfig \
	pcre \
	musl-dev \
	libc-dev \
	pcre-dev \
	zlib-dev

# install runtime packages
RUN \
 apk add --no-cache \
	curl \
	expat \
	gdbm \
	gst-plugins-good1 \
	gstreamer1 \
	jpeg \
	lame \
	libffi \
	libpng \
	nano \
	openjpeg \
	py2-gobject3 \
	py2-pip \
	python2 \
	sqlite-libs \
	tar \
	wget \
	nasm \
	yasm-dev \
	lame-dev \
	libogg-dev \
	libvpx-dev \
	libvorbis-dev \
	freetype-dev \
	libass-dev \
	libtheora-dev \
	opus-dev

# add repository for fdk-aac-dev
RUN \
 echo http://dl-cdn.alpinelinux.org/alpine/edge/testing >> /etc/apk/repositories

 # install fdk-aac-dev package
RUN \
 apk add --update --no-cache fdk-aac-dev

# compile mp3gain
RUN \
 mkdir -p \
	/tmp/mp3gain-src && \
 curl -o \
 /tmp/mp3gain-src/mp3gain.zip -L \
	https://sourceforge.net/projects/mp3gain/files/mp3gain/1.5.2/mp3gain-1_5_2_r2-src.zip && \
 cd /tmp/mp3gain-src && \
 unzip -qq /tmp/mp3gain-src/mp3gain.zip && \
 sed -i "s#/usr/local/bin#/usr/bin#g" /tmp/mp3gain-src/Makefile && \
 make && \
 make install

# compile chromaprint
RUN \
 git clone https://bitbucket.org/acoustid/chromaprint.git \
	/tmp/chromaprint && \
 cd /tmp/chromaprint && \
 cmake \
	-DBUILD_TOOLS=ON \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_INSTALL_PREFIX:PATH=/usr && \
 make && \
 make install
 
# compile ffmpeg
RUN \
 cd /tmp/ && wget http://ffmpeg.org/releases/ffmpeg-3.3.2.tar.gz
RUN \
 tar zxf ffmpeg-3.3.2.tar.gz 
RUN \
 cd /tmp/ffmpeg-3.3.2
RUN \
 ./configure \
 --enable-version3 \
 --enable-gpl \
 --enable-nonfree \
 --enable-libmp3lame \
 --enable-libvpx \
 --enable-libtheora \
 --enable-libvorbis \
 --enable-libopus \
 --enable-libfdk-aac \
 --enable-libass \
 --enable-libwebp \
 --enable-librtmp \
 --enable-postproc \
 --enable-avresample \
 --enable-libfreetype \
 --disable-debug

RUN \
 make && make install && make distclean

# install pip packages
RUN \
 pip install --no-cache-dir -U \
	beets \
	beets-copyartifacts \
	flask \
	pillow \
	pip \
	pyacoustid \
	pylast \
	unidecode

# cleanup
RUN \
 apk del --purge \
	build-dependencies && \
 rm -rf \
	/root/.cache \
	/tmp/*

# environment settings
ENV BEETSDIR="/config" \
EDITOR="nano" \
HOME="/config"

# copy local files
COPY root/ /

# ports and volumes
EXPOSE 8337
VOLUME /config /downloads /music
