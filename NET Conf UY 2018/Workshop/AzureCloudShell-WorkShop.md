# Azure Cloud Shell: de 0 a Ninja!

Workshop pensado para introducirnos a esta herramienta disponible desde el navegador...

**Victor Silva**

[Blog](https://blog.victorsilva.com.uy) | [@vmsilvamolina](https://twitter.com/vmsilvamolina) | [Linked-In](https://www.linkedin.com/in/vmsilvamolina/) | [Email](mailto:vmsilvamolina@hotmail.com) | [GitHub](https://www.github.com/vmsilvamolina)


## Contenido

- [Azure Cloud Shell: de 0 a Ninja!](#azure-cloud-shell-de-0-a-ninja)
  - [Contenido](#contenido)
  - [Conocimiento previo](#conocimiento-previo)
  - [Nuevos skills](#nuevos-skills)
  - [Requisitos](#requisitos)
  - [Parte 1 - Accediendo a la Azure Cloud Shell](#parte-1---accediendo-a-la-azure-cloud-shell)
  - [Parte 2 - Crear una Virtual Machine](#parte-2---crear-una-virtual-machine)
- [Introducción a Ansible](#introducci%C3%B3n-a-ansible)
  - [Introduction to Containers, Docker and Kubernetes](#introduction-to-containers-docker-and-kubernetes)
  - [Part 3 - Manage Cluster with Cloud Shell](#part-3---manage-cluster-with-cloud-shell)
  - [Part 4 - Deploy your First Application](#part-4---deploy-your-first-application)
  - [Part 5 - Scale up your First Application](#part-5---scale-up-your-first-application)
  - [Part 6 - Editing a Deployed Application](#part-6---editing-a-deployed-application)
  - [Part 7 - When Disaster Strikes](#part-7---when-disaster-strikes)
  - [Step 8 - Cleanup After the Workshop](#step-8---cleanup-after-the-workshop)


  - [Introduction to Containers, Docker and Kubernetes](#introduction-to-containers-docker-and-kubernetes)
  - [Part 3 - Manage Cluster with Cloud Shell](#part-3---manage-cluster-with-cloud-shell)
  - [Part 4 - Deploy your First Application](#part-4---deploy-your-first-application)
  - [Part 5 - Scale up your First Application](#part-5---scale-up-your-first-application)
  - [Part 6 - Editing a Deployed Application](#part-6---editing-a-deployed-application)
  - [Part 7 - When Disaster Strikes](#part-7---when-disaster-strikes)
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
        az network nic create \
          --resource-group CloudShellWS \
          --name NIC \
          --vnet-name vNET \
          --subnet subnet \
          --network-security-group NetworkSecurityGroup \
          --public-ip-address PublicIP

6. Ahora sí, con todos los recursos generados, vamos a crear la virtual machine.

Pero antes, vamos a generar una variable (la password):

        AdminPassword=ChangeYourAdminPassword1

Finalmente ejecutamos el comando para crear la VM:
        az vm create \
            --resource-group CloudShellWS \
            --name VM \
            --location eastus \
            --nics NIC \
            --image win2016datacenter \
            --admin-username azureuser \
            --admin-password $AdminPassword

7. Para validad que todo está OK, vamos a conectarnos a la VM.

Lo primero que debemos hacer es abrir el puerto 3389:

        az vm open-port --port 3389 --resource-group CloudShellWS --name VM

Y luego utilizamos el cliente RDP para conectarnos con el usuario y clave.

# Introducción a Ansible



































We will now use the Cloud Shell to create a new Azure Container Service (ACS)
Kubernetes cluster that will be used to host our containers.

Any ACS service you create will be publically accessible on the internet.
A URL will be automatically assigned to your ACS service that you will be
able to use to access your containers and manage your cluster.

1. Launch an **Cloud Shell** in the Azure Portal or as a standalone console:

   [![Launch Cloud Shell](https://shell.azure.com/images/launchcloudshell.png "Launch Cloud Shell")](https://shell.azure.com)

2. Depending on your type of subscription (Free, Azure Pass etc.) you may
   have to register the required resource providers. This is because by
   default many resource providers (types of resource providers) are not
   registered by default.

   This only needs to be done once for a subscription. To do this, run
   the following commands in Cloud Shell:

   ```bash
   az provider register --namespace Microsoft.Network
   az provider register --namespace Microsoft.Compute
   az provider register --namespace Microsoft.Storage
   az provider register --namespace Microsoft.ContainerService --wait
   ```

   ![Register Providers](images/registerproviders.png "Register Providers")

3. Come up with a **name** for your ACS service. The name must contain only
   letters and numbers and be globally unique because it will be used for
  the public URLs of your Kubernetes cluster.

1. Run this command in Cloud Shell, but change `<set me please>` to the
   **name** that you specified above.

   ```bash
   name="<set me please>"
   ```

   **Important: Please note this value and command down, because if your Cloud
   Shell closes the value will be removed and you'll have to define it in your
   Cloud Shell session again by re-running this command.**

1. Run this command your Cloud Shell to create a resource group:

   ```bash
   az group create --name $name-rgp --location EastUS
   ```

1. Run this command in Cloud Shell to create a Kubernetes cluster:

   ```bash
   az acs create --name $name --resource-group $name-rgp --location EastUS --dns-prefix $name --orchestrator-type kubernetes --generate-ssh-keys --agent-count 2
   ```

The ACS Kubernetes cluster will be created in your Azure subscription.
This will take at least 10 minutes to complete creation of the ACS.

![Create ACS](images/acscreate.png "Create ACS")

## Introduction to Containers, Docker and Kubernetes

Once the Kubernetes cluster has been created we can continue with the workshop.

In the meantime, we'll talk about what containers are and how they're used as
well as talking about the components that make up a Kubernetes cluster.

## Part 3 - Manage Cluster with Cloud Shell

Once your ACS has been created you will be able to review the resources that
have been created:

![ACS Resources](images/acsresources.png "ACS Resources")

Now that our cluster is deployed we need to configure Cloud Shell to be able
to manage it.

Kubernetes clusters always expose a management endpoint that the Kubernetes tools
and other software can use to control and monitor the cluster with. The FQDN
for this endpoint can be located by selecting the ACS cluster resource in the
resource group that we deployed to contain our cluster:

![ACS Management FQDN](images/acsresourcemanagementfqdn.png "ACS Management FQDN")

We can then configure the `kubectl` tool to manage this cluster. We could do this
manually, but the `Azure CLI` in Cloud Shell provides a handy way to do this for us.

1. Configure your Cloud Shell to manage your ACS by running the command:

   ```bash
   az acs kubernetes get-credentials --resource-group $name-rgp --name $name
   ```

   ![Configure Cloud Shell to manage ACS](images/configurecloudshellacs.png "Configure Cloud Shell to manage ACS")

1. Validate our cluster is running by running the command:

   ```bash
   kubectl cluster-info
   ```

   ![Get Cluster Info](images/acsclusterinfo.png "Get Cluster Info")

1. Check all nodes in the cluster by running the command:

   ```bash
   kubectl get nodes
   ```

## Part 4 - Deploy your First Application

We are going to start by deploying a simple two-tier voting web application:

![Your First Kubernetes App](images/firstdemoapplication.png "Your First Kubernetes App")

This application will contain two _Deployments_:

- **azure-vote-front** which will run a one or more _Pods_ hosting the
  web application containers. This will run on Port 80. A load balancing
  _Service_ will be configured to provide external access to the _Pods_.
- **azure-vote-back** which will run a single Redis cache container. This
  provides a cache so that the `azure-vote-front` end can share state data.
  This will be exposed on Port 6379 and will only be able to be accessed
  by the `azure-vote-front` _Pods_.

![Voting Web Application](images/ourdeployedapplication.png "Voting Web Application")

We will deploy this application by downloading the _Deployment_ file and
applying to the cluster. This will start the cluster automatically deploying
the application by downloading container images from the internet (Docker Hub)
and creating containers from them.

> Note: We could use a private container registry like Azure Container Registry
> to pull the container images from if we had private container images we had
> created.

You can review the _Deployment_ file by [clicking here](src/azure-vote.yml).

1. Download a Kubernetes _Deployment_ file for the demo app to your Cloud Shell:

   ```bash
   wget https://raw.githubusercontent.com/PlagueHO/AzureGlobalBootcamp2018/master/src/azure-vote.yml
   ```

1. Create the application by telling Kubernetes to create the _Deployments_
   and _Services_ using the _Deployment_ file by running this command in the
   Cloud Shell:

   ```bash
   kubectl create -f azure-vote.yml
   ```

1. Wait for the Kubernetes _Service_ to be started and become accessible
   by running this command in the Cloud Shell:

   ```bash
   kubectl get service azure-vote-front --watch
   ```

   _This may take a few minutes for the application images to be downloaded
   to the cluster and the application to be started up. Once the external IP
   address appears then the application is up and ready for us to use:_

   ![Wait for Kubernetes Demo App](images/waitforkubernetesdemoapp.png "Wait for Kubernetes Demo App")

1. Once the _Service_ reports an `EXTERNAL-IP` <kbd>CTRL+C</kbd> to exit
   watching.

1. Copy the `EXTERNAL-IP` address of YOUR application into the browser and
   your app should be shown:

   ![Your First Kubernetes App](images/firstdemoapplication.png "Your First Kubernetes App")

   Congratulations! You are now running your first Kubernetes application.

   ![Congratulations](images/congratulations.png "Congratulations")

1. Now let us look at the _Deployments_ on the Kubernetes cluster by
   running this command in Cloud Shell:

   ```bash
   kubectl get deployments
   ```

   This shows the applications deployed to the cluster and the number of
   replicas of each _Pod_:

   ![First Demo Deployments](images/firstdemodeployments.png "First Demo Deployments")

1. We can get a list of all the services running on the cluster by executing
   this command in Cloud Shell:

   ```bash
   kubectl get services
   ```

   ![First Demo Services](images/firstdemoservices.png "First Demo Services")

1. Finally, lets find out which nodes the _Pods_ are running on by
   executing this command in Cloud Shell:

   ```bash
   kubectl get pods -o wide
   ```

   ![First Demo Pods](images/firstdemopods.png "First Demo Pods")

   _This command enables us to see which _Pods_ are running on each
   Kubernetes agent. Normally we wouldn't worry to much about this, but we
   want to watch what happens **later** when we shut down one of our agents._

## Part 5 - Scale up your First Application

One of the awesome features of Kubernetes is how easy it is to scale up
(or down) our _Pods_ so that more replicas of a container run in it.

We can easily scale individual _Pods_ or configure autoscaling to let
Kubernetes manage the scale of indivual _Pods_ based on the load.

1. To scale the front end _Pod_ of our vote demo we can run the following
   command in our Cloud Shell:

   ```bash
   kubectl scale deployment azure-vote-front --replicas=3
   ```

   ![First Demo Scaled Up](images/firstdemoscaledup.png "First Demo Scaled Up")

1. Now have a look at the _Pods_ that are running on our agents
   by executing this command in Cloud Shell:

   ```bash
   kubectl get pods -o wide
   ```

   ![First Demo Scaled Pods](images/firstdemoscaleduppods.png "First Demo Scaled Pods")

1. Lets now set up the front end Pod to automatically scale between 2 and 5
   containers when the containers run at 75% CPU utilization by executing
   this command in our Cloud Shell:

   ```bash
   kubectl autoscale deployment azure-vote-front --min=2 --max=5 --cpu-percent=75
   ```

   ![First Demo Autoscaled](images/firstdemoautoscaled.png "First Demo Autoscaled")

## Part 6 - Editing a Deployed Application

Each _Deployment_ file that has been applied to a cluster is stored
within the Cluster master as a file and can be modified to apply changes
to the _Deployments_ and _Services_ in flight.
This enables reconfiguring almost any aspect of the _Deployment_ file
and have the changes applied to the _Deployments_ and _Services_ immediately.

For example, if we wanted to update the container image version of the
running containers to a new version then we could edit this file.
So, we'll now update to V2 of our running app without any user disruption
at all. This is the power of Kubernetes.

1. First, describe all the _Deployments_ on the cluster by running
   this command in Cloud Shell:

   ```bash
   kubectl describe deployments
   ```

1. To edit a _Deployment_ file, execute the following command in Cloud
   Shell:

   ```bash
   kubectl edit -f azure-vote.yml
   ```

   ![First Demo Edit Deployment](images/firstdemoeditdeployment.png "First Demo Edit Deployment")

   _This will open VIM to edit the file in Azure Cloud Shell, which if you're
   not familiar with it might be a little bit tricky._

1. Search for the text `azure-vote-front:v1` in by pressing <kbd>/</kbd> on
   your keyboard and then entering `azure-vote-front:v1` and press
   <kbd>enter</kbd>. This should locate the line that matches:

   ```yaml
   image: microsoft/azure-vote-front:v1
   ```

   ![First Demo Find Image](images/firstdemofindimage.png "First Demo Find Image")

1. Press <kbd>i</kbd> to enter _insert text_ mode and change the image to v2:

   ```yaml
   image: microsoft/azure-vote-front:v2
   ```

   ![First Demo Update Image](images/firstdemoupdateimage.png "First Demo Update Image")

1. Press <kbd>esc</kbd> to exit _insert text_ mode.

1. Press <kbd>:</kbd> and then press <kbd>w</kbd> and then <kbd>enter</kbd>
   to write the file.

   ![First Demo Write Update](images/firstdemowriteupdate.png "First Demo Write Update")

1. Press <kbd>:</kbd> and then press <kbd>q</kbd> and then <kbd>enter</kbd>
   to quit VIM.

> Alternately, if you get stuck with the VIM part, you can use this
> simple command to set the image that the `front-vote-front` deployment
> should run by executing this command in the Cloud Shell:
> ```bash
> kubectl set image deployment azure-vote-front azure-vote-front=microsoft/azure-vote-front:v2
> ```

   The changes to your Deployment will now be applied. A n  ew version of
   the container image will be downloaded and new containers deployed using
   it. As each running container is deployed the old version will be
   terminated.

   ![First Demo Update Progress](images/firstdemoupdateprogress.png "First Demo Update Progress")

1. We can now watch the rolling deployment of our new application by running
   this command in the Azure Cloud Shell:

   ```bash
   kubectl get pods -o wide --watch
   ```

1. Once all Pods report a status of `Running` press <kbd>CTRL+C</kbd> to
   exit watching.

   ![First Demo Update Complete](images/firstdemoupdatecomplete.png "First Demo Update Complete")

1. Now head back over to your running application in the browser and
   refresh the window to see the new version of your application
   running:

   ![First Demo V2 Running](images/firstdemoapplicationv2.png "First Demo V2 Running")

1. You can redeploy the previous version image by running this
   command in the Cloud Shell:

   ```bash
   kubectl set image deployment azure-vote-front azure-vote-front=microsoft/azure-vote-front:v1
   ```

## Part 7 - When Disaster Strikes

So, what happens when disaster strikes and one of your Kubernetes agents
(_Nodes_) goes down - or if you just need to take it out of the cluster to
update it?

This is where Kubernetes really shines - it will always make sure the desired
number of replicas are running for each _Pod_ in your _Deployment_, no matter
how many agents you have available.

If a _Node_ becomes unresponsive for 5 minutes then Kubernetes will automatically
evict it from the cluster and move all the running _Pods_ to another _Node_.
This will keep your systems running and reliable if unexpected outages occur.

If you're planning on performing maintainence on a _Nodes_ in your cluster
then typically you'd want to _Drain_ the _Nodes_ first. This ensures there
will be no service disruption. So let's see this in action.

1. First have a look at the containers that are running on our _Nodes_
   by executing this command in Cloud Shell:

   ```bash
   kubectl get pods -o wide
   ```

   You'll see that they're spread accross the two running _Nodes_.

   ![High Availabiliy Pods](images/highavailabilitystartpods.png "High Availabiliy Pods")

1. To make things a little bit easier we'll assign the name of
   one of our _Nodes_ to a variable by running this command in
   the Cloud Shell:

   ```bash
   nodename="k8s-agent-6a859ffc-1"
   ```

1. Now, lets _Drain_ one of the _Nodes_ by running this command in

   ```bash
   kubectl drain $nodename
   ```

   This stops new _Pods_ from being deployed to this _Node_, but
   leaves the existing _Pods_ running on it.

1. Lets simulate a complete failure of the _Node_ by shutting
   down the VM:

   Get the name of one of your _Nodes_ from the result of the
   previous command and execute this command (changing the `--name` parameter
   value to that of the _Node_ to stop):

   ```bash
   az vm stop --resource-group $name-rgp --name $nodename
   ```

1. It will take 5 minutes for the Kubernetes cluster to determine
   that the _Node_ is no longer available. At this point it will
   redeploy all the _Pods_ to the other running _Nodes_ and mark
   the failed _Pods_ as status `Unknown`:

   ![High Availabiliy Pods Unknown](images/highavailabilitypodsunknown.png "High Availabiliy Pods Unknown")

1. We will now start the VM back up (changing the `--name` parameter
   value to that of the _Node_ to start):

   ```bash
   az vm start --resource-group $name-rgp --name $nodename
   ```

1. A _Node_ that has been shutdown without removing it from the cluster
   will result in a status of `SchedulingDisabled`. Before the Kubernetes
   _Scheduler_ will start using it again we must _Uncordon_ the node

   ```bash
   kubectl uncordon $nodename
   ```

## Step 8 - Cleanup After the Workshop

> This step is optional and only needs to be done if you're finished with your
> cluster and want to get rid of it to save some Azure credit.

_Note: If you just want to pause running your cluster, you can actually go in and
shut each of the cluster VMs down. This will reduce some compute costs but won't
completely delete the cluster. You will still pay for some components._

1. Delete the cluster by running the following command in the Azure Cloud Shell:

   ```bash
   az acs delete --resource-group $name-rgp --name $name --yes
   ```

2. Delete the resource group by running this command in the Azure Cloud Shell:

   ```bash
   az group delete --name $name-rgp --yes
   ```

![Delete Cluster](images/acsdelete.png "Delete Cluster")

Everything will now be cleaned up and deleted and you won't be paying to run
an ACS Kubernetes cluster.

![Congratulations](images/congratulations.png "Congratulations")

**Well done!**
You have taken your first steps into the amazingly powerful world of
Containers, Kubernetes and Azure Container Service. This technology is
increadibly powerful and can allow your applications to run virtually
anywhere and they will always run the same way.

Thank you!