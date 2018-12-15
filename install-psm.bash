#!/usr/bin/env bash

if [[ $PATH == *"$HOME/.local/bin"* ]]; then
	dir="$HOME/.local/bin"
elif [[ $PATH == *"$HOME/bin"* ]]; then
	dir="$HOME/bin"
elif [[ $PATH == *"/usr/local/bin"* ]] && [ -w /usr/local/bin ]; then
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

echo "Installing to $dir/psm ..."
rm -f $dir/psm
curl -so $dir/psm https://raw.githubusercontent.com/anlutro/psm/master/psh.sh
chmod +x $dir/psm
