# Top level Makefile

PACKAGES:=influxdb

# Build all packages
all: $(PACKAGES)

clean dist-clean:
	@for pkg in $(PACKAGES); do \
	  $(MAKE) -C $$pkg $@; \
	done

# Run make in target package directory
$(PACKAGES):
	@$(MAKE) -C $@

.PHONY: all clean $(PACKAGES)
