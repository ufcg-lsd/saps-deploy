#!/bin/bash
# This script goal is to generate the Ansible hosts and ansible.cfg files

readonly HOSTS_CONF_FILE_PATH="./hosts.conf"
readonly ANSIBLE_FILES_DIR_PATH="./ansible-playbook"
readonly ANSIBLE_HOSTS_FILE_PATH="${ANSIBLE_FILES_DIR_PATH}/hosts"
readonly ANSIBLE_CFG_FILE_PATH=${ANSIBLE_FILES_DIR_PATH}/"ansible.cfg"

# Get the value of field from conf file
get_value() {
  local FILE_PATH=${1}
  local FIELD_NAME=${2}

  local FIELD=$(grep ${FIELD_NAME} ${FILE_PATH})
  local VALUE=$(cut -d"=" -f2- <<< ${FIELD})
  echo "${VALUE}"
}

generate_ansible_host_file() {
  echo "[catalog_host]" > ${ANSIBLE_HOSTS_FILE_PATH}
  echo ${CATALOG_HOST_IP} >> ${ANSIBLE_HOSTS_FILE_PATH}
  echo "[catalog_host:vars]" >> ${ANSIBLE_HOSTS_FILE_PATH}
  echo "ansible_ssh_private_key_file=${CATALOG_HOST_PRIVATE_KEY_FILE_PATH}" >> ${ANSIBLE_HOSTS_FILE_PATH}
  echo "ansible_python_interpreter=/usr/bin/python3" >> ${ANSIBLE_HOSTS_FILE_PATH}
  echo "" >> ${ANSIBLE_HOSTS_FILE_PATH}
  echo "[dispatcher_host]" >> ${ANSIBLE_HOSTS_FILE_PATH}
  echo ${DISPATCHER_HOST_IP} >> ${ANSIBLE_HOSTS_FILE_PATH}
  echo "[dispatcher_host:vars]" >> ${ANSIBLE_HOSTS_FILE_PATH}
  echo "ansible_ssh_private_key_file=${DISPATCHER_HOST_PRIVATE_KEY_FILE_PATH}" >> ${ANSIBLE_HOSTS_FILE_PATH}
  echo "ansible_python_interpreter=/usr/bin/python3" >> ${ANSIBLE_HOSTS_FILE_PATH}
  echo "" >> ${ANSIBLE_HOSTS_FILE_PATH}
  echo "[scheduler_host]" >> ${ANSIBLE_HOSTS_FILE_PATH}
  echo ${SCHEDULER_HOST_IP} >> ${ANSIBLE_HOSTS_FILE_PATH}
  echo "[scheduler_host:vars]" >> ${ANSIBLE_HOSTS_FILE_PATH}
  echo "ansible_ssh_private_key_file=${SCHEDULER_HOST_PRIVATE_KEY_FILE_PATH}" >> ${ANSIBLE_HOSTS_FILE_PATH}
  echo "ansible_python_interpreter=/usr/bin/python3" >> ${ANSIBLE_HOSTS_FILE_PATH}
  echo "" >> ${ANSIBLE_HOSTS_FILE_PATH}
  echo "[archiver_host]" >> ${ANSIBLE_HOSTS_FILE_PATH}
  echo ${ARCHIVER_HOST_IP} >> ${ANSIBLE_HOSTS_FILE_PATH}
  echo "[archiver_host:vars]" >> ${ANSIBLE_HOSTS_FILE_PATH}
  echo "ansible_ssh_private_key_file=${ARCHIVER_HOST_PRIVATE_KEY_FILE_PATH}" >> ${ANSIBLE_HOSTS_FILE_PATH}
  echo "ansible_python_interpreter=/usr/bin/python3" >> ${ANSIBLE_HOSTS_FILE_PATH}
  echo "" >> ${ANSIBLE_HOSTS_FILE_PATH}
  echo "[temp_storage_host]" >> ${ANSIBLE_HOSTS_FILE_PATH}
  echo ${TEMP_STORAGE_HOST_IP} >> ${ANSIBLE_HOSTS_FILE_PATH}
  echo "[temp_storage_host:vars]" >> ${ANSIBLE_HOSTS_FILE_PATH}
  echo "ansible_ssh_private_key_file=${TEMP_STORAGE_HOST_PRIVATE_KEY_FILE_PATH}" >> ${ANSIBLE_HOSTS_FILE_PATH}
  echo "ansible_python_interpreter=/usr/bin/python3" >> ${ANSIBLE_HOSTS_FILE_PATH}
}

