#!/usr/bin/env bash

EXPORT_DIR=${1}

if [[ -z "${EXPORT_DIR}" ]]; then
    echo "Usage: bash install_nfs.server.sh <export_dir>"
    exit 1
fi

create_export_dir(){
  echo "Creating ${EXPORT_DIR} directory"
  mkdir -p ${EXPORT_DIR}
  # Remove any restrictions in the directory permissions.
  chown -R nobody:nogroup ${EXPORT_DIR}
  # Given the read, write and execute privileges to all the contents inside the directory.
  chmod 777 ${EXPORT_DIR}
}

grant_access_to_client(){
  EXPORT_CONF="${EXPORT_DIR} \*(rw,insecure,no_subtree_check,async,no_root_squash)"
  # Check if the config is already in the exports file
  if ! grep -q "${EXPORT_CONF}" /etc/exports; then
    echo "${EXPORT_DIR} *(rw,insecure,no_subtree_check,async,no_root_squash)" >> /etc/exports
  fi
}

main() {
  apt install -y nfs-kernel-server
  create_export_dir
  grant_access_to_client
  exportfs -a
  systemctl restart nfs-kernel-server
}

# main