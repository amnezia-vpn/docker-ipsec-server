FROM alpine:3.14

LABEL maintainer="AmneziaVPN"

ENV SWAN_VER 4.5
WORKDIR /opt/src

RUN set -x \
    && apk add --no-cache \
         bash bind-tools coreutils dumb-init openssl uuidgen wget xl2tpd iproute2 \
         libcap-ng libcurl libevent linux-pam musl nspr nss nss-tools \
         bison flex gcc make libc-dev bsd-compat-headers linux-pam-dev \
         nss-dev libcap-ng-dev libevent-dev curl-dev nspr-dev \
    && wget -t 3 -T 30 -nv -O libreswan.tar.gz "https://github.com/libreswan/libreswan/archive/v${SWAN_VER}.tar.gz" \
    || wget -t 3 -T 30 -nv -O libreswan.tar.gz "https://download.libreswan.org/libreswan-${SWAN_VER}.tar.gz" \
    && tar xzf libreswan.tar.gz \
    && rm -f libreswan.tar.gz \
    && cd "libreswan-${SWAN_VER}" \
    && sed -i '28s/stdlib\.h/sys\/types.h/' include/fd.h \
    && printf 'WERROR_CFLAGS=-w -s\nUSE_DNSSEC=false\nUSE_DH2=true\n' > Makefile.inc.local \
    && printf 'FINALNSSDIR=/etc/ipsec.d\nUSE_GLIBC_KERN_FLIP_HEADERS=true\n' >> Makefile.inc.local \
    && make -s base \
    && make -s install-base \
    && cd /opt/src \
    && rm -rf "/opt/src/libreswan-${SWAN_VER}" \
    && apk del --no-cache \
         bison flex gcc make libc-dev bsd-compat-headers linux-pam-dev \
         nss-dev libcap-ng-dev libevent-dev curl-dev nspr-dev

EXPOSE 500/udp 4500/udp
ENTRYPOINT [ "dumb-init", "tail -f /dev/null" ]