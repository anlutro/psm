# `psm` - python script manager

This is a tool inspired by and similar to pipsi, but just a standalone shell script, which means you don't need to have `pip` or `virtualenv` or anything other than plain Python 3.4 or higher installed on your system to install or use it.

## Installation

```
curl https://raw.githubusercontent.com/anlutro/psm/master/install-psm.bash | bash
```

... or just copy `psm.bash` to your favorite directory in `$PATH`.

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

## License

The contents of this repository are released under the [GPL v3 license](https://opensource.org/licenses/GPL-3.0). See the [LICENSE](LICENSE) file included for more information.
