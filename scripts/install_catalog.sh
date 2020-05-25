#!/bin/bash

# This script goal is to deploy the catalog service container in the host

readonly USAGE="usage: catalog.sh <conf_files_path>"
readonly CATALOG_IMAGE=ufcgsaps/catalog
readonly CONTAINER_NAME=catalog
readonly VOLUME_NAME=catalogdata
readonly NETWORK_NAME=saps_net
readonly CATALOG_VARS_FILE=catalog.env

IMAGE_TAG=latest
CATALOG_PORT=5432
CATALOG_USER=admin
CATALOG_PASSWORD=admin
CATALOG_DB=saps

### Checks for all configuration files
check_conf_dir() {
  local CONF_FILES_PATH=${1}
  if [ ! -d ${CONF_FILES_PATH} ] 
  then
      echo "Directory ${CONF_FILES_PATH} DOES NOT exists." 
      exit 1
  fi
  for FILE in ${CATALOG_VARS_FILE}
  do
    if [[ ! -f "${CONF_FILES_PATH}/${FILE}" ]]; then
      echo "${FILE} was not found in the ${CONF_FILES_PATH} dir!"
      exit 1
    fi
  done
}

load_vars() {
  local CONF_FILES_PATH=${1}
  local VARS_FILE_PATH="${CONF_FILES_PATH}/${CATALOG_VARS_FILE}"
  if [[ -f "${VARS_FILE_PATH}" ]]; then
    echo "---> Loading ${CATALOG_VARS_FILE}"
    source "${VARS_FILE_PATH}"
  else
    echo "${CATALOG_VARS_FILE} was not found in the conf-files dir!"
    echo "Using default values for variables!"
  fi
}

# Checks if the container already exists
container_exists() {
  CHECK=$(docker ps -a -q -f name="${CONTAINER_NAME}")
  if [ ! -z "${CHECK}" ]; then
    echo "The container ${CONTAINER_NAME} already exists"
    return 0
  fi
  return 1
}

# Create bridge network used by catalog
create_network() {
  CHECK=$(sudo docker network ls -q -f name=${NETWORK_NAME})
  if [ ! ${CHECK} ]; then
    echo "---> Creating ${NETWORK_NAME} network"
    docker network create "${NETWORK_NAME}"
  fi
}

# Removes the catalog container and the volume
remove_service() {
  # TODO check if exists the container before stop 
  echo "---> Removing current catalog service"
  sudo docker stop ${CONTAINER_NAME}
  sudo docker rm -v ${CONTAINER_NAME}
}

# Starts the catalog container
run() {
  echo "---> Starting Catalog Service..."
  docker run -dit \
    --name "${CONTAINER_NAME}" \
    -p "${CATALOG_PORT}":5432 \
    --net="${NETWORK_NAME}" --net-alias=catalog \
    -v catalogdata:/var/lib/postgresql/data \
    -e POSTGRES_USER="${CATALOG_USER}" \
    -e POSTGRES_PASSWORD="${CATALOG_PASSWORD}" \
    -e POSTGRES_DB="${CATALOG_DB}" \
    "${CATALOG_IMAGE}":"${IMAGE_TAG}"
}

# TODO Create flag for allow not remove current service if it exists
main() {
  if [ "$#" -ne 1 ]; then
      echo "Error. ${USAGE}"
      exit 1
  fi

  local CONF_FILES_PATH=${1}
  check_conf_dir ${CONF_FILES_PATH}

  load_vars ${CONF_FILES_PATH}
  if container_exists; then
    remove_service
  fi
  create_network
  run
}

main "$@"