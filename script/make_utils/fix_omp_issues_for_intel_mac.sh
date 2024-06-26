#!/usr/bin/env bash

# Fix OMP issues for macOS Intel, https://github.com/zama-ai/concrete-ml-internal/issues/3951
# This should be avoided for macOS with arm64 architecture

set -ex

UNAME=$(uname)
MACHINE=$(uname -m)
PYTHON_VERSION=$(python --version | cut -d' ' -f2 | cut -d'.' -f1,2)

# The error does not seem to happen on python 3.10 (on MacOS 13.6.6)
if [ "$UNAME" == "Darwin" ] && [ "$MACHINE" != "arm64" ] && [ "$PYTHON_VERSION" != "3.10" ]
then

    # We need to source the venv here, since it's not done in the CI
    # shellcheck disable=SC1090,SC1091
    source  .venv/bin/activate

    # In the following, `command -v python` is for `which python` in a way which is approved by our
    # shell lint
    WHICH_VENV=$(command -v python | sed -e "s@bin/python@@")
    WHICH_PYTHON=$(python -c 'import sys; print(f"python{sys.version_info.major}.{sys.version_info.minor}")')

    rm "${WHICH_VENV}"/lib/"${WHICH_PYTHON}"/site-packages/torch/lib/libiomp5.dylib
    ln -s "${WHICH_VENV}"/lib/"${WHICH_PYTHON}"/site-packages/concrete/.dylibs/libomp.dylib "${WHICH_VENV}"/lib/"${WHICH_PYTHON}"/site-packages/torch/lib/libiomp5.dylib
    rm "${WHICH_VENV}"/lib/"${WHICH_PYTHON}"/site-packages/functorch/.dylibs/libiomp5.dylib
    ln -s "${WHICH_VENV}"/lib/"${WHICH_PYTHON}"/site-packages/concrete/.dylibs/libomp.dylib "${WHICH_VENV}"lib/"${WHICH_PYTHON}"/site-packages/functorch/.dylibs/libiomp5.dylib
fi



