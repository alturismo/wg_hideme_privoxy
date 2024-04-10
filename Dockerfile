FROM alpine:latest AS builder

LABEL org.opencontainers.image.authors="alturismo@gmail.com"

# Set Variables
ARG MICROSOCKS_V=1.0.4
ARG HIDEME_V=0.9.9

# Add compile dependencies for Microsocks
RUN apk update && \
    apk add --no-cache make gcc musl-dev

# Download Microsocks and compile it
RUN wget -O /tmp/microsocks_v${MICROSOCKS_V}.tar.gz https://github.com/rofl0r/microsocks/archive/refs/tags/v${MICROSOCKS_V}.tar.gz && \
    tar -C /tmp -xzvf /tmp/microsocks_v${MICROSOCKS_V}.tar.gz && \
    cd /tmp/microsocks-${MICROSOCKS_V} && \
    make -j$(nproc --all) && \
    DESTDIR=/tmp/copy make install

# Download hide.me binary and move binary to copy directory
RUN wget -O /tmp/hide.me_v${HIDEME_V}.tar.gz https://github.com/eventure/hide.client.linux/releases/download/${HIDEME_V}/hide.me-linux-amd64-${HIDEME_V}.tar.gz && \
    tar -C /tmp -xvf /tmp/hide.me_v${HIDEME_V}.tar.gz && \
    mkdir -p /tmp/copy/usr/bin && \
    cp /tmp/hide.me /tmp/copy/usr/bin/hide.me

FROM alpine:latest

LABEL org.opencontainers.image.authors="alturismo@gmail.com"

# Add Packages
RUN apk update && \
    apk add --no-cache ca-certificates privoxy runit

# Copy binaries from build stage to main container
COPY --from=builder /tmp/copy/ /

# Timezone (TZ)
ENV TZ=Europe/Berlin
RUN apk update && apk add --no-cache tzdata && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Fix for missing gcc libraries
RUN mkdir /lib64 && \
    ln -s /lib/libc.musl-x86_64.so.1 /lib64/ld-linux-x86-64.so.2

# Add Bash shell & dependancies
RUN apk add --no-cache bash busybox-suid su-exec screen socat

# Default env variables
ENV HIDEME_SOCKS="on"
ENV HIDEME_PRIVOXY="on"
ENV CA_FILEPATH="/config/cert.pem"
ENV AT_FILEPATH="/config/accessToken.txt"
ENV PR_FILEPATH="/config/privoxy_config"
ENV START_PARAMS=""
ENV TOKEN_PARAMS=""
ENV CONNECTED_CONTAINERS=""

# Volumes
VOLUME /config

# Add Files
RUN chmod +x /usr/bin/hide.me
COPY defaults /opt/defaults
COPY startups /opt/startups

RUN find /opt/startups -name run | xargs chmod u+x

# Add Expose Port
EXPOSE 8080 1080

# Command
CMD ["runsvdir", "/opt/startups"]
