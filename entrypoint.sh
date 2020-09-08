#!/usr/bin/env bash
set -e

KUBECONFIG_FILE="kubeconfig"
KUBECTL_OPTIONS="-v=6 --kubeconfig=${KUBECONFIG_FILE} -n ${NODIS_K8S_NAMESPACE} --context ${NODIS_DEPLOY_ENV}"

export CHARTMUSEUM_URI="https://${NODIS_CHART_REPOSITORY_USER}:${NODIS_CHART_REPOSITORY_PASSWORD}@${NODIS_CHART_REPOSITORY_HOST}"
pip install -i "https://${NODIS_PYPI_USER}:${NODIS_PYPI_PASSWORD}@${NODIS_PYPI_HOST}/simple" maestro

maestro export_kubeconfig ${KUBECONFIG_FILE}

kubectl ${KUBECTL_OPTIONS} config get-contexts
kubectl ${KUBECTL_OPTIONS} scale ${NODIS_SERVICE_TYPE}/${NODIS_SERVICE_NAME} --current-replicas=0 --replicas=1 || true
kubectl ${KUBECTL_OPTIONS} set image ${NODIS_SERVICE_TYPE}/${NODIS_SERVICE_NAME} ${NODIS_SERVICE_NAME}=${NODIS_IMAGE_NAME}:${NODIS_FULL_VERSION}
