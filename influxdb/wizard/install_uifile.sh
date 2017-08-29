#!/bin/bash

# TODO: Ask for port
# TODO: Ask for username / password

# NOTE: SYNOPKG_PKGDEST and SYNOPKG_PKGDEST_VOL are not set when UI files
# are generated. Instead we make best guess of location for default value
# by searching for '@appstore' directories in volumes

if [ -z "${SYNOPKG_PKGDEST_VOL}" ]; then
    SYNOPKG_PKGDEST_VOL=$(dirname $(readlink -f /volume[0-9*]/@appstore 2>/dev/null) 2>/dev/null)
fi

cat > ${SYNOPKG_TEMP_LOGFILE} <<EOF
[{
    "step_title": "Installing InfluxDB (version ${SYNOPKG_PKGVER})",
    "items": [{
        "type": "textfield",
        "desc": "Configuration",
        "subitems": [{
            "key": "INFLUXDB_DATA_DIR",
            "desc": "InfluxDB Data Directory",
            "defaultValue": "${SYNOPKG_PKGDEST_VOL}/data/${SYNOPKG_PKGNAME}"
        }]
    }]
}]
EOF

env >> /volume1/install_env
