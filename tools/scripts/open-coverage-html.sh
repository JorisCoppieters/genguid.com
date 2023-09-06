#!/bin/bash
set -e # Bail on first error
source "$(dirname "$0")/_lib.sh"

chrome "$(pwd)/coverage/index.html"