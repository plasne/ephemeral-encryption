# Ephemeral Encryption

When running workloads that need high disk performance, such as Cassandra, it may be beneficial to store that data on ephemeral disk. To prevent data loss, you would need a method to replicate changes to a more permanant storage system and/or have enough nodes distributed across enough regions such that the likelihood of loosing all nodes at the same time is acceptibly slow.

The other challenge with using ephemeral disk is that some customers require encryption of the data at rest.

The script contained in this repository was developed for a customer to ensure the ephemeral drive is encrypted. The customer was using CentOS 6.9 and Azure Key Vault.

## Python 2.7

Unfortunately, CentOS 6.9 does not contain Python 2.7 which is a requirement for the Azure CLI 2.0 which was needed to get the passphrase from Azure Key Vault. Moreover, Python cannot simply be upgraded on CentOS because yum requires the original version.

The [install-az.sh](install-az.sh) script installs a parallel copy of Python 2.7 at /usr/local/bin/python2.7. This script is based on: https://danieleriksson.net/2017/02/08/how-to-install-latest-python-on-centos/.

To run the script:

```bash
sudo ./install-az.sh
```

## Installing Azure CLI 2.0

If you are using a system that already has Python 2.7, you can simply install az per the instructions here: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest.

## Storing the passphrase in Azure Key Vault

Follow these steps to store the passphrase in Azure Key Vault.

1. Create an Azure Key Vault.

```bash
az group create --name pelasne-vault --location eastus2
az keyvault create --resource-group pelasne-vault --name pelasne-vault
```

2. Create a secret in the Key Vault that will be used for the passphrase.

```bash
az keyvault secret set --vault-name pelasne-vault --name cryptkey --value password
```

3. Create a security principal that the script can use to access the key vault.

```bash
az ad sp create-for-rbac --name "pelasne-app" --create-cert --skip-assignment
```

This will create a pem file that will be used for the authentication. You can move this file wherever you like, but you will reference it when you run the encryption script. Also, if you are going to use this across multiple VMs, you will need to copy that pem file to the other VMs.

Also note the appId will be the spn for the next step. The name will be used when you invoke the script (minus the http:// prefix).

4. Set the policy to allow the service principal access to get the key.

```bash
az keyvault set-policy --resource-group pelasne-vault --name pelasne-vault --spn <appId> --secret-permissions get
```

## Running the encryption script

The [encryption.sh](encryption.sh) script performs the following steps:

1. If the ephemeral volume is mounted, it is unmounted and deleted
2. If the encrypted volume exists, it is mounted
3. If the encrypted volume does not exist, it will be created and mounted

The parameters for the script are:

1. tenant - You AD tenant that contains the service principal you created above.
2. principal - The name of the security principal you created above.
3. certificate - The path to the pem file used to authenticate your service principal.
4. vault - The name of the Azure Key vault.
5. key - The name of the key in the vault containing the secret.
6. device - Optional, defaults: /dev/sdb; the path for the ephemeral device.

To run the script (substitute your parameters):

```bash
sudo ./encryption.sh microsoft.onmicrosoft.com pelasne-app /home/plasne/tmpECU54D.pem pelasne-vault cryptkey
```
