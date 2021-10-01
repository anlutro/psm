#!/bin/sh
set -eux

fail() {
	echo "$*" >&2
	exit 1
}

command -v python3 || fail 'python3 not found!'
python3 -m venv --help >/dev/null || fail 'venv module not installed!'
mkdir -p $HOME/.local/bin

./psm.bash install black==21.7b0
black --help >/dev/null

./psm.bash install streamlink
streamlink --help >/dev/null

./psm.bash list | grep -qPx 'black\s+21.7b0' || fail "black not listed!"
./psm.bash list | grep -qPx 'streamlink\s.*' || fail "streamlink not listed!"
./psm.bash list-scripts black | grep -qx 'black' || fail "black script not listed!"

./psm.bash uninstall streamlink
[ ! -e $HOME/.local/bin/streamlink ] || fail "uninstall didn't remove bin/streamlink!"

./psm.bash upgrade-all
./psm.bash list | grep -qPxv 'black\s*' || fail "upgrade-all didn't upgrade black!"
