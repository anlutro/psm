#!/bin/sh
set -eux

fail() {
	echo "$*" >&2
	exit 1
}

command -v python3 || fail 'python3 not found!'
python3 -m venv --help >/dev/null || fail 'venv module not installed!'
mkdir -p $HOME/.local/bin

./psm.bash install ranger-fm==1.9.2
ranger --help >/dev/null

./psm.bash install streamlink
streamlink --help >/dev/null

./psm.bash list | grep -qx 'ranger-fm 1.9.2' || fail "ranger not listed!"
./psm.bash list | grep -qx 'streamlink .*' || fail "streamlink not listed!"
./psm.bash list-scripts ranger-fm | grep -qx 'ranger' || fail "ranger script not listed!"

./psm.bash uninstall streamlink
[ ! -e $HOME/.local/bin/streamlink ] || fail "uninstall didn't remove bin!"

./psm.bash upgrade-all
./psm.bash list | grep -qxv 'ranger-fm 1.9.1' || fail "upgrade-all didn't upgrade ranger-fm!"
