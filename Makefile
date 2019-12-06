# Top level Makefile

PACKAGES:=influxdb grafana

ifneq ($(BUILD_VERBOSE),1)
MAKE_OPTS:=--no-print-directory
endif

# Build all packages
all: $(PACKAGES)

clean clean-all dist-clean:
	@for pkg in $(PACKAGES); do \
	  $(MAKE) $(MAKE_OPTS) $$pkg-$@; \
	done

# Run make all in target package directory
$(PACKAGES):
	@$(MAKE) $(MAKE_OPTS) $@-all

# Generic rules for running package specific rules in appropriate subdir
$(addsuffix -%,$(PACKAGES)):
	@pkg=$$(echo '$@' | cut -f1 -d'-'); \
	echo "$$pkg:"; \
	$(MAKE) -C $$pkg $(MAKE_OPTS) $*
	@echo

.PHONY: all clean clean-all dist-clean $(PACKAGES)