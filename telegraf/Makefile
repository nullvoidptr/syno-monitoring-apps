# Telegraf Makefile

PKG_NAME := telegraf

# Override via environment to build other version/arch
PKG_VERSION ?= 1.14.1
PKG_ARCH ?= x86_64
PKG_STATIC ?=
PKG_RELEASE := 1

# NOTE: PKG_INFO vars must have strings in double quotes but other values unquoted
PKG_INFO_DISPLAYNAME := "Telegraf"
PKG_INFO_MAINTAINER := "James Bowen"
PKG_INFO_DESCRIPTION := \
	"Telegraf is a plugin-driven server agent for collecting and sending metrics \
	 and events from databases, systems, and IoT sensors."

# Override with non-zero value to fail if checksum not found
BUILD_FORCE_CHECKSUM ?= 0

# Checksum info
CHECKSUM_HASH := SHA256
CHECKSUM_BIN := sha256sum
CHECKSUM_FILE := SHA256SUMS

ifeq ($(PKG_ARCH),x86_64)
  PKG_DOWNLOAD_ARCH := amd64
else
  $(error Architecture '$(PKG_ARCH)' not supported for $(PKG_NAME))
endif

PKG_TARBALL := telegraf-$(PKG_VERSION)$(PKG_STATIC)_linux_$(PKG_DOWNLOAD_ARCH).tar.gz
TARBALL_URL := https://dl.influxdata.com/telegraf/releases/$(PKG_TARBALL)

PKG_ROOT_DIR := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))

include $(PKG_ROOT_DIR)/../mk/package.mk

ifneq ($(BUILD_VERBOSE),1)
WGET_QUIET:="--quiet"
endif

# Fetch tarball if not present in local cache
$(TARBALL_DIR)/$(PKG_TARBALL): $(TARBALL_DIR) $(PKG_ROOT_DIR)/$(CHECKSUM_FILE)
	@echo " - Fetching $(PKG_NAME) tarball (version: $(PKG_VERSION), arch: $(PKG_ARCH))"
	$(Q) wget $(WGET_QUIET) -O $(TARBALL_DIR)/$(PKG_TARBALL).download $(TARBALL_URL)
	@# wget will leave empty file on failure so download to temp file and rename on success
	$(Q) mv $(TARBALL_DIR)/$(PKG_TARBALL).download $(TARBALL_DIR)/$(PKG_TARBALL)
	@# wget sets modify time to time fetched from server
	@# 'touch' the file to ensure make handles updated file correctly
	@# otherwise will download each time make is run
	$(Q) touch $(TARBALL_DIR)/$(PKG_TARBALL)
	$(Q) cksum=$$(grep '^$(TARBALL_URL)' $(PKG_ROOT_DIR)/$(CHECKSUM_FILE) | awk '{print $$2}' | head -n1 ); \
	  if [ -n "$$cksum" ]; then \
	    echo " - Verifying $(CHECKSUM_HASH) checksum for downloaded tarball"; \
	    echo "$$cksum  $(TARBALL_DIR)/$(PKG_TARBALL)" | $(CHECKSUM_BIN) -c > /dev/null 1>&1; \
		if [ $$? -ne 0 ]; then \
		  echo "$(CHECKSUM_HASH) checksum mismatch for $(PKG_TARBALL)"; \
		  exit 1; \
		 fi; \
      else \
	    echo "No matching $(CHECKSUM_HASH) checksum found for $(PKG_TARBALL)" && exit $(BUILD_FORCE_CHECKSUM);  \
	  fi

$(INNER_PKG_DIR): $(TARBALL_DIR)/$(PKG_TARBALL)
	@echo " - Installing $(PKG_NAME) to temp directory"
	$(Q) rm -rf $(INNER_PKG_DIR)
	$(Q) install -d $(INNER_PKG_DIR)/bin
	$(Q) tar_root=$$(tar tzf $(TARBALL_DIR)/$(PKG_TARBALL) | grep "/[^/]*/$$" | head -n1); \
	  tar xzf $(TARBALL_DIR)/$(PKG_TARBALL) -O  $${tar_root}usr/bin/telegraf > $(INNER_PKG_DIR)/bin/telegraf
	$(Q) chmod 755 $(INNER_PKG_DIR)/bin/telegraf
	$(Q) install -d $(INNER_PKG_DIR)/etc $(INNER_PKG_DIR)/etc/telegraf.d
	$(Q) install -m 0644 etc/telegraf.conf $(INNER_PKG_DIR)/etc/telegraf.conf
	$(Q) install -m 0644 etc/telegraf.d/* $(INNER_PKG_DIR)/etc/telegraf.d
