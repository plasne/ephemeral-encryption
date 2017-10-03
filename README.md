# ephemeral-encryption


install python 2.7:
  https://danieleriksson.net/2017/02/08/how-to-install-latest-python-on-centos/
  many commands had to be run sudo
  sudo /usr/local/bin/pip2.7 install azure-cli

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


