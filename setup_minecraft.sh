#/bin/bash

RESOURCEGROUP="minecraft"
LOCATION="westeurope"
VMNAME="minecraft"


az group create --name $RESOURCEGROUP --location $LOCATION
az vm create -n $VMNAME -g $RESOURCEGROUP --image UbuntuLTS --location $LOCATION --assign-identity --size Standard_B2s --generate-ssh-keys --admin-username cccadmin
IP=$(az network public-ip show -g $RESOURCEGROUP -n ${VMNAME}PublicIP --query "ipAddress" -o tsv)


cat << EOF | cat > inventory 
[minecraft]
$IP ansible_ssh_common_args='-o StrictHostKeyChecking=no'

EOF

ansible-playbook test.yml -i inventory

az network nsg rule create -g $RESOURCEGROUP --nsg-name ${VMNAME}NSG -n AllowPing \
    --priority 2000 --source-address-prefixes '*' --destination-address-prefixes '*' \
    --destination-port-ranges '0' --direction InBound --access Allow --protocol '*' --description "AllowPing"

az network nsg rule create -g $RESOURCEGROUP --nsg-name ${VMNAME}NSG -n Server1 \
    --priority 2001 --source-address-prefixes '*' --destination-address-prefixes '*' \
    --destination-port-ranges '25565' --direction InBound --access Allow --protocol TCP --description "Allow Server1"

az network nsg rule create -g $RESOURCEGROUP --nsg-name ${VMNAME}NSG -n Server2 \
    --priority 2002 --source-address-prefixes '*' --destination-address-prefixes '*' \
    --destination-port-ranges '25566' --direction InBound --access Allow --protocol TCP --description "Allow Server2"

az network nsg rule create -g $RESOURCEGROUP --nsg-name ${VMNAME}NSG -n Server3 \
    --priority 2003 --source-address-prefixes '*' --destination-address-prefixes '*' \
    --destination-port-ranges '25567' --direction InBound --access Allow --protocol TCP --description "Allow Server3"

