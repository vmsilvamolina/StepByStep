# DEMO - Utilizar Azure Automation para desplegar el rol de Web Server

Paso a paso sobre como integrar PowerShell DSC para desplegar el rol de Web Server por medio de Azure Automation. Previo a lo anterior, se generará una VM utilizando la CLI de Azure.

| **Descrcipción** | **Valor utilizado en esta guía** |
| --- | --- |
| Resource group | IaC-Automation |
| Región en Azure | eastus |
| Nombre de la VM | Server2016 |
| Nombre del usuario | vmsilvamolina |

**1-** Crear la VM:

Desde la Azure Cloud Shell debemos ejecutar:

    ResourceGroupName="IaC-Automation"
    VmName="Server2016"
    AdminPassword="Passw0rd.Meetup.2018"

En donde se define una variable para definir el nombre del Resource Group, de la VM y la contraseña del administrador del servidor Windows.

Luego ejecutamos lo siguiente para generar el Resource Group:

    az group create --name $ResourceGroupName --location eastus

**2-** Crear la VM con Azure CLI:

Para crear la VM, simplemente debemos ejecutar:

    az vm create \
        --resource-group $ResourceGroupName \
        --name $VmName \
        --image win2016datacenter \
        --admin-username vmsilvamolina \
        --admin-password $AdminPassword \
        --size Basic_A1 \
        --use-unmanaged-disk \
        --storage-sku Standard_LRS

**3-** Crear la cuenta Azure Run As:

a) Ingresar al portal de Azure y seleccionar **Create a resource**.
b) En la barra de búsqueda, ingresar Automation y seleccionar el primer resultado. Seleccionar **Create**.
c) Completar el asistente de creación con los valores solicitados.

**4-** Crear el archivo de PowerShell DSC:

Desde la consola de PowerShell, guardar como **TestConfig.ps1** el siguiente código:

    configuration TestConfig {
        Node IsWebServer {
            WindowsFeature IIS {
                Ensure               = 'Present'
                Name                 = 'Web-Server'
                IncludeAllSubFeature = $true

            }
        }

        Node NotWebServer {
            WindowsFeature IIS {
                Ensure               = 'Absent'
                Name                 = 'Web-Server'

            }
        }
    }

**5-** Generar la configuración desde Automation:

a) Dentro del portal de Azure, y ubicados en grupo de recursos correspondiente. Seleccionamos la Automation Account recién creada.
b) Seleccionamos **DSC Configurations** y luego **Add Configurations**.
c) Seleccionamos para importar el archivo de PowerShell DSC **TestConfig.ps1**.

**6-** Conectamos la VM y aplicamos la configuración

a) Dentro de la Automation Account seleccionamos** DSC Nodes** y luego **Add Azure VM**.
b) Elegimos de la lista la VM a la cuál queremos aplicar la configuración y seleccionamos **Connect**.
c) Dentro del asistente de conexión a la VM, definimos el rol de Web Server (o no, en caso que sea necesario).