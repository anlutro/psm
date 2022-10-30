#!/bin/bash
set -eu

[ -z "${PSM_VENV_DIR-}" ] && PSM_VENV_DIR=~/.local/share/psm
[ -z "${PSM_BIN_DIR-}" ] && PSM_BIN_DIR=~/.local/bin
[ -z "${PSM_PYTHON-}" ] && PSM_PYTHON=$(
    find $HOME/.local/bin /usr/local/bin /usr/bin -regex '.*/python[3-9][0-9.]*' -printf '%f\n' \
    | sort -V | tail -1
)
PSM_PYTHON_VER=$($PSM_PYTHON --version 2>&1 | cut -d' ' -f2)

export PIP_DISABLE_PIP_VERSION_CHECK=1

_get_pkg_name() {
    if [ -d "$1" ] && [ -e "$1/setup.py" ]; then
        $PSM_PYTHON "$1/setup.py" --name
    else
        $PSM_PYTHON -c "from pkg_resources import parse_requirements; print(next(parse_requirements('$1')).name)"
    fi
}

_psm_list() {
    {
        for venv in $PSM_VENV_DIR/*/; do
            name=$(basename $venv)
            if [ -e $venv/bin/python ]; then
                $venv/bin/pip list "$@" | grep -P "^$name\s+" || true
            else
                echo >&2 "WARNING: venv for $name is broken! to fix: psm reinstall $name"
            fi
        done
    } | column -t
}

_psm_list_all_scripts() {
    if [ $# -gt 0 ]; then
        pkgs="$*"
    else
        pkgs=$(find ~/.local/share/psm/ -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | sort)
    fi
    for pkg in $pkgs; do
        scripts=$(_psm_list_scripts $pkg)
        if [ -n "$scripts" ]; then
            echo $pkg: $scripts
        fi
    done
}

_psm_list_scripts() {
    if [ -z "$1" ]; then
        echo "missing argument!" >&2
        return 1
    fi
    venv=$PSM_VENV_DIR/$1
    if [ ! -d "$venv" ]; then
        echo >&2 "venv does not exist: $venv"
        return 1
    fi
    if [ ! -e "$venv/bin/python" ]; then
        echo >&2 "bin/python is broken for venv: $venv"
        return 1
    fi
    $venv/bin/python -c "
from pkg_resources import get_distribution
from os.path import abspath, basename, join
dist = get_distribution('$1')
scripts = dist.get_entry_map().get('console_scripts', {}).values()
for script in scripts:
    print(script.name)
if dist.has_metadata('installed-files.txt'):
    for line in dist.get_metadata_lines('installed-files.txt'):
        path = abspath(join(dist.egg_info, line.split(',')[0]))
        if path.startswith('$venv/bin/'):
            print(basename(path))
if dist.has_metadata('RECORD'):
    records = [s.split(',')[0] for s in dist.get_metadata_lines('RECORD')]
    bin_paths = [s for s in records if '/bin/' in s and not s.endswith('.pyc')]
    for bin_path in bin_paths:
        print(bin_path.split('/')[-1])
" | sort | uniq
}

_install_cleanup() {
    rm -rf ${PSM_VENV_DIR:?}/$pkg_name
}

_psm_install() {
    for pkg in "$@"; do
        pkg_name=$(_get_pkg_name "$pkg")
        if [ -d $PSM_VENV_DIR/$pkg_name ]; then
            echo "$pkg_name already exists, not doing anything."
            echo "Hint: did you mean psm upgrade or psm reinstall?"
        else
            trap _install_cleanup EXIT
            echo "Creating virtual environment for $pkg_name with $PSM_PYTHON ..."
            $PSM_PYTHON -m venv $PSM_VENV_DIR/$pkg_name || exit 1
            _psm_upgrade "$pkg"
            trap - EXIT
        fi
    done
}

_psm_reinstall() {
    for pkg in "$@"; do
        _psm_uninstall "$pkg"
        _psm_install "$pkg"
    done
}

_upgade_cleanup() {
    echo "PSM script aborted in the middle of upgrade!"
    echo "$venv may be in an inconsistent state."
    echo "If broken, run:  psm reinstall '$pkg'"
}

_psm_upgrade() {
    for pkg in "$@"; do
        pkg_name=$(_get_pkg_name "$pkg")
        venv=$PSM_VENV_DIR/$pkg_name

        # determine if package is editable
        if [ -d "$pkg" ] && [ -e "$pkg/setup.py" ]; then
            editable_dir=$(readlink -f "$pkg")
        else
            editable_dir=$($venv/bin/pip list --editable | awk "\$1 == \"$pkg_name\" { print \$3 }")
        fi

        trap _upgade_cleanup EXIT

        # check if venv can be upgraded with new python
        venv_pyver=$($venv/bin/python --version 2>&1 | cut -d' ' -f2)
        if [ $venv_pyver != $PSM_PYTHON_VER ]; then
            echo "Recreating venv with new python ($PSM_PYTHON) for $pkg_name ..."
            $PSM_PYTHON -m venv --clear $venv
        fi

        echo "Installing/upgrading pip and setuptools for $pkg_name ..."
        $venv/bin/pip install -q -U pip setuptools

        echo "Installing package: $pkg_name ..."
        if [ -n "$editable_dir" ]; then
            pip_install_args=(-e "$editable_dir")
        else
            pip_install_args=("$pkg")
        fi
        $venv/bin/pip install -q -U "${pip_install_args[@]}"

        echo "Creating script symlinks for $pkg_name ..."
        _psm_list_scripts $pkg_name | xargs -r -I% ln -sf $venv/bin/% $PSM_BIN_DIR/

        trap - EXIT
    done
}

_psm_upgrade_all() {
    pkgs=$(
        find $PSM_VENV_DIR -mindepth 1 -maxdepth 1 -type d -print0 \
        | xargs -r -0 -n1 basename
    )
    _psm_upgrade $pkgs
}

_psm_uninstall() {
    for pkg in "$@"; do
        echo "Uninstalling package: $pkg ..."
        _psm_list_scripts $pkg | xargs -r -I% rm -f $PSM_BIN_DIR/%
        rm -rf "${PSM_VENV_DIR:?}/$pkg"
    done
}

_psm_help() {
    echo "psm - python script manager"
    echo
    echo "psm install pkg [pkg ...]"
    echo "psm uninstall pkg [pkg ...]"
    echo "psm upgrade pkg [pkg ...]"
    echo "psm upgrade-all"
}

psm() {
    if [ $# -gt 0 ]; then
        arg="$1" && shift
        cmd="$(echo "$arg" | tr -s - _)"
    fi

    if [ -z "${cmd-}" ] || [ "$arg" = '-h' ] || [ "$arg" = '--help' ]; then
        func=_psm_help
    else
        func="_psm_$cmd"
    fi

    if ! type $func >/dev/null 2>&1; then
        echo "Unknown command $arg"
        exit 1
    fi

    $func "$@"
}

psm "$@"
