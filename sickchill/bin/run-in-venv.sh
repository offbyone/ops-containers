#!/bin/bash
VENV_ROOT=$1
shift

if [ ! -f "$VENV_ROOT/bin/activate" ]; then
    echo '$1 must be an existing venv root' >&2
    exit 1
fi

. "$VENV_ROOT/bin/activate"
exec "$@"
