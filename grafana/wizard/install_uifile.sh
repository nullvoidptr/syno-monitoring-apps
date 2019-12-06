#!/bin/bash

# TODO: Ask for username / password

# NOTE: SYNOPKG_PKGDEST and SYNOPKG_PKGDEST_VOL are not set when UI files
# are generated. Instead we make best guess of location for default value
# by searching for '@appstore' directories in volumes

if [ -z "${SYNOPKG_PKGDEST_VOL}" ]; then
    SYNOPKG_PKGDEST_VOL=$(dirname $(readlink -f /volume[0-9*]/@appstore 2>/dev/null | head -n1 ) 2>/dev/null)
fi

cat > ${SYNOPKG_TEMP_LOGFILE} <<EOF
[{
    "step_title": "Grafana Settings",
    "items": [{
        "type": "textfield",
        "desc": "",
        "subitems": [{
            "key": "GRAFANA_DATA_DIR",
            "desc": "Data Directory",
            "defaultValue": "${SYNOPKG_PKGDEST_VOL}/data/${SYNOPKG_PKGNAME}"
        }]
    },
    {
        "type": "textfield",
        "subitems" : [{
            "key": "GRAFANA_PORT",
            "desc": "UI Port",
            "defaultValue": 3000,
            "validator": {
                "regex": {
                    "expr": "/^[0-9]+$/",
                    "errorText": "Error: Must be a number"
                }
            }
        }]
    }]
}]
EOF