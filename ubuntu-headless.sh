#!/usr/bin/env bash
set -e
export NAME="ubuntu2404"
export ISO_URL="https://sjc.mirror.rackspace.com/ubuntu-releases/24.04/ubuntu-24.04.2-live-server-amd64.iso"
export ISO_HASH="d6dab0c3a657988501b4bd76f1297c053df710e06e0c3aece60dead24f270b4d"
export BASE_DIR="$HOME/vms"

mkdir -p ${BASE_DIR}/iso
mkdir -p ${BASE_DIR}/ks
mkdir -p ${BASE_DIR}/images
mkdir -p ${BASE_DIR}/init

virsh destroy ${NAME} || true
virsh undefine ${NAME} --nvram || true
rm -f ${BASE_DIR}/${NAME}.qcow2

if [ ! -f "${BASE_DIR}/iso/$(basename ${ISO_URL})" ]; then
  wget -P ${BASE_DIR}/iso ${ISO_URL}
else
  echo "ISO already exists"
fi

echo "${ISO_HASH} ${BASE_DIR}/iso/$(basename ${ISO_URL})" | sha256sum --check
if [ $? -ne 0 ]; then
  echo "Checksum for ISO failed"
  exit 1
fi

mkdir -p ${BASE_DIR}/init/${NAME}

tee ${BASE_DIR}/init/${NAME}/user-data << EOF
#cloud-config
autoinstall:
  version: 1
  timezone: "Etc/UTC"
  identity:
    realname: "Cloud"
    username: cloud
    password: "\$6\$x7YEknTyUuNSTTVK\$nq4xoSTrYp7a/Kb1EvtpH97GxG02CFBqELznybQv4XrA7sskq9PI0Y5KADhp9KiwVdrwR6v2IP6wqoxyXj4SP/"
    hostname: cloud
  storage:
    layout:
      name: direct
    config:
      - type: disk
        id: disk0
        match:
          size: largest
      - type: partition
        id: efi-partition
        device: disk0
        size: 100M
        flag: boot
        grub_device: true
      - type: partition
        id: root-partition
        device: disk0
        size: -1
      - type: format
        id: efi-format
        volume: efi-partition
        fstype: fat32
      - type: format
        id: root-format
        volume: root-partition
        fstype: xfs
      - type: mount
        id: efi-mount
        device: efi-format
        path: /boot/efi
      - type: mount
        id: root-mount
        device: root-format
        path: /
EOF

echo "creating metadata"
tee ${BASE_DIR}/init/${NAME}/meta-data << EOF
instance-id: ${NAME}
local-hostname: cloud
EOF

echo "creating seed"
cloud-localds "${BASE_DIR}/init/${NAME}.iso" "${BASE_DIR}/init/${NAME}/user-data" "${BASE_DIR}/init/${NAME}/meta-data"

echo "doing virt-install"
virt-install \
  --name ${NAME} \
  --vcpus 8 \
  --memory 8192 \
  --boot uefi \
  --disk path=${BASE_DIR}/${NAME}.qcow2,size=8,format=qcow2,bus=virtio \
  --disk path=${BASE_DIR}/init/${NAME}.iso,device=cdrom \
  --os-variant ubuntu-lts-latest \
  --network user \
  --graphics=none \
  --console pty,target_type=serial \
  --location=${BASE_DIR}/iso/$(basename ${ISO_URL}),kernel=casper/hwe-vmlinuz,initrd=casper/hwe-initrd \
  --extra-args="console=ttyS0 serial autoinstall"

while ! virsh domstate ${NAME} 2>/dev/null | grep -q "shut off"; do
  sleep 1
done

echo "Compressing image..."
rm -f ${BASE_DIR}/images/${NAME}_$(date +%y%m).qcow2
qemu-img convert -f qcow2 -O qcow2 -c ${BASE_DIR}/${NAME}.qcow2 ${BASE_DIR}/images/${NAME}_$(date +%y%m).qcow2
sha256sum ${BASE_DIR}/images/${NAME}_$(date +%y%m).qcow2
