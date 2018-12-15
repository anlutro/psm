# `psm` - python script manager

This is a tool inspired by and similar to pipsi, but just a standalone shell script, which means you don't need to have `pip` or `virtualenv` or anything other than plain Python 3.4 or higher installed on your system to install or use it.

## Installation

```
curl https://raw.githubusercontent.com/anlutro/psm/master/install-psh.bash | bash
```

## Usage

Install one or more pip packages and their scripts:

```
psm install bpython streamlink
```

Upgrade one or more existing packages, or upgrade all installed packages:

```
psm upgrade bpyton streamlink
psm upgrade-all
```

Uninstall one or more packages:

```
psm uninstall streamlink
```
