# Source images
FROM "bitnami/minideb:buster" as minideb

# Ubuntu 18.04 Bionic LTS
FROM "ubuntu:18.04"
ARG UNIFI_CONTROLLER_VERSION="6.0.45"
ARG MONGODB_VERSION="3.6"
SHELL [ "/bin/bash", "-e", "-u", "-o", "pipefail", "-c" ]

# Install the installer script
COPY --from=minideb \
	"/usr/sbin/install_packages" \
	"/usr/sbin/install_packages"

# Install pre-requisite packages
RUN install_packages \
	"apt-transport-https" \
	"ca-certificates" \
	"curl" \
	"gnupg" \
	"lsb-release"

# Prepare the MongoDB
RUN \
	curl --silent --show-error \
		--location \
		"https://www.mongodb.org/static/pgp/server-${MONGODB_VERSION}.asc" \
	| APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE="1" apt-key add - \
	&& \
	echo "deb https://repo.mongodb.org/apt/ubuntu $(lsb_release --short --codename)/mongodb-org/${MONGODB_VERSION} multiverse" >"/etc/apt/sources.list.d/mongodb-org.list"

# Install required packages
RUN install_packages \
	"binutils" \
	"jsvc" \
	"libcap2" \
	"logrotate" \
	"mongodb-org" \
	"openjdk-11-jre-headless"

# Install the Unifi Controller
RUN \
	curl --silent --show-error \
		--location \
		--output "/tmp/unifi_sysvinit_all.deb" \
		"https://dl.ui.com/unifi/${UNIFI_CONTROLLER_VERSION}/unifi_sysvinit_all.deb" \
	&& \
	DEBIAN_FRONTEND="noninteractive" \
	RUNLEVEL="1" \
	dpkg -i "/tmp/unifi_sysvinit_all.deb" \
	&& \
	rm -r \
		"/tmp/unifi_sysvinit_all.deb"

# Copy our entrypoint
COPY "entrypoint.sh" "/docker-entrypoint.sh"
ENTRYPOINT [ "/bin/bash", "/docker-entrypoint.sh" ]
CMD [ "unifi" ]

# Set the workdir
WORKDIR "/usr/lib/unifi"

# Expose volume and ports
VOLUME "/usr/lib/unifi/data"
VOLUME "/usr/lib/unifi/logs"

# STUN protocol
EXPOSE "3478/udp"

# Remote syslog capture
EXPOSE "5514/udp"

# Device and controller communication
EXPOSE "8080/tcp"

# Admin interface
EXPOSE "8443/tcp"

# HTTP portal redirection
EXPOSE "8880/tcp"

# HTTPS portal redirection
EXPOSE "8843/tcp"

# UniFi mobile speed test
EXPOSE "6789/tcp"

# Local-bound database communication
EXPOSE "27117/tcp"

# AP-EDU broadcasting
EXPOSE "5656-5699/udp"

# Device discovery
EXPOSE "10001/udp"

# L2 network discoverability (controller setting)
EXPOSE "1900/udp"
