#!/usr/bin/env bash

IFS=':' read -r -a pathlist <<< "$PATH"
path_contains_writeable_dir() {
	match="$1"
	for path in "${pathlist[@]}"; do
		if [ "$path" = "$match" ] && [ -d "$path" ] && [ -w "$path" ]; then
			return 0
		fi
	done
	return 1
}

if path_contains_writeable_dir "$HOME/.local/bin"; then
	dir="$HOME/.local/bin"
elif path_contains_writeable_dir "$HOME/bin"; then
	dir="$HOME/bin"
elif path_contains_writeable_dir /usr/local/bin; then
	dir=/usr/local/bin
else
	echo 'No existing, writeable directory found in your PATH!'
	echo
	echo 'Create one, like ~/.local/bin or ~/bin and'
	echo 'add it to your .profile or .bashrc, e.g.:'
	echo
	echo 'PATH="$HOME/.local/bin:$PATH"'
	exit 1
fi

echo "Installing to $dir/psm ..."
rm -f $dir/psm
curl -so $dir/psm https://raw.githubusercontent.com/anlutro/psm/master/psm.bash
chmod +x $dir/psm
