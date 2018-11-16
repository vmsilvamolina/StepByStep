# DEMO - Crear una VM usando Ansible desde la Azure Cloud Shell

Paso a paso para crear una VM con CentOS desde la Azure Cloud Shell utilizando Ansible para aprovisionar.
Para la demo se utilizaron los siguientes valores:

| **Descrcipción** | **Valor utilizado en esta guía** |
| --- | --- |
| Resource group | netconfuy |
| Región en Azure | eastus |
| Nombre de la VM | LinuxVM |
| Nombre del usuario | vmsilvamolina |


**1-** Ver lista de Resource Groups existentes:

A modo de comprobar que se ejecutó correctamente el comando anterior, es posible determinar si el recurso fue creado o no, ejecutando:

    az group list --o table

**2-** Crear los recursos de networking:

Luego de contar con el Resource Group, lo siguiente es crear la red a la que se va a conectar la VM:

    az network vnet create --resource-group netconfuy --name vNET --address-prefix 10.0.0.0/16 --subnet-name Subnet --subnet-prefix 10.0.1.0/24

**3-** Ver los recursos del Resource Group:

Revisar si los recursos de redes han sido creados satisfactoriamente:

    az resource list --resource-group netconfuy --o table

**4-** Obtener la clave pública:

Para conectarnos de forma más segura, en lugar de definir una contraseña, vamos a utilizar una clave pública (para ello previamente se debe de haber generado una clave para SSH utilizando *ssh-keygen -t rsa -b 2048*):

    cat ~/.ssh/id_rsa.pub

**5-** Crear el Playbook:

Luego de contar con los requisitos para el despliegue es necesario crear el archivo .yml donde se definirán los recursos a implementar:

    code

Insertar la siguiente información:

    - name: Create Azure VM
    hosts: localhost
    connection: local
    tasks:
    - name: Create VM
        azure_rm_virtualmachine:
        resource_group: netconfuy
        name: LinuxVM
        vm_size: Standard_DS1_v2
        admin_username: vmsilvamolina
        ssh_password_enabled: false
        ssh_public_keys:
            - path: /home/vmsilvamolina/.ssh/authorized_keys
            key_data: "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDAIvl2EiHvFL8ftjdTQxAjt4/qPkCeAbNfKOV+WG8MGPqAP3s5goG6YC+t4KuKwnB59Gbic+3bLWfo/t7tbCL9CmgVqh2UNWVctZuEi02NxvUPLaTjW0lAblzlGGn9CUXbGGsNNWhJuZpuH+Npw6r1BOC/VGVKJ858IYzll/BM+gZkQAnqJJASRGuFbUyy8OC+ZLiRCJTh5JeoU0iYIwFu0PVfEqvRToIgTtmGNYr9TqbNMgte985tBtQF8/ZmsyYcSfIqBcKoFDd3GdexztygxgQAM+TpgOu9BUsvX6NAfvXpHalaBtnzJT4cG6FYpTxWSzTwIRTgv5Pf4KeHfEaL vmsilvamolina@cc-96005c8c-55d4776955-cvmz4"
        image:
            offer: CentOS
            publisher: OpenLogic
            sku: '7.5'
            version: latest

Y guardar el archivo con el nombre de *azure-Create.yml*


**6-** Ejecutar el Playbook:

Resta únicamente ejecutar el Playbook para aprovisionar nuestra VM en Azure desde la consola Azure Cloud Shell:

    ansible-playbook azure_create.yml

**7-** Obtener IP pública de la VM:

En caso de querer identificar la IP pública de la VM recién implementada, se debe ejecutar:

    azure vm show netconfuy LinuxVM | grep "Public IP address" | awk -F ":" '{print $3}'

**8-** Conectarse por SSH:

Para conectarse por SSH, es necesario ejecutar:

    ssh <user>@<ip>