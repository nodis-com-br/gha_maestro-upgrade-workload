#!/usr/bin/env bash
set -e

[[ ${NODIS_DEPLOY_ENV} == "qa" && ${DEPLOY_QA_TO_PROD} != "false" ]] && NODIS_DEPLOY_ENV="prod"

export CHARTMUSEUM_URI="https://${NODIS_CHART_REPOSITORY_USER}:${NODIS_CHART_REPOSITORY_PASSWORD}@${NODIS_CHART_REPOSITORY_HOST}"
pip install -i "https://${NODIS_PYPI_USER}:${NODIS_PYPI_PASSWORD}@${NODIS_PYPI_HOST}/simple" maestro
git clone https://${GH_GLOBAL_TOKEN}@github.com/${GITHUB_REPOSITORY_OWNER}/${MAESTRO_REPOSITORY}.git
cd ${MAESTRO_REPOSITORY}

RESOURCE_FILE=`find . -name ${NODIS_PROJECT_NAME}.yaml`
NEW_VALUES="{\"${NODIS_DEPLOY_ENV}\":{\"image\":{\"tag\":\"${NODIS_PROJECT_VERSION}\"}}}"

case `echo ${RESOURCE_FILE} | wc -w` in
    1) maestro edit_values ${RESOURCE_FILE} -v "${NEW_VALUES}"
       maestro -e ${NODIS_DEPLOY_ENV} upgrade ${RESOURCE_FILE}
       git add ${RESOURCE_FILE}
       git commit -m "Updated ${RESOURCE_FILE} ${NODIS_DEPLOY_ENV} tag: ${NODIS_PROJECT_VERSION} - skip_ci"
       git push;;
    0) echo "Resource file for ${NODIS_PROJECT_NAME} not found" && exit 1;;
    *) echo "Multiple resource files found: ${RESOURCE_FILE}" && exit 1;;
esac

