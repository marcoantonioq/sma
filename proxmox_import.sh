#!/bin/bash

directory="/mnt/vmware/"
vmware_user="andre"
vmware_ip="10.80.67.2"
vmware_store="/vmfs/volumes/datastore1/"
VM_ID=""
arquivo=""

mkdir -p $directory
echo -en "Senha do vmware: "
sshfs -o ro -oHostKeyAlgorithms=+ssh-rsa $vmware_user@$vmware_ip:$vmware_store $directory

# Obter lista de arquivos .vmdk
options=$(find $directory -name "*.vmdk" | grep -vE -- "-(flat|sesparse|ctk)")

# Verificar se a lista está vazia
if [[ ${#options[@]} -eq 0 ]]; then
  echo "Nenhum arquivo .vmdk encontrado."
  exit 1
fi

echo
read -p "Digite o ID da VM: " VM_ID

echo "Selecione um arquivo .vmdk:"
number=1
while IFS= read -r file; do
    echo "($number) $file"
    number=$((number + 1))
done <<< "$options"
echo
read -p "Digite o número do disco: " escolha

# Validar a escolha do usuário
if [[ ! $escolha =~ ^[1-9][0-9]*$ ]]; then
  echo "Opção inválida. Escolha um número entre 1 e ${number-1}."
  exit 1
fi

# Selecionar o arquivo
arquivo=$(echo "$options" | sed -n "${escolha}p")

# Exibir a opção escolhida
echo "Você escolheu: $VM_ID ---- $arquivo "

qm importdisk $VM_ID "$arquivo" local-lvm --format qcow2