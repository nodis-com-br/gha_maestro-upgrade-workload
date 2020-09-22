#!/usr/bin/env bash
set -e

[[ ${NODIS_DEPLOY_ENV} == "qa" && ${DEPLOY_QA_TO_PROD} != "false" ]] && NODIS_DEPLOY_ENV="prod"
[[ ${NODIS_DEPLOY_ENV} == "qa" && ${DEPLOY_QA_TO_DEV} == "true" ]] && NODIS_DEPLOY_ENV="dev"

export PIP_INDEX_URL="https://${NODIS_PYPI_USER}:${NODIS_PYPI_PASSWORD}@${NODIS_PYPI_HOST}/simple"

pip install maestro

git config --global user.email "${GH_PUSHER_EMAIL}"
git config --global user.name "${GH_PUSHER_NAME}"
git clone https://${GH_GLOBAL_TOKEN}@github.com/${GITHUB_REPOSITORY_OWNER}/${MAESTRO_REPOSITORY}.git

cd ${MAESTRO_REPOSITORY}

RESOURCE_FILE=`find . -name ${NODIS_PROJECT_NAME}.yaml`
NEW_VALUES="{\"${NODIS_DEPLOY_ENV}\":{\"image\":{\"tag\":\"${NODIS_PROJECT_VERSION}\"}}}"

case `echo ${RESOURCE_FILE} | wc -w` in
    1) maestro edit_values ${RESOURCE_FILE} -v "${NEW_VALUES}"
       maestro -e ${NODIS_DEPLOY_ENV} upgrade ${RESOURCE_FILE}
       git add ${RESOURCE_FILE}
       git commit -m "Updated ${RESOURCE_FILE} ${NODIS_DEPLOY_ENV} image tag to ${NODIS_PROJECT_VERSION} - skip_ci"
       git push;;
    0) echo "Resource file for ${NODIS_PROJECT_NAME} not found" && exit 1;;
    *) echo "Multiple resource files found: ${RESOURCE_FILE}" && exit 1;;
esac

