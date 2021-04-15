#!/usr/bin/env python

import os
import pathlib
import argparse


def main():
    pass


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
                description="x86 Hello World build script")

    parser.add_argument("-c", "--clean", help="remove generated build files")

    return parser.parse_args()


if __name__ == "__main__":
    args = parse_args()
    main()
