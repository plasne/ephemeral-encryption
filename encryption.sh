# login to Azure
az login --service-principal -u http://pelasne-vault -p /home/plasne/tmpECU54D.pem --tenant microsoft.onmicrosoft.com

# get the passphrase from keyvault
passphrase=$(az keyvault secret show --vault-name pelasne-keys --name EphCrypt --query value -o tsv)

# encrypt the volume
echo -n $passphrase | cryptsetup -q luksFormat /dev/sdb

# open the disk
echo -n $passphrase | cryptsetup -q luksOpen /dev/sdb cryptdisk

# make the filesystem
mkfs.ext4 /dev/mapper/cryptdisk

# make the directory
mkdir /media/encrypted

# mount the directory
sudo mount -t ext4 /dev/mapper/cryptdisk /media/encrypted
