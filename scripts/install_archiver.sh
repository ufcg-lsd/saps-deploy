#!/bin/bash

# This script goal is to deploy the archiver service container in the host

readonly USAGE="usage: archiver.sh <conf_files_path>"
readonly ARCHIVER_IMAGE=ufcgsaps/archiver
readonly CONTAINER_NAME=archiver
readonly NETWORK_NAME=saps_net
readonly TEMP_STORAGE_DIR=/nfs

readonly CONF_FILE=archiver.conf
readonly LOG4J_FILE=log4j.properties
readonly EXECUTION_TAGS_FILE=execution_script_tags.json

IMAGE_TAG=latest

### Checks for all configuration files
check_conf_dir() {
  local CONF_FILES_PATH=${1}
  if [ ! -d ${CONF_FILES_PATH} ] 
  then
      echo "Directory ${CONF_FILES_PATH} DOES NOT exists." 
      exit 1
  fi
  for FILE in ${CONF_FILE} ${LOG4J_FILE} ${EXECUTION_TAGS_FILE}
  do
    if [[ ! -f "${CONF_FILES_PATH}/${FILE}" ]]; then
      echo "${FILE} was not found in the ${CONF_FILES_PATH} dir!"
      exit 1
    fi
  done
}

get_absolute_path() {
  local PATH=${1}
  echo $(cd ${PATH}; pwd)
}

# Checks if the container already exists
container_exists() {
  CHECK=$(docker ps -aq -f name="${CONTAINER_NAME}")
  if [ ! -z "${CHECK}" ]; then
    echo "The container ${CONTAINER_NAME} already exists"
    return 0
  fi
  return 1
}

# Create bridge network used by archiver
create_network() {
  CHECK=$(sudo docker network ls -q -f name=${NETWORK_NAME})
  if [ ! ${CHECK} ]; then
    echo "---> Creating ${NETWORK_NAME} network"
    docker network create "${NETWORK_NAME}"
  fi
}

# Removes the archiver container
remove_service() {
  # TODO check if exists the container before stop 
  echo "---> Removing current archiver service"
  sudo docker stop ${CONTAINER_NAME}
  sudo docker rm -v ${CONTAINER_NAME}
}

# Starts the archiver container
run() {
  # Getting absolute path because docker not allow use of relative path
  local CONF_FILES_PATH=$(get_absolute_path ${1})
  echo "---> Starting Dispatcher Service..."
  echo "---> Configuration files path: ${CONF_FILES_PATH}"
  docker run -dit \
    --name "${CONTAINER_NAME}" \
    --net="${NETWORK_NAME}" --net-alias=archiver \
    -v "${CONF_FILES_PATH}/${CONF_FILE}":/archiver/archiver.conf \
    -v "${CONF_FILES_PATH}/${LOG4J_FILE}":/archiver/log4j.properties \
    -v "${TEMP_STORAGE_DIR}":/archiver/nfs \
    "${ARCHIVER_IMAGE}":"${IMAGE_TAG}"
}

# TODO Create flag for allow remove current service if it exists
main() {
  if [ "$#" -ne 1 ]; then
      echo "Error. ${USAGE}"
      exit 1
  fi

  local CONF_FILES_PATH=${1}
  check_conf_dir ${CONF_FILES_PATH}

  if container_exists; then
    remove_service
  fi
  create_network
  run ${CONF_FILES_PATH}
}

main "$@"