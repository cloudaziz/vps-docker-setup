#!/bin/sh

set -eu

# Validate PHP configuration
php -v >/dev/null 2>&1 || exit 1

# Validate PHP-FPM configuration
php-fpm -t >/dev/null 2>&1 || exit 1

exit 0