generate_ansible_cfg() {
  echo "[defaults]" > ${ANSIBLE_CFG_FILE_PATH}
  echo "inventory = hosts" >> ${ANSIBLE_CFG_FILE_PATH}
  echo "remote_user = ${REMOTE_USER}" >> ${ANSIBLE_CFG_FILE_PATH}
  echo "host_key_checking = False" >> ${ANSIBLE_CFG_FILE_PATH}
}

# Generate content of Ansible hosts file

readonly CATALOG_HOST_IP_PATTERN="catalog_host_ip"
readonly CATALOG_HOST_PRIVATE_KEY_FILE_PATH_PATTERN="catalog_host_ssh_private_key_file"
readonly DISPATCHER_HOST_IP_PATTERN="dispatcher_host_ip"
readonly DISPATCHER_HOST_PRIVATE_KEY_FILE_PATH_PATTERN="dispatcher_host_ssh_private_key_file"
readonly SCHEDULER_HOST_IP_PATTERN="scheduler_host_ip"
readonly SCHEDULER_HOST_PRIVATE_KEY_FILE_PATH_PATTERN="scheduler_host_ssh_private_key_file"
readonly ARCHIVER_HOST_IP_PATTERN="archiver_host_ip"
readonly ARCHIVER_HOST_PRIVATE_KEY_FILE_PATH_PATTERN="archiver_host_ssh_private_key_file"
readonly TEMP_STORAGE_HOST_IP_PATTERN="temp_storage_host_ip"
readonly TEMP_STORAGE_HOST_PRIVATE_KEY_FILE_PATH_PATTERN="temp_storage_host_ssh_private_key_file"
readonly REMOTE_USER_PATTERN="remote_user"

readonly CATALOG_HOST_IP=$(get_value ${HOSTS_CONF_FILE_PATH} ${CATALOG_HOST_IP_PATTERN})
readonly CATALOG_HOST_PRIVATE_KEY_FILE_PATH=$(get_value ${HOSTS_CONF_FILE_PATH} ${CATALOG_HOST_PRIVATE_KEY_FILE_PATH_PATTERN})
readonly DISPATCHER_HOST_IP=$(get_value ${HOSTS_CONF_FILE_PATH} ${DISPATCHER_HOST_IP_PATTERN})
readonly DISPATCHER_HOST_PRIVATE_KEY_FILE_PATH=$(get_value ${HOSTS_CONF_FILE_PATH} ${DISPATCHER_HOST_PRIVATE_KEY_FILE_PATH_PATTERN})
readonly SCHEDULER_HOST_IP=$(get_value ${HOSTS_CONF_FILE_PATH} ${SCHEDULER_HOST_IP_PATTERN})
readonly SCHEDULER_HOST_PRIVATE_KEY_FILE_PATH=$(get_value ${HOSTS_CONF_FILE_PATH} ${SCHEDULER_HOST_PRIVATE_KEY_FILE_PATH_PATTERN})
readonly ARCHIVER_HOST_IP=$(get_value ${HOSTS_CONF_FILE_PATH} ${ARCHIVER_HOST_IP_PATTERN})
readonly ARCHIVER_HOST_PRIVATE_KEY_FILE_PATH=$(get_value ${HOSTS_CONF_FILE_PATH} ${ARCHIVER_HOST_PRIVATE_KEY_FILE_PATH_PATTERN})
readonly TEMP_STORAGE_HOST_IP=$(get_value ${HOSTS_CONF_FILE_PATH} ${TEMP_STORAGE_HOST_IP_PATTERN})
readonly TEMP_STORAGE_HOST_PRIVATE_KEY_FILE_PATH=$(get_value ${HOSTS_CONF_FILE_PATH} ${TEMP_STORAGE_HOST_PRIVATE_KEY_FILE_PATH_PATTERN})

readonly REMOTE_USER=$(get_value ${HOSTS_CONF_FILE_PATH} ${REMOTE_USER_PATTERN})

generate_ansible_host_file
generate_ansible_cfg

(cd $ANSIBLE_FILES_DIR_PATH && ansible-playbook -vvv deploy.yml)
