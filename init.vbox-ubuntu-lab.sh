#!/bin/bash

# Update the system
sudo apt-get update -y
sudo apt-get upgrade -y

# Function to check if VirtualBox is installed
is_virtualbox_installed() {
  command -v vboxmanage >/dev/null 2>&1
}

# Install VirtualBox if not installed
if ! is_virtualbox_installed; then
  echo "VirtualBox not found, installing..."

  # Install VirtualBox
  sudo apt-get install -y virtualbox
fi

# Set VM configuration parameters
VM_NAME="my-vm"
RAM="2048"
VCPU="2"
DISK_SIZE="10240" # In MB
ISO_PATH="/path/to/ubuntu-20.04.3-live-server-amd64.iso"

# Create and configure the VM
VBoxManage createvm --name "${VM_NAME}" --ostype "Ubuntu_64" --register
VBoxManage modifyvm "${VM_NAME}" --memory "${RAM}" --cpus "${VCPU}" --acpi on --boot1 dvd --nic1 nat
VBoxManage createhd --filename "${VM_NAME}.vdi" --size "${DISK_SIZE}"
VBoxManage storagectl "${VM_NAME}" --name "IDE Controller" --add ide
VBoxManage storageattach "${VM_NAME}" --storagectl "IDE Controller" --port 0 --device 0 --type hdd --medium "${VM_NAME}.vdi"
VBoxManage storageattach "${VM_NAME}" --storagectl "IDE Controller" --port 1 --device 0 --type dvddrive --medium "${ISO_PATH}"

# Start the VM
VBoxManage startvm "${VM_NAME}"
  b