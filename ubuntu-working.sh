#!/usr/bin/env bash

if [[ -f ~/.virbir.rc ]]; then
  . ~/.virbir.rc
fi

# set defaults, override from config file if it exists
vm_cpus=${cpus:-8}
vm_mem=${memory:-4096}
vm_disk=${disksize:-50}
vm_storagepool=${pool:-default}
vm_user=${vm_user:-$USER}
vm_importid=${vm_importid:-"gh:msplival"}
vm_pwd=${vm_pwd:-"ubuntu"}


FOO=$(getopt -o n:i:c:m:d:p: --longoptions name:,image:,cpus:,memory:,disksize:,pool: -n "virbir" -- "$@" )
eval set -- "$FOO"
while true; do
    case "$1" in
    -n | --name ) vm_name="$2"; shift 2;;
    -i | --image ) imagefile="$2"; shift 2;;
    -c | --cpus ) vm_cpus="$2"; shift 2;;
    -m | --memory ) vm_mem="$2"; shift 2;;
    -d | --disksize ) vm_disk="$2"; shift 2;;
    -p | --pool ) vm_storagepool="$2"; shift 2;;
    --) shift ; break ;;
    esac
done

if [[ -z $vm_name ]]; then
  echo "Please provide virtual machina name."
  exit 1
fi

if [[ -z $imagefile ]]; then
  echo "Please provide iso image to boot from."
  exit 2
fi

hashed_password=$(mkpasswd --method=SHA-512 "$vm_pwd")
workTempDir=$(mktemp -d)

autoinstall_yaml=$(cat <<EOF
#cloud-config
autoinstall:
  version: 1
  identity:
    hostname: $vm_name
    password: "$hashed_password" #ubuntu
    username: $vm_user
  locale: en_US
  storage:
    layout:
      name: direct
  # seems these are needed for 24.04
  ssh:
    install-server: true
  packages:
    - ssh-import-id
    - ubuntu-desktop
    - git
    - curl
  late-commands:
    - curtin in-target -- curl -L -o /tmp/appgate.deb https://bin.appgate-sdp.com/latest/ubuntu/Appgate-SDP-client.deb
    - curtin in-target -- apt install -y /tmp/appgate.deb
  user-data:
    package_upgrade: true
    apt:
      http_proxy: ''
    users:
    - name: $vm_user
      ssh_import_id:
        - $vm_importid
      sudo: ALL=(ALL) NOPASSWD:ALL
      groups: sudo,admin,adm
      shell: /bin/bash
      lock_passwd: false
EOF
)

echo  "$autoinstall_yaml" > "$workTempDir"/user-data
touch "$workTempDir"/meta-data

virt-install \
    --name "$vm_name" \
    --memory "$vm_mem" \
    --vcpus="${vm_cpus}" \
    --disk size="${vm_disk}",pool="${vm_storagepool}" \
    --os-variant ubuntu-lts-latest \
    --cloud-init="meta-data=$workTempDir/meta-data,user-data=$workTempDir/user-data" \
    --autoconsole graphical \
    --location="${imagefile},kernel=casper/hwe-vmlinuz,initrd=casper/hwe-initrd" \
    --extra-args="ip=dhcp console=ttyS0 serial autoinstall"

rm -rf "$workTempDir"
