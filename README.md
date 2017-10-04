# Ephemeral Encryption

When running workloads that need high disk performance, such as Cassandra, it may be beneficial to store that data on ephemeral disk. To prevent data loss, you would need a method to replicate changes to a more permanant storage system and/or have enough nodes distributed across enough regions such that the likelihood of loosing all nodes at the same time is acceptibly slow.

The other challenge with using ephemeral disk is that some customers require encryption of the data at rest.

The script contained in this repository was developed for a customer to ensure the ephemeral drive is encrypted. The customer was using CentOS 6.9 and Azure Key Vault.

## Python 2.7

Unfortunately, CentOS 6.9 does not contain Python 2.7 which is a requirement for the Azure CLI 2.0 which was needed to get the passphrase from Azure Key Vault. Moreover, Python cannot simply be upgraded on CentOS because yum requires the original version.

The [install-az.sh](install-az.sh) script installs a parallel copy of Python 2.7 at /usr/local/bin/python2.7. This script is based on: https://danieleriksson.net/2017/02/08/how-to-install-latest-python-on-centos/.

**NOTE: You may need to make the script executable (ex. chmod +x ./install-az.sh) **
**NOTE: You need to run this script as sudo (ex. sudo ./install-az.sh). **

## Running the encryption script

The [encryption.sh](encryption.sh) script performs the following steps:

1. If the ephemeral volume is mounted, it is unmounted and deleted
2. If the encrypted volume exists, it is mounted
3. If the encrypted volume does not exist 

install Azure CLI 2.0
  https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest

az ad sp create-for-rbac -n "pelasne-vault" --create-cert
{
  "appId": "e6910c60-eb9d-4800-b245-c3cbb48ecba1",
  "displayName": "pelasne-vault",
  "fileWithCertAndPrivateKey": "/home/plasne/tmpECU54D.pem",
  "name": "http://pelasne-vault",
  "password": null,
  "tenant": "72f988bf-86f1-41af-91ab-2d7cd011db47"
}

az keyvault secret set --vault-name pelasne-keys --name EphCrypt --value password

az keyvault set-policy --resource-group pelasne-centos --name pelasne-keys --spn e6910c60-eb9d-4800-b245-c3cbb48ecba1 --secret-permissions get

az keyvault secret show --vault-name pelasne-keys --name EphCrypt --query value -o tsv

sudo umount /dev/sdb1






sudo mount -t ext4 /dev/mapper/crypted /encryptedfs

echo -n "passphrase" | sudo cryptsetup -q luksFormat /dev/sdb


