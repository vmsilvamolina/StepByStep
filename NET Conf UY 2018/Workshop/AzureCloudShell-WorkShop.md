# Azure Cloud Shell: de 0 a Ninja!

Workshop pensado para introducirnos a esta herramienta disponible desde el navegador...

**Victor Silva**

[Blog](https://blog.victorsilva.com.uy) | [@vmsilvamolina](https://twitter.com/vmsilvamolina) | [Linked-In](https://www.linkedin.com/in/vmsilvamolina/) | [Email](mailto:vmsilvamolina@hotmail.com) | [GitHub](https://www.github.com/vmsilvamolina)


## Contenido

  - [Conocimiento previo](#conocimiento-previo)
  - [Nuevos skills](#nuevos-skills)
  - [Requisitos](#requisitos)
  - [Parte 1 - Accediendo a la Azure Cloud Shell](#parte-1---accediendo-a-la-azure-cloud-shell)
  - [Parte 2 - Crear una Virtual Machine](#parte-2---crear-una-virtual-machine)
  - [Introducción a Ansible](#introducci%C3%B3n-a-ansible)
  - [Parte 3 - Crear una VM con Ansible](#parte-3---crear-una-vm-con-ansible)
  - [Parte 4 - Crear un Azure Container Service](#parte-4---crear-un-azure-container-service)
  - [Parte 5- Administrar un Cluster con Cloud Shell](#parte-5---Administrar-un-cluster-con-cloud-shell)
  - [Step 8 - Cleanup After the Workshop](#step-8---cleanup-after-the-workshop)



## Conocimiento previo

- Conocimiento básico de Virtualización (Hyper-V, VMware, Computo en la nube)
- Uso básico de editores de texto (Notepad++, Vim, VS Code)
- Haber ejecutado algún script en Bash, Cmd o PowerShell

## Nuevos skills

- Crear y usar la Azure Cloud Shell.
- Usar la CLI de Azure (`az`) para crear y eliminar recursos y servicios.
- Use the Kubernetes tools (`kubectl`) to deploy and manage highly available
  container applications.

## Requisitos

Para completar el workshop, es necesario contar con lo siguiente:

- Una **Cuenta de Microsoft Azure**.
  Se puede registrar una cuenta (trial) gratis [acá](https://azure.microsoft.com/en-us/free/).
- Una computadora con **Windows**, **OSX** o **Linux** con la **última versión** de Chrome, Firefox, Edge u Opera.

## Parte 1 - Accediendo a la Azure Cloud Shell

Azure Cloud Shell es una línea de comandos interactiva, accesible desde el navegador que permite administrar los recursos de Azure.
Otorga flexibilidad al momento de elegir la experiencia entre bash, para los usuario de Linux, mientras que para los usuario de Windows se encuentra disponible PowerShell.


1. Abrir la Azure Cloud Shell haciendo click sobre el ícono:
   ![Abrir la Azure Cloud Shell](images/opencloudshell.png "Abrir la Azure Cloud Shell")

> Si **no** se había utilizado previamente la Azure Cloud Shell:

![Welcome to Cloud Shell](images/welcometocloudshell.png "Welcome to Cloud Shell")

1. Click **Bash (Linux)**

   _Al momento de crear por primera vez la Cloud Shell una cuenta de storage se generará para alojar las configuraciones, scripts y otros archivos. Esto habilita tener acceso a nuestro propio ambiente sin importar el dispositivo que se utilice._

   ![Crear la Cloud Shell Storage](images/createcloudshellstorage.png "Crear la Cloud Shell Storage")

2. Seleccionar la **subscription** para crear la Storage Account y click **Create storage**.
3. La Storage Account va a ser creada y se ejecutará la Cloud Shell:

   ![Cloud Shell Started](images/cloudshellstarted.png "Cloud Shell Started")

> Si se había utilizado previamente la Azure Cloud Shell:

4. Seleccionar **Bash** desde la lista desplegable:

   ![Seleccionar Bash](images/selectbashcloudshell.png "Select Bash")

## Parte 2 - Crear una Virtual Machine


Ahora vamos a utilizar Azure CLI para generar una máquina virtual.

Azure CLI es la línea de comandos de Azure.

1. Crear el grupo de recursos que alojará la VM, ejecutando la siguiente línea:

        az group create --name CloudShellWS --location eastus

2. Lo siguiente es crear la vNet:

        az network vnet create --resource-group CloudShellWS --name vNET --subnet-name subnet

3. El siguiente paso es crear una Public IP:

        az network public-ip create --resource-group CloudShellWS --name PublicIP

4. Continuando el proceso el siguiente paso es crear el Network Security Group.

        az network nsg create --resource-group CloudShellWS --name NetworkSecurityGroup

5. Resta crear la virtual network card y luego, asociarla a la Public IP y el NSG.

        az network nic create --resource-group CloudShellWS --name NIC --vnet-name vNET --subnet subnet --network-security-group NetworkSecurityGroup --public-ip-address PublicIP

6. Ahora sí, con todos los recursos generados, vamos a crear la virtual machine.

Pero antes, vamos a generar una variable (la password):

    AdminPassword=ChangeYourAdminPassword1

Finalmente ejecutamos el comando para crear la VM:
    
    az vm create --resource-group CloudShellWS --name VM --location eastus --nics NIC --image win2016datacenter --admin-username azureuser --admin-password $AdminPassword

1. Para validad que todo está OK, vamos a conectarnos a la VM.

Lo primero que debemos hacer es abrir el puerto 3389:

    az vm open-port --port 3389 --resource-group CloudShellWS --name VM

Para obtener la IP pública es necesario ejecutar:

    azure vm show CloudShellWS VM | grep "Public IP address" | awk -F ":" '{print $3}'

Y luego utilizamos el cliente RDP para conectarnos con el usuario y clave.

## Introducción a Ansible

Vamos a charlar un poco de que trata Ansible y como podemos utilizarla desde la Azure Cloud Shell.

## Parte 3 - Crear una VM con Ansible

1. Ver lista de Resource Groups existentes:

A modo de comprobar que se ejecutó correctamente el comando anterior, es posible determinar si el recurso fue creado o no, ejecutando:

    az group list --o table

2. Crear los recursos de networking:

Luego de contar con el Resource Group, lo siguiente es crear la red a la que se va a conectar la VM:

    az network vnet create --resource-group CloudShellWS --name vNET --address-prefix 10.0.0.0/16 --subnet-name subnet --subnet-prefix 10.0.1.0/24

3. Ver los recursos del Resource Group:

Revisar si los recursos de networking han sido creados satisfactoriamente dentro del grupo de recursos:

    az resource list --resource-group CloudShellWS --o table

4. Obtener la clave pública:

Para conectarnos de forma más segura, en lugar de definir una contraseña, vamos a utilizar una clave pública (para ello previamente se debe de haber generado una clave para SSH utilizando *ssh-keygen -t rsa -b 2048*):

    cat ~/.ssh/id_rsa.pub

5. Obtener el playbook:

Se encuentra disponible el archivo con el playbook listo. Para acceder a él basta ejecutar lo siguiente:

    wget https://raw.githubusercontent.com/vmsilvamolina/TalksAndMore/master/NET%20Conf%20UY%202018/Workshop/azure_create_vm.yml

6. Ahora que tenemos a disposición el archivo, vamos a editarlo usando **code**:

    code ./azure_create_vm.yml

Para guardar utilizamos Ctrl + S.
Para cerrar Ctrl + Q.

7. Ejecutamos el playbook de la siguiente manera:

    ansible-playbook ./azure_create.vm.yml


## Parte 4 - Crear un Azure Container Service

El objetivo es generar un cluster de ACS para hostear nuestros contenedores.

Cualquier servicio de ACS que sea creado tendrá de acceso público en Internet.
Se asignará automáticamente una URL a su servicio de ACS donde podremos acceder a los contenedores y administrar su clúster.


1. Acceder a la **Cloud Shell** desde el portal de Azure o de forma individual desde la URL:

   [![Acceder a Cloud Shell](https://shell.azure.com/images/launchcloudshell.png "Acceder a Cloud Shell")](https://shell.azure.com)

2. Dependiendo del tipo de suscripción (Free, Azure Pass, MSDN, etc.) se deberá registrar los providers requeridos. Esto se debe a que por defecto, algunos resource providers no están registrados.

Esto se debe hacer una única vez por suscripción. Ejecutando lo siguiente:

   ```bash
   az provider register --namespace Microsoft.Network
   az provider register --namespace Microsoft.Compute
   az provider register --namespace Microsoft.Storage
   az provider register --namespace Microsoft.ContainerService --wait
   ```

   ![Registrar Providers](images/registerproviders.png "Registrar Providers")

1. Definir un  **nombre** para el servicio ACS. El nombre debe contener únicamente letras y números y debe ser único a nivel global, ya que va a ser utilizado públicamente por las URLs.

2. Ejecutar el siguiente comando en la Cloud Shell, cambiando el valor `<set me please>` por el **nombre** definido anteriormente.

   ```bash
   name="<set me please>"
   ```

   **Importante: Tomar nota de este valor, ya que si la consola se cierra, es necesario volver a ejecutar el proceso.**

3. Ejecutar el siguiente comando para crear el grupo de recursos:

   ```bash
   az group create --name $name-rgp --location EastUS
   ```

4. Ahora, con el siguiente comando, vamos a crear el cluster:

   ```bash
   az acs create --name $name --resource-group $name-rgp --location EastUS --dns-prefix $name --orchestrator-type kubernetes --generate-ssh-keys --agent-count 2
   ```

El clúster de ACS Kubernetes se va a desplegar en menos de 10 minutos.

![Crear el cluster ACS](images/acscreate.png "Crear el cluster ACS")

## Parte 5 - Administrar un Cluster con Cloud Shell

Una vez que el cluster está desplegado, podremos acceder a ver los recursos generados:

![ACS Resources](images/acsresources.png "ACS Resources")

Ahora que nuestro clúster está implementado, necesitamos configurar Cloud Shell para poder gestionarlo.

Los clusters de Kubernetes siempre exponen un punto de gestión que las herramientas de Kubernetes y aplicaciones externas pueden usar para controlar y monitorear el cluster. El FQDN para este punto final se puede localizar seleccionando el recurso de clúster de ACS en el grupo de recursos que implementamos para contener nuestro clúster:

![ACS Management FQDN](images/acsresourcemanagementfqdn.png "ACS Management FQDN")

Podemos utilizar la herramienta `kubectl` para administrar los recursos. Estas tareas podríamos hacerlas manualmente, pero tenemos `Azure CLI` para facilitar la tarea...

1. Configure your Cloud Shell to manage your ACS by running the command:

   ```bash
   az acs kubernetes get-credentials --resource-group $name-rgp --name $name
   ```

   ![Configurar Cloud Shell para administrar ACS](images/configurecloudshellacs.png "Configurar Cloud Shell para administrar ACS")

2. Validar que el cluster esté corriendo:

   ```bash
   kubectl cluster-info
   ```

   ![Get Cluster Info](images/acsclusterinfo.png "Get Cluster Info")

3. Comprobar todos los nodos de la siguiente manera:

   ```bash
   kubectl get nodes
   ```

## Parte 6 - Cleanup

> Este paso es opcional :)

1. Borrar el cluster ejecutando el siguiente comando:

   ```bash
   az acs delete --resource-group $name-rgp --name $name --yes
   ```

2. Borrar el grupo de recursos:

   ```bash
   az group delete --name $name-rgp --yes
   ```

![Delete Cluster](images/acsdelete.png "Delete Cluster")

Ahora todo se borrará!

![Congratulations](images/congratulations.png "Congratulations")

**Well done!**

Gracias!