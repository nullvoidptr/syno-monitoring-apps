
PKG_DISPLAY_NAME := "InfluxDB"
PKG_MAINTAINER := "James Bowen"
PKG_DESCRIPTION := "InfluxDB is used as a data store for any use case involving large amounts of timestamped data, including DevOps monitoring, application metrics, IoT sensor data, and real-time analytics."
#os_min_vers=6.0-5914

# Override via environment to build other version/arch
PKG_NAME ?= influxDB
PKG_VERSION ?= 1.3.4
PKG_ARCH ?= x86_64
PKG_STATIC ?=
PKG_RELEASE := beta1

ifdef PKG_RELEASE
    PKG_VERSION_FULL:=$(PKG_VERSION)-$(PKG_RELEASE)
else
    PKG_VERSION_FULL:=$(PKG_VERSION)
endif

# Synology uses x86_64 designation, influxdb download uses amd64
ifeq ($(PKG_ARCH),x86_64)
    PKG_DOWNLOAD_ARCH := amd64
    PKG_PLATFORMS := "x86 bromolow cedarview avoton braswell broadwell dockerx64 kvmx64 grantley"
else
    ifeq ($(PKG_ARCH),arm)
        PKG_DOWNLOAD_ARCH := armhf
        PKG_PLATFORMS := ""
    else
        $(error Unknown arch $PKG_ARCH)
    endif
endif

PKG_TARBALL := influxdb-$(PKG_VERSION)$(PKG_STATIC)_linux_$(PKG_DOWNLOAD_ARCH).tar.gz
INFLUXDB_URL := https://dl.influxdata.com/influxdb/releases/$(PKG_TARBALL)

ROOT_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
BUILD_DIR := $(ROOT_DIR)/.build/$(PKG_NAME)-$(PKG_ARCH)-$(PKG_VERSION_FULL)
TARBALL_DIR := $(ROOT_DIR)/.tarballs
SCRIPT_DIR := $(ROOT_DIR)/scripts

INNER_PKG_DIR := $(BUILD_DIR)/_inner_
OUTER_PKG_DIR := $(BUILD_DIR)/_outer_

