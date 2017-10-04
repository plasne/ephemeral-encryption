# remove existing unencrypted volume 
if [[ $(mount) == */dev/sdb1* ]]
then
  echo "=> found unencrypted volume, removing it..."
  umount /dev/sdb1
  rm -f /dev/sdb1
  echo "=> unencrypted volume removed."
fi

# login to Azure
echo "=> logging into Azure to obtain passphrase..."
az login --service-principal -u http://pelasne-vault -p /home/plasne/tmpECU54D.pem --tenant microsoft.onmicrosoft.com --query name -o tsv

# get the passphrase from keyvault
passphrase=$(az keyvault secret show --vault-name pelasne-keys --name EphCrypt --query value -o tsv)
echo "=> passphrase obtained."

# see if the encrypted disk is mounted
if [[ $(mount) == */media/encrypted* ]]
then
  echo "=> encrypted volume is already mounted."
else

  # see if the encrypted volume exists
  cryptsetup isLuks /dev/sdb
  if [ $? == 0 ]
  then

    # mount the encrypted disk    
    echo "=> encrypted volume is being mounted..."
    echo -n $passphrase | cryptsetup -q luksOpen /dev/sdb cryptdisk
    sudo mount -t ext4 /dev/mapper/cryptdisk /media/encrypted
    echo "=> encrypted volume is mounted."

  else

    # encrypt the volume
    echo "=> encrypting the volume..."
    echo -n $passphrase | cryptsetup -q luksFormat /dev/sdb

    # open the disk
    echo "=> opening the disk..."
    echo -n $passphrase | cryptsetup -q luksOpen /dev/sdb cryptdisk

    # make the filesystem
    echo "=> creating the filesystem..."
    mkfs.ext4 /dev/mapper/cryptdisk

    # make the directory
    echo "=> making the mountpoint..."
    mkdir /media/encrypted

    # mount the volume in the directory
    echo "=> mounting the volume..."
    sudo mount -t ext4 /dev/mapper/cryptdisk /media/encrypted
    echo "=> encrypted volume mounted as /media/encrypted."
    echo "=> NOTE: you must add permissions for users beyond root."

  fi

fi
