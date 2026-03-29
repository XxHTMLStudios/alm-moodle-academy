#!/bin/bash
set -e

CONFIG_FILE="/var/www/html/config.php"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "Generating config.php..."
    {
        echo "<?php"
        echo "unset(\$CFG);"
        echo "global \$CFG;"
        echo "\$CFG = new stdClass();"
        echo ""
        echo "\$CFG->dbtype    = 'mariadb';"
        echo "\$CFG->dblibrary = 'native';"
        echo "\$CFG->dbhost    = '$MOODLE_DB_HOST';"
        echo "\$CFG->dbname    = '$MOODLE_DB_NAME';"
        echo "\$CFG->dbuser    = '$MOODLE_DB_USER';"
        echo "\$CFG->dbpass    = '$MOODLE_DB_PASSWORD';"
        echo "\$CFG->prefix    = 'mdl_';"
        echo ""
        echo "\$CFG->wwwroot   = '$MOODLE_WWWROOT';"
        echo "\$CFG->dataroot  = '/var/moodledata';"
        echo "\$CFG->admin     = 'admin';"
        echo ""
        echo "\$CFG->directorypermissions = 0777;"
        echo ""
        echo "require_once(__DIR__ . '/lib/setup.php');"
    } > "$CONFIG_FILE"
    chown www-data:www-data "$CONFIG_FILE"
fi

exec "$@"