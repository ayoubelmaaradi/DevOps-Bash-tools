#!/usr/bin/env bash
#
#  Author: Hari Sekhon
#  Date: 2019-11-26 15:19:31 +0000 (Tue, 26 Nov 2019)
#
#  https://github.com/harisekhon/devops-bash-tools
#
#  License: see accompanying LICENSE file
#
#  https://www.linkedin.com/in/harisekhon
#

# Reinstalls Python via HomeBrew to fix OpenSSL library linkage break upon OpenSSL 1.0 => OpenSSL 1.1 upgrade caused by krb5

# fixes this breakage:
#
# python -c 'import hashlib', which break pips, eg:
#
# https://stackoverflow.com/questions/20399331/error-importing-hashlib-with-python-2-7-but-not-with-2-6

set -euo pipefail
[ -n "${DEBUG:-}" ] && set -x

if [ "$(uname -s)" != Darwin ]; then
    echo "Not a Mac system, aborting..."
    exit 1
fi

if type -P brew &>/dev/null; then
    # grep -q causes a pipefail via early pipe close which exits the script early without fixing
    if python -c 'import hashlib' 2>&1 | tee /dev/stderr | grep 'unsupported hash type'; then
        echo "Attempting to upgrade homebrew packages dependending on upgraded OpenSSL linkage break"
        if python -V 2>&1 | tee /dev/stderr | grep '^Python 2'; then
            echo "upgrading python@2"
            brew upgrade python@2
        else
            echo "upgrading python"
            brew upgrade python
        fi
        echo "finding packages dependent on openssl"
        dependent_packages="$(brew deps --installed | awk -F: '/:.*openssl/{print $1}')"
        echo "upgrading packages dependent on openssl"
        # want package splitting
        # shellcheck disable=SC2086
        brew upgrade $dependent_packages
    fi
else
    echo "Not a HomeBrew system, aborting..."
    exit 1
fi