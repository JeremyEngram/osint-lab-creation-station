#!/bin/bash

# Update the system
sudo apt-get update -y
sudo apt-get upgrade -y

# Install KVM, virt-manager, and qemu-kvm
sudo apt-get install -y qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils virt-manager

# Start and enable libvirtd service
sudo systemctl start libvirtd
sudo systemctl enable libvirtd

# Set VM configuration parameters
VM_NAME="my-vm"
OS_VARIANT="ubuntu20.04"
RAM="2048"
VCPU="2"
DISK_SIZE="10G"
DISK_PATH="/var/lib/libvirt/images/${VM_NAME}.qcow2"
ISO_PATH="/path/to/ubuntu-20.04.3-live-server-amd64.iso"

# Create a disk image for the VM
sudo qemu-img create -f qcow2 "$DISK_PATH" "$DISK_SIZE"

# Deploy the VM
sudo virt-install \
  --name "$VM_NAME" \
  --os-variant "$OS_VARIANT" \
  --ram "$RAM" \
  --vcpus "$VCPU" \
  --disk path="$DISK_PATH",format=qcow2 \
  --network network=default \
  --graphics none \
  --console pty,target_type=serial \
  --location "$ISO_PATH" \
  --extra-args 'console=ttyS0,115200n8 serial'
