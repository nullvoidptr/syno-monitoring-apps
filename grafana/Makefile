# Grafana Makefile

PKG_NAME := grafana

# Override via environment to build other version/arch
PKG_VERSION ?= 4.4.3
PKG_ARCH ?= x86_64
PKG_STATIC ?=
PKG_RELEASE := 1-beta

# NOTE: PKG_INFO vars must have strings in double quotes but other values unquoted
PKG_INFO_DISPLAYNAME := "Grafana"
PKG_INFO_MAINTAINER := "James Bowen"
PKG_INFO_DESCRIPTION := \
	Grafana is an open source monitoring app compatible with InfluxDB and other \
	time series databases. See https://grafana.com for more info.

# Require 6.0-5914 to support data share resource
# PKG_INFO_OS_MIN_VER := 6.0-5914

# Override with non-zero value to fail if checksum not found
BUILD_FORCE_CHECKSUM ?= 0

# Checksum info
CHECKSUM_HASH := SHA256
CHECKSUM_BIN := sha256sum
CHECKSUM_FILE := SHA256SUMS

ifeq ($(PKG_ARCH),x86_64)
  PKG_DOWNLOAD_ARCH := x64
else
  $(error Architecture '$(PKG_ARCH)' not supported for $(PKG_NAME))
endif

PKG_TARBALL := grafana-$(PKG_VERSION)$(PKG_STATIC).linux-$(PKG_DOWNLOAD_ARCH).tar.gz
TARBALL_URL := https://s3-us-west-2.amazonaws.com/grafana-releases/release/$(PKG_TARBALL)

PKG_ROOT_DIR := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))

include $(PKG_ROOT_DIR)/../mk/package.mk

ifneq ($(BUILD_VERBOSE),1)
WGET_QUIET:="--quiet"
endif

$(TARBALL_DIR)/$(PKG_TARBALL): $(TARBALL_DIR) $(PKG_ROOT_DIR)/$(CHECKSUM_FILE)
	@echo " - Fetching $(PKG_NAME) tarball (version: $(PKG_VERSION), arch: $(PKG_ARCH))"
	$(Q) wget $(WGET_QUIET) -O $(TARBALL_DIR)/$(PKG_TARBALL) $(TARBALL_URL)
	@# wget sets modify time to time fetched from server
	@# 'touch' the file to ensure make handles updated file correctly
	@# otherwise will download each time make is run
	$(Q) touch $(TARBALL_DIR)/$(PKG_TARBALL)
	$(Q) cksum=$$(grep '^$(TARBALL_URL)' $(PKG_ROOT_DIR)/$(CHECKSUM_FILE) | awk '{print $$2}' | head -n1 ); \
	  if [ -n "$$cksum" ]; then \
	    echo " - Verifying $(CHECKSUM_HASH) checksum for downloaded tarball"; \
	    echo "$$cksum  $(TARBALL_DIR)/$(PKG_TARBALL)" | $(CHECKSUM_BIN) -c >/dev/null 2>&1; \
		if [ $$? -ne 0 ]; then \
		  echo "$(CHECKSUM_HASH) checksum mismatch for $(PKG_TARBALL)"; \
		  exit 1; \
		 fi; \
      else \
	    echo "No matching $(CHECKSUM_HASH) checksum found for $(PKG_TARBALL)" && exit $(BUILD_FORCE_CHECKSUM);  \
	  fi


# Build is a no-op as we download pre-compiled binaries from the web
build: $(BUILD_DIR) $(TARBALL_DIR)/$(PKG_TARBALL)

# Install copies files into target directory
install: $(INNER_PKG_DIR)

$(INNER_PKG_DIR): $(TARBALL_DIR)/$(PKG_TARBALL)
	@echo " - Installing $(PKG_NAME) to temp directory"
	$(Q) rm -rf $(INNER_PKG_DIR)
	$(Q) install -d $(INNER_PKG_DIR)
	$(Q) tar xzf $(TARBALL_DIR)/$(PKG_TARBALL) -C $(INNER_PKG_DIR) --strip-components=1
