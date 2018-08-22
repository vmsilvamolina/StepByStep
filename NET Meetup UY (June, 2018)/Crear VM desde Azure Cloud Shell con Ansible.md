# DEMO - Crear una VM usando Ansible desde la Azure Cloud Shell

Paso a paso para crear una VM con CentOS desde la Azure Cloud Shell utilizando Ansible para aprovisionar.
Para la demo se utilizaron los siguientes valores:

| **Descrcipción** | **Valor utilizado en esta guía** |
| --- | --- |
| Resource group | IaC |
| Región en Azure | eastus |
| Nombre de la VM | CentOS |
| Nombre del usuario | vmsilvamolina |

**1-** Crear un *Resource Group*:

Desde la consola Azure Cloud Shell ejecutar el siguiente comando:

    az group create --name IaC --location eastus


**2-** Ver lista de Resource Groups existentes:

A modo de comprobar que se ejecutó correctamente el comando anterior, es posible determinar si el recurso fue creado o no, ejecutando:

    az group list --o table

**3-** Crear los recursos de networking:

Luego de contar con el Resource Group, lo siguiente es crear la red a la que se va a conectar la VM:

    az network vnet create --resource-group IaC --name vNET --address-prefix 10.0.0.0/16 --subnet-name Subnet --subnet-prefix 10.0.1.0/24

**4-** Ver los recursos del Resource Group:

Revisar si los recursos de redes han sido creados satisfactoriamente:

az resource list --resource-group IaC --o table

**5-** Obtener la clave pública:

Para conectarnos de forma más segura, en lugar de definir una contraseña, vamos a utilizar una clave pública (para ello previamente se debe de haber generado una clave para SSH):

    cat ~/.ssh/id_rsa.pub

**6-** Crear el Playbook:

Luego de contar con los requisitos para el despliegue es necesario crear el archivo .yml donde se definirán los recursos a implementar:

    vi azure_create_vm.yml

Insertar la siguiente información:

    - name: Create Azure VM
    hosts: localhost
    connection: local
    tasks:
    - name: Create VM
        azure_rm_virtualmachine:
        resource_group: IaC
        name: CentOS
        vm_size: Standard_DS1_v2
        admin_username: vmsilvamolina
        ssh_password_enabled: false
        ssh_public_keys: 
            - path: /home/vmsilvamolina/.ssh/authorized_keys
            key_data: "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDAGLqLBJtraRrQUUceXgCz6rMBMUhEZ0Zvdv0WRrTWWotDWV/4DSmuiGES0e3KS/quMZ6AnaWc91iRqsuXpKXB+RkWEbhUHMg9nsjPvSR1bC5n8/KErRhgWevlCHhurA3inUotSZA0b92zPIk+URvpKbuZfrFXf5yEbctBmXY2hudSDDJX2RvDsPyOyr4/dLkBrzUDdEydYC183DkdiSs49v3bmUDy0WPeIFL2ziCyIoHci/GG1+gkTssdHeVazPWwLweW/6T02EGmAI2dqe6DceQ7+AC5N+Es/rLMxl17ban6gewMz6umSktoMqhT0MCmBFY9TnWbDqJWIW908q1N victor@cc-29b641c2-3985331103-q4711"
        image:
            offer: CentOS
            publisher: OpenLogicls -l
            sku: '7.5'
            version: latest

**7-** Ejecutar el Playbook:

Resta únicamente ejecutar el Playbook para aprovisionar nuestra VM en Azure desde la consola Azure Cloud Shell:

    ansible-playbook azure_create_vm.yml

**8-** Obtener IP pública de la VM:

En caso de querer identificar la IP pública de la VM recién implementada, se debe ejecutar:

    azure vm show IaC CentOS | grep "Public IP address" | awk -F ":" '{print $3}'