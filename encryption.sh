# parameters
tenant=${1-tenant.onmicrosoft.com}
service_principal=${2:-principal}
certificate=${3:-./cert.pem}
vault=${4:-keyvault}
device=${5:-/dev/sdb}

# remove existing unencrypted volume 
if [[ $(mount) == *${device}1* ]]
then
  echo "=> found unencrypted volume, removing it..."
  umount ${device}1
  rm -f ${device}1
  echo "=> unencrypted volume removed."
fi

# login to Azure
echo "=> logging into Azure to obtain passphrase..."
az login --service-principal -u http://$service_principal -p $certificate --tenant $tenant --query "[*].user.name" -o tsv

# get the passphrase from keyvault
passphrase=$(az keyvault secret show --vault-name $vault --name EphCrypt --query value -o tsv)
echo "=> passphrase obtained."

# see if the encrypted disk is mounted
if [[ $(mount) == */media/encrypted* ]]
then
  echo "=> encrypted volume is already mounted."
else

  # see if the encrypted volume exists
  cryptsetup isLuks $device
  if [ $? == 0 ]
  then

    # mount the encrypted disk    
    echo "=> encrypted volume is being mounted..."
    echo -n $passphrase | cryptsetup -q luksOpen $device cryptdisk
    sudo mount -t ext4 /dev/mapper/cryptdisk /media/encrypted
    echo "=> encrypted volume is mounted."

  else

    # encrypt the volume
    echo "=> encrypting the volume..."
    echo -n $passphrase | cryptsetup -q luksFormat $device

    # open the disk
    echo "=> opening the disk..."
    echo -n $passphrase | cryptsetup -q luksOpen $device cryptdisk

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
