# InfluxDB Makefile


PKG_NAME := influxDB
PKG_DISPLAY_NAME := "InfluxDB"
PKG_MAINTAINER := "James Bowen"
PKG_DESCRIPTION := "InfluxDB is used as a data store for any use case involving large amounts of timestamped data, including DevOps monitoring, application metrics, IoT sensor data, and real-time analytics."

# Override via environment to build other version/arch
PKG_VERSION ?= 1.3.4
PKG_ARCH ?= x86_64
PKG_STATIC ?=
PKG_RELEASE := beta1

ifeq ($(PKG_ARCH),x86_64)
    PKG_DOWNLOAD_ARCH := amd64
endif

PKG_TARBALL := influxdb-$(PKG_VERSION)$(PKG_STATIC)_linux_$(PKG_DOWNLOAD_ARCH).tar.gz
INFLUXDB_URL := https://dl.influxdata.com/influxdb/releases/$(PKG_TARBALL)

PKG_ROOT_DIR := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))

include $(PKG_ROOT_DIR)/../mk/package.mk

$(TARBALL_DIR)/$(PKG_TARBALL): $(TARBALL_DIR)
	@echo "Fetching $(PKG_NAME) tarball (version: $(PKG_VERSION), arch: $(PKG_ARCH))"
	@wget -O $(TARBALL_DIR)/$(PKG_TARBALL) $(INFLUXDB_URL)
	@# wget sets modify time to time fetched from server
	@# 'touch' the file to ensure make handles updated file correctly
	@# otherwise will download each time make is run
	@touch $(TARBALL_DIR)/$(PKG_TARBALL)

# Build is a no-op as we download pre-compiled binaries from the web
build: $(BUILD_DIR) $(TARBALL_DIR)/$(PKG_TARBALL)

# Install copies files into target directory
install: $(INNER_PKG_DIR)

$(INNER_PKG_DIR): $(TARBALL_DIR)/$(PKG_TARBALL)
	rm -rf $(INNER_PKG_DIR)
	install -d $(INNER_PKG_DIR)
	install -d $(INNER_PKG_DIR)/bin
	tar_root=$$(tar tzf $(TARBALL_DIR)/$(PKG_TARBALL) | grep "/[^/]*/$$" | head -n1); \
	  tar xzf $(TARBALL_DIR)/$(PKG_TARBALL) -O  $${tar_root}usr/bin/influxd > $(INNER_PKG_DIR)/bin/influxd; \
	  tar xzf $(TARBALL_DIR)/$(PKG_TARBALL) -O  $${tar_root}usr/bin/influx > $(INNER_PKG_DIR)/bin/influx
	chmod 755 $(INNER_PKG_DIR)/bin/influx*
