FROM nfxus/netcore:latest

ENV GID=991 \
    UID=991 

LABEL description="Emby based on alpine and netcore nightly" \
      tags="latest" \
      maintainer="dextou" 

RUN export BUILD_DEPS="build-base \
                        git \
                        unzip \
                        wget \
                        ca-certificates \
                        xz" \
    && apk add --no-cache imagemagick \
	            sqlite-libs \
	            ffmpeg \
	            s6 \
                    curl \
                su-exec \
                jq \
                grep \
                $BUILD_DEPS \
                 
                       
    && MEDIAINFO_VER=$(curl --silent "https://api.github.com/repos/MediaArea/MediaInfo/releases/latest" | grep -Po '"tag_name": "v\K.*?(?=")') \
    && wget http://mediaarea.net/download/binary/mediainfo/${MEDIAINFO_VER}/MediaInfo_CLI_${MEDIAINFO_VER}_GNU_FromSource.tar.xz -O /tmp/MediaInfo_CLI_${MEDIAINFO_VER}_GNU_FromSource.tar.xz \
    && wget http://mediaarea.net/download/binary/libmediainfo0/${MEDIAINFO_VER}/MediaInfo_DLL_${MEDIAINFO_VER}_GNU_FromSource.tar.xz -O /tmp/MediaInfo_DLL_${MEDIAINFO_VER}_GNU_FromSource.tar.xz \
    && tar xJf /tmp/MediaInfo_DLL_${MEDIAINFO_VER}_GNU_FromSource.tar.xz -C /tmp \
    && tar xJf /tmp/MediaInfo_CLI_${MEDIAINFO_VER}_GNU_FromSource.tar.xz -C /tmp \
    && cd  /tmp/MediaInfo_DLL_GNU_FromSource \
    && ./SO_Compile.sh \
    && cd /tmp/MediaInfo_DLL_GNU_FromSource/ZenLib/Project/GNU/Library \
    && make install \
    && cd /tmp/MediaInfo_DLL_GNU_FromSource/MediaInfoLib/Project/GNU/Library \
    && make install \
    && cd /tmp/MediaInfo_CLI_GNU_FromSource \
    && ./CLI_Compile.sh \
    && cd /tmp/MediaInfo_CLI_GNU_FromSource/MediaInfo/Project/GNU/CLI \
    && make install \
    && mkdir /embyServer /embyData \
    && EMBY_VER=$(curl -s "https://api.github.com/repos/MediaBrowser/Emby.Releases/releases/latest" | awk -F '"' '/tag_name/{print $4}'|cut -f2 -d "v") \
    && wget https://github.com/MediaBrowser/Emby.Releases/releases/download/${EMBY_VER}/embyserver-netcore_${EMBY_VER}.zip -O /tmp/embyserver-netcore.zip \
    && ln -s /usr/lib/libsqlite3.so.0 /usr/lib/libsqlite3.so \
    && unzip /tmp/embyserver-netcore.zip -d /embyServer \
    && apk del --no-cache $BUILD_DEPS \
    && rm -rf /tmp/*

EXPOSE 8096 8920 7359/udp
VOLUME /embyData
ADD rootfs /
RUN chmod +x /usr/local/bin/startup

ENTRYPOINT ["/usr/local/bin/startup"]
CMD ["s6-svscan", "/etc/s6.d"]

HEALTHCHECK --interval=30s --timeout=60s CMD curl --fail http://localhost:8096/web || exit 1
