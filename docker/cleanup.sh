#!/bin/bash -ev

echo "Remove unused files (examples, documentation, notebooks,...)"
source ${TELEMAC_ROOT}/setenv.sh
rm -rfv ${HOMETEL}/documentation
rm -rfv ${HOMETEL}/examples
rm -rfv ${HOMETEL}/notebooks
