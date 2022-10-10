ALL_CURL_OPTS := $(CURL_OPTS) -L --fail --create-dirs

VERSION := 22.03.0
BOARD := bcm27xx
SUBTARGET := bcm2711
BUILDER := openwrt-imagebuilder-$(VERSION)-$(BOARD)-$(SUBTARGET).Linux-x86_64
PROFILE := rpi-4
EXTRA_IMAGE_NAME := iscsi-usb
PACKAGES := luci open-iscsi tgt kmod-usb-dwc2 kmod-usb-gadget-mass-storage luci-app-commands blkid lsblk atop tcpdump

BUILD_DIR := build
OUTPUT_DIR := $(BUILD_DIR)/$(BUILDER)/bin/targets/$(BOARD)/$(SUBTARGET)


all: images


deps-debian:
	# https://openwrt.org/docs/guide-user/additional-software/imagebuilder#debianubuntu
	apt-get install ${PKGMGR_OPTS} --no-install-recommends \
		build-essential \
		file \
		gawk \
		gettext \
		git \
		libncurses5-dev \
		libncursesw5-dev \
		libssl-dev \
		python3 \
		rsync \
		unzip \
		wget \
		xsltproc \
		zlib1g-dev
	
	# Extra build dependencies
	apt-get install ${PKGMGR_OPTS} --no-install-recommends \
		ca-certificates \
		curl


$(BUILD_DIR)/downloads:
	# OpenWrt Image Builder
	curl $(ALL_CURL_OPTS) --output-dir $(BUILD_DIR)/downloads.tmp -O https://downloads.openwrt.org/releases/$(VERSION)/targets/$(BOARD)/$(SUBTARGET)/$(BUILDER).tar.xz
	mv $(BUILD_DIR)/downloads.tmp $(BUILD_DIR)/downloads


$(BUILD_DIR)/$(BUILDER): $(BUILD_DIR)/downloads
	cd $(BUILD_DIR) && tar -xf downloads/$(BUILDER).tar.xz


rootfs-contents: $(BUILD_DIR)/downloads
	rm -rf $(BUILD_DIR)/rootfs
	cp -rv rootfs $(BUILD_DIR)/rootfs


images: $(BUILD_DIR)/$(BUILDER) rootfs-contents
	cd $(BUILD_DIR)/$(BUILDER) && make image PROFILE="$(PROFILE)" EXTRA_IMAGE_NAME="$(EXTRA_IMAGE_NAME)" PACKAGES="$(PACKAGES)" FILES="../rootfs"
	rm -f $(BUILD_DIR)/images && ln -s ../$(OUTPUT_DIR) $(BUILD_DIR)/images
	cat $(OUTPUT_DIR)/sha256sums


clean:
	rm -rf build

