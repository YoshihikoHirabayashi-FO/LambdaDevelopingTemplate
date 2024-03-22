#!/bin/bash
set -e

if [ ! -d "/dist" ]; then
  echo "# Output destination folder ('/dist') is not mounted."
  exit 1
fi

# init log file
logfile=/dist/buil_layer.log
rm -f $logfile
exec > >(tee -a $logfile) 2>&1

if [ ! -d "/source" ]; then
  echo "# Source folder ('/source') is not mounted."
  exit 1
fi

if [ -z "$ZIP_FILE_NAME" ]; then
  ZIP_FILE_NAME="lambda_layer.zip"
fi

if [ -z "$PYTHON_VERSION" ]; then
  PYTHON_VERSION="3.12"
fi
echo "build lambda layer with python version $PYTHON_VERSION to $ZIP_FILE_NAME"

# create layer directory
LAYER_DIR=layer/python/lib/python$PYTHON_VERSION/site-packages
echo "# mkdir -p $LAYER_DIR"
mkdir -p $LAYER_DIR

# set python version
PYTHON_VERSION_ESCAPED=$(echo "${PYTHON_VERSION}" | sed 's/\./\\./g')
if ! pyenv versions --bare | grep -E "^${PYTHON_VERSION_ESCAPED}(\.[0-9]+)?$"; then
    echo "# pyenv install ${PYTHON_VERSION}"
    pyenv install ${PYTHON_VERSION}
fi
echo "# pyenv local $PYTHON_VERSION"
pyenv local $PYTHON_VERSION

# install packages
if [ -f "/source/requirements.txt" ]; then
  echo "# pip install -r /source/requirements.txt -t \"$LAYER_DIR\""
  pip install -r /source/requirements.txt -t "$LAYER_DIR"
fi

# copy other sources
echo "# rsync -av --exclude='requirements.txt' /source/ \"$LAYER_DIR\""
rsync -av --exclude='requirements.txt' /source/ "$LAYER_DIR"

# zip
echo "# cd layer"
cd layer
echo "# zip -r \"/dist/$ZIP_FILE_NAME\" ."
zip -r "/dist/$ZIP_FILE_NAME" .

# finished
echo "# all process finished successfully
"