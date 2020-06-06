#!/usr/bin/env bash

IFS=':' read -r -a pathlist <<< "$PATH"
path_contains() {
	match="$1"
	for path in "${pathlist[@]}"; do
		[ "$path" = "$match" ] && return 0
	done
	return 1
}

if path_contains "$HOME/.local/bin"; then
	dir="$HOME/.local/bin"
elif path_contains "$HOME/bin"; then
	dir="$HOME/bin"
elif path_contains /usr/local/bin && [ -w /usr/local/bin ]; then
	dir=/usr/local/bin
else
	echo 'No appropriate directory found in your PATH!'
	echo
	echo 'Create one, like ~/.local/bin or ~/bin and'
	echo 'add it to your .profile or .bashrc, e.g.:'
	echo
	echo 'PATH="$HOME/.local/bin:$PATH"'
	exit 1
fi

if [ ! -d "$dir" ]; then
	echo "$dir found in PATH and will be used, but does not exist - creating it"
	mkdir -p "$dir"
fi

echo "Installing to $dir/psm ..."
rm -f $dir/psm
curl -so $dir/psm https://raw.githubusercontent.com/anlutro/psm/master/psm.sh
chmod +x $dir/psm
