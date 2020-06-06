#!/bin/sh
set -eux

fail() {
	echo "$*" >&2
	exit 1
}

command -v python3 || fail 'python3 not found!'
python3 -m venv --help >/dev/null || fail 'venv module not installed!'

./psm.sh install ranger-fm==1.9.2
ranger --help >/dev/null

./psm.sh install streamlink
streamlink --help >/dev/null

./psm.sh list | grep -qx 'ranger-fm 1.9.2' || fail "ranger not listed!"
./psm.sh list | grep -qx 'streamlink .*' || fail "streamlink not listed!"
./psm.sh list-scripts ranger-fm | grep -qx 'ranger' || fail "ranger script not listed!"

./psm.sh uninstall streamlink
[ ! -e $HOME/.local/bin/streamlink ] || fail "uninstall didn't remove bin!"

./psm.sh upgrade-all
./psm.sh list | grep -qxv 'ranger-fm 1.9.1' || fail "upgrade-all didn't upgrade ranger-fm!"
