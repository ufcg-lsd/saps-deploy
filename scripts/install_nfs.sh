#!/bin/bash

is_a_export_dir() {
  local LOCAL_EXPORT_DIR=${3}
  if showmount -e localhost | grep -q "${LOCAL_EXPORT_DIR}"; then
    return 0
  fi
  return 1
}

setup_nfs_client() {
  echo "--> Setting up the NFS Client"
  local NFS_SERVER=${1}
  local NFS_EXPORT_DIR=${2}
  local LOCAL_EXPORT_DIR=${3}
  mkdir -p ${LOCAL_EXPORT_DIR}

  if is_a_export_dir ${LOCAL_EXPORT_DIR}; then
    echo "The directory chosen for mounting is exported by the NFS server"
    exit 0
  fi

  if nfsstat --nfs -m | grep -q "${LOCAL_EXPORT_DIR} from ${NFS_SERVER}:${NFS_EXPORT_DIR}"; then
    echo "The ${LOCAL_EXPORT_DIR}  directory is already mounted"
    exit 0
  fi
  if mountpoint -q -- ${LOCAL_EXPORT_DIR} ; then
    echo "Umounting current ${LOCAL_EXPORT_DIR} ..."
    umount -f -l ${LOCAL_EXPORT_DIR} 
  fi
  mount -t nfs ${NFS_SERVER}:${NFS_EXPORT_DIR} ${LOCAL_EXPORT_DIR}
}

setup_nfs_service() {
  local EXPORT_DIR=${1}
  echo "Creating ${EXPORT_DIR} directory"
  mkdir -p ${EXPORT_DIR}
  EXPORT_CONF="${EXPORT_DIR} \*(rw,insecure,no_subtree_check,async,no_root_squash)"
  # Check if the config is already in the exports file
  if ! grep -q "${EXPORT_CONF}" /etc/exports; then
    echo "${EXPORT_DIR} *(rw,insecure,no_subtree_check,async,no_root_squash)" >> /etc/exports
  fi
  service nfs-kernel-server restart
}

main() {
  local OPT=${1}
  case ${OPT} in
    client) shift
      setup_nfs_client "$@" 
      ;;
    service) shift
      setup_nfs_service "$@"
      ;;
  esac
}

main "$@"