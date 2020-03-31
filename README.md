# Synology Monitoring Applications #

A collection of open-source applications useful for system monitoring
that can be installed on Synology NAS appliances.

Currently repackages the following applications into native Synology
packages:

- Grafana
- InfluxDB

**NOTE:** Currently only x86-64 architecture Synology NAS devices are supported

## Features ##

### Native packaging ###

This build system takes upstream *pre-compiled* tarballs and creates
native Synology `spk` packages which can then be installed on supported
Synology NAS devices. Installing as native packages allows one to
use the standard Synology Package Center tool to install, upgrade,
monitor and uninstall packages like normal Synology applications.

### No Docker Overhead ###

Not all Synology NAS devices support running Docker images. As such
these applications are built from pre-compiled tarballs that can be
run directly on the Synology NAS without requiring docker.

### Download Checksums ###

To ensure accurate downloads of upstream binaries, a `SHA256SUMS` file is checked
to verify downloads match a known checksum hash for the given URL.
If the checksum does not match, the build exits with an error.
In the case where there is no URL-checksum pair, the build will
note the lack of checksum but continue, unless the environment
variable `BUILD_FORCE_CHECKSUM` is set to 1.

### Cached Downloads ###

Upstream software tarballs are cached locally once downloaded in order to minimize network traffic.
This cache is located in the `.tarballs` directory
within each application's directory. This cache can be cleared by
running `make dist-clean` within the individual application directory
for a single application or from the repository root to clear all
applications.

### Package Release Versioning ###

In order to differentiate updated packages using the same upstream
software version (eg. fixing a bug in Synology package scripts), each
application `Makefile` defines a `PKG_RELEASE` variable that is appended
to the upstream version string when creating the package version. This
should be set to 1 for initial release but can be set to any value desired
(for instance, `beta2`) as it is strictly informational.

For example, for an influxDB package with `PKG_VERSION = 1.7.9` and
`PKG_RELEASE = 5`, the resulting package will be named `influxDB-x86_64-1.7.9-5.spk`.

## Building Packages ##

From the root directory of the repository run `make all` to build
Synology packages for all applications. Alternatively, one can
build an individual application package using `make grafana` or
`make influxdb`

### Example ###

```none
~/git/local/synology-monitor-apps$ make grafana
grafana:
 - Fetching grafana tarball (version: 6.7.1, arch: x86_64)
   from https://dl.grafana.com/oss/release/grafana-6.7.1.linux-amd64.tar.gz
 - Verifying SHA256 checksum for downloaded tarball
 - Installing grafana to temp directory
 - Generating package.tgz
 - Generating INFO file
 - Building grafana-x86_64-6.7.1-1.spk
```

The built package will be found in the `grafana` directory.

## Installing Packages on Synology NAS ##

Packages must be installed using the **Manual Install** option in
Synology Package Center as follows:

1. Log into the Synology web GUI

2. Launch **Package Center**

3. In the top right corner click on the **Manual Install** button.

4. In the *Upload Package* dialog, select the desired `.spk` file from
   your local computer using the *Browse* button.

5. Click *Next* to start the install.

6. If prompted about the package not containing a digital signature,
   click *Yes* to continue the install.

7. A summary dialog will be displayed with package name, author and
   version to verify. If all looks correct, click the *Apply* button.

The same process can be used for updating already installed software as
well. The only requirement is that the package version is different from
the already installed package version (see *Package Release Versioning* above for details on how to set new package versions).

## Updating Package Versions ##

To build new packages containing upstream updates, one needs to
change the `PKG_VERSION` in the application `Makefile` and update
the `SHA256SUMS` file with URL and hash for upstream tarballs.
In addition, if the `PKG_RELEASE` variable was changed in prior
version, reset to 1 for a newly built upstream version.

Detailed instructions for each application below:

### Grafana ###

1. Go to the [Grafana downloads page](https://grafana.com/grafana/download)

2. Select Linux and scroll to the **Standalone Linux Binaries** section.

3. Copy the URL from the `wget` command to a new line in the `SHA256SUMS`
   file in the `grafana` directory.

4. Copy the SHA256 checksum listed on the webpage for the standalone linux
   binaries to the same line in `SHA256SUMS` leaving a single space
   between the URL and the checksum.

5. Update the value of `PKG_VERSION` in `grafana/Makefile` to match the
   new software version.

6. Reset the `PKG_RELEASE` version.

### InfluxDB ###

1. Go to the [InfluxData downloads page](https://portal.influxdata.com/downloads/)

2. Select desired InfluxDB version then scroll to **Linux Binaries (64-bit, static)

3. Copy the URL from the `wget` command to a new line in the `SHA256SUMS`
   file in the `influxdb` directory.

4. Copy the SHA256 checksum listed on the webpage for the standalone linux
   binaries to the same line in `SHA256SUMS` leaving a single space
   between the URL and the checksum.

5. Update the value of `PKG_VERSION` in `influxdb/Makefile` to match the
   new software version.

6. Reset the `PKG_RELEASE` version.