SCRIPT_FILES := $(shell ls $(SCRIPT_DIR)/*)
INFO_FILE := $(BUILD_DIR)/INFO
ICON_FILES := $(shell ls $(ROOT_DIR)/icons/PACKAGE_ICON*.PNG)
PKG_CONF_FILES := $(shell ls $(ROOT_DIR)/conf/*)
WIZARD_UIFILES := $(shell ls $(ROOT_DIR)/wizard/*)

DEST_PACKAGE := influxdb-$(PKG_ARCH)-$(PKG_VERSION)-$(PKG_RELEASE).spk

# Need to export for 'dump-vars' rule
export PKG_VERSION PKG_ARCH PKG_STATIC PKG_TARBALL INFLUXDB_URL
export ROOT_DIR BUILD_DIR SCRIPT_DIR SCRIPT_FILES INFO_FILE ICON_FILES PKG_CONF_FILES DEST_PACKAGE


all: build install package

# Fetch retrieves desired version from web
fetch: $(TARBALL_DIR)/$(PKG_TARBALL)

$(TARBALL_DIR)/$(PKG_TARBALL): $(TARBALL_DIR)
	@echo "Fetching influxdb tarball (version: $(PKG_VERSION), arch: $(PKG_ARCH))"
	@wget -O $(TARBALL_DIR)/$(PKG_TARBALL) $(INFLUXDB_URL)
	@# wget sets modify time to time fetched from server
	@# 'touch' the file to ensure make handles updated file correctly
	@# otherwise will download each time make is run
	@touch $(TARBALL_DIR)/$(PKG_TARBALL)

# Build is a no-op as we download pre-compiled binaries from the web 
build: $(BUILD_DIR) $(TARBALL_DIR)/$(PKG_TARBALL)

# Install copies files into target directory
install: $(BUILD_DIR)/package.tgz

# Create the inner package
$(BUILD_DIR)/package.tgz: $(TARBALL_DIR)/$(PKG_TARBALL)
	rm -rf $(INNER_PKG_DIR)
	install -d $(INNER_PKG_DIR)
	install -d $(INNER_PKG_DIR)/bin
	tar_root=$$(tar tzf $(TARBALL_DIR)/$(PKG_TARBALL) | grep "/[^/]*/$$" | head -n1); \
	  tar xzf $(TARBALL_DIR)/$(PKG_TARBALL) -O  $${tar_root}usr/bin/influxd > $(INNER_PKG_DIR)/bin/influxd; \
	  tar xzf $(TARBALL_DIR)/$(PKG_TARBALL) -O  $${tar_root}usr/bin/influx > $(INNER_PKG_DIR)/bin/influx
	chmod 755 $(INNER_PKG_DIR)/bin/influx*
	tar czf $@ -C $(INNER_PKG_DIR) .


$(INFO_FILE): $(BUILD_DIR)/package.tgz
	echo "package=\"$(PKG_NAME)\"" > $(INFO_FILE)
	echo "displayname=\"$(PKG_DISPLAY_NAME)\"" >> $(INFO_FILE)
	echo "maintainer=\"$(PKG_MAINTAINER)\"" >> $(INFO_FILE)
	echo "description=\"$(PKG_DESCRIPTION)\"" >> $(INFO_FILE)
	echo "version=\"$(PKG_VERSION_FULL)\"" >> $(INFO_FILE)
	echo "arch=\"$(PKG_PLATFORMS)\"" >> $(INFO_FILE)
	size=$$(du -s $(INNER_PKG_DIR) | cut -f1); \
	  echo "extractsize=$$size" >> $(INFO_FILE)
	echo "create_time=\"$$(date "+%Y%m%d-%H:%M:%S")\"" >> $(INFO_FILE)


package: $(DEST_PACKAGE)

$(DEST_PACKAGE): $(BUILD_DIR)/package.tgz $(SCRIPT_FILES) $(ICON_FILES) $(INFO_FILE) $(PKG_CONF_FILES) $(WIZARD_UIFILES)
	install -d $(OUTER_PKG_DIR)
	install -d $(OUTER_PKG_DIR)/scripts
	install -m 755 $(SCRIPT_FILES) $(OUTER_PKG_DIR)/scripts
	install -m 644 $(BUILD_DIR)/package.tgz $(OUTER_PKG_DIR)
	install -m 644 $(ICON_FILES) $(INFO_FILE) $(OUTER_PKG_DIR)
	install -d $(OUTER_PKG_DIR)/conf
	install -m 644 $(PKG_CONF_FILES) $(OUTER_PKG_DIR)/conf
	if [ -n "$(WIZARD_UIFILES)" ]; then \
	  install -d $(OUTER_PKG_DIR)/WIZARD_UIFILES; \
	  install -m 755 $(WIZARD_UIFILES) $(OUTER_PKG_DIR)/WIZARD_UIFILES; \
	fi
	tar czf $@ -C $(OUTER_PKG_DIR) $$(ls $(OUTER_PKG_DIR))

dump-vars:
	@for var in PKG_VERSION PKG_ARCH PKG_STATIC PKG_TARBALL INFLUXDB_URL \
	    ROOT_DIR BUILD_DIR SCRIPT_DIR SCRIPT_FILES INFO_FILE ICON_FILES PKG_CONF_FILES \
	    DEST_PACKAGE; do \
	    eval "val=\$$""$$var"; \
	    printf "%-18s  %s\n" "$$var:" "$$val"; \
	done

# Create build directory
$(BUILD_DIR) $(TARBALL_DIR):
	@if [ ! -d "$@" ]; then mkdir -p "$@"; fi
	@if [ ! -f "$@/.gitignore" ]; then echo "*" > "$@/.gitignore"; fi

clean:
	rm -rf $(BUILD_DIR)/*

clean-all:
	rm -rf $(ROOT_DIR)/.build

dist-clean: clean-all
	rm -rf $(TARBALL_DIR)

.PHONY: all clean build fetch package dist-clean dump-vars
