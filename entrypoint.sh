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
    1) maestro -K environ edit ${RESOURCE_FILE} -v "${NEW_VALUES}"
       maestro -K environ -e ${NODIS_DEPLOY_ENV} upgrade ${RESOURCE_FILE}
       git add ${RESOURCE_FILE}
       git commit -m "Updated ${NODIS_PROJECT_NAME} ${NODIS_DEPLOY_ENV} image tag to ${NODIS_PROJECT_VERSION} - skip_ci"
       git push;;
    0) echo "Resource file for ${NODIS_PROJECT_NAME} not found" && exit 1;;
    *) echo "Multiple resource files found: ${RESOURCE_FILE}" && exit 1;;
esac

curl --location --header 'Content-Type: application/json' --request POST 'https://discord.com/api/webhooks/740966411366563870/k34Nc5ee0_j1OAzNNRNxGnUiUTicAX3CAYyjtyZXd9Q395NTHZUqlxWf31JOdTSUhfc6' \
     --data-raw '{"embeds":[{"title":"Application deployed!","description":"The application **'${NODIS_PROJECT_NAME}'** was deployed with the version **'${NODIS_PROJECT_VERSION}'**","color":3311947,"fields":[{"name":"Triggered by","value":"'${GITHUB_ACTOR}'","inline":true},{"name":"Environment","value":"'${NODIS_DEPLOY_ENV}'","inline":true},{"name":"Repo","value":"'${GITHUB_SERVER_URL}'/'${GITHUB_REPOSITORY}'","inline":true}]}]}'
