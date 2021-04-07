#!/usr/bin/env python3

import argparse


def install(args):
	print('install', args)


def upgrade(args):
	print('upgrade', args)


def parse_args(args=None):
	parser = argparse.ArgumentParser()
	parser.add_argument('-p', '--python')
	funcs = parser.add_subparsers(dest='func')

	install_func = funcs.add_parser('install')
	install_func.add_argument('package')

	upgrade_func = funcs.add_parser('upgrade')
	upgrade_mutex = upgrade_func.add_mutually_exclusive_group()
	upgrade_mutex.add_argument('packages', nargs='*', default=[])
	upgrade_mutex.add_argument('--all')

	args = parser.parse_args()

	args.func = globals().get(args.func)

	return args


def main():
	args = parse_args()
	args.func(args)


if __name__ == '__main__':
	main()
