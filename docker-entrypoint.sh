#!/bin/sh
set -e

kong migrations bootstrap

exec kong start
