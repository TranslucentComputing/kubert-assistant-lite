---
layout: default
title: Azure VM Windows Deployment
parent: Installation
nav_order: 2
nav_fold: false
---

# Azure VM Windows 10 Pro Deployment: A Complete Guide

Deploying a Windows Virtual Machine (VM) on Microsoft Azure allows you to create a scalable and flexible environment for development, testing, or any other business needs. Azure provides a cloud-based platform where you can easily deploy and manage Windows VMs, taking advantage of the power and security of Microsoft's infrastructure. This document will guide you through the process of deploying a Windows 10 Pro VM on Azure, from the initial setup to accessing the VM remotely.

**Note:** While you can select other versions of Windows, including Windows 11 Pro, this guide focuses on Windows 10 Pro to support the deployment of Kubert AI Assistant Lite for developers, who mostly use Windows 10 Pro on their personal development PCs.

## Prerequisites

Before you begin, ensure you have the following:

- **Azure Subscription**: An active Azure subscription is required. If you don’t have one, you can sign up for a free account at the [Azure portal](https://azure.microsoft.com/en-ca/){:target="_blank"}.

## Step 1: Sign in to the Azure Portal

1. Open your web browser and go to the Azure Portal.
2. Sign in with your Microsoft account.

[![Azure home](/kubert-assistant-lite/assets/images/azure-vm/1_azure-home.png)](/kubert-assistant-lite/assets/images/azure-vm/1_azure-home.png)

## Step 2: Create a Virtual Machine

1. Navigate to the "Virtual Machine" section in the Azure Portal.
    [![Azure VM Home](/kubert-assistant-lite/assets/images/azure-vm/2_azure-vm-home.png)](/kubert-assistant-lite/assets/images/azure-vm/2_azure-vm-home.png)
2. Click "Create" and select "Azure virtual machine".
    [![Create VM](/kubert-assistant-lite/assets/images/azure-vm/3_create-vm.png)](/kubert-assistant-lite/assets/images/azure-vm/3_create-vm.png)

## Step 3: Configure the VM

1. Start by creating a new, click "Create a resource".
    [![Create Resource](/kubert-assistant-lite/assets/images/azure-vm/4_create-resource-group.png)](/kubert-assistant-lite/assets/images/azure-vm/4_create-resource-group.png)

    `Note`-> **Benefits of Using a Resource Group for Cleanup**:
    - **Centralized Management**: A resource group allows you to manage all related resources as a single unit. This means that all components related to your VM (e.g., virtual network, public IP address, network interface, storage accounts) are organized under one resource group.
    - **Simplified Deletion**: If you no longer need the VM and its associated resources, you can delete the entire resource group in one action. This ensures that no orphaned resources are left behind, which can otherwise incur unnecessary costs.
    - **Cost Management**: By grouping related resources together, you can more easily track the costs associated with a specific project or environment. When you're done with the project, deleting the resource group removes all associated costs.
    - **Isolation**: Resource groups help isolate environments, especially in cases where you might have multiple projects or environments (e.g., development, testing, production). This reduces the risk of accidentally deleting or modifying resources that are unrelated to your current task.
2. Enter the host name and choose the region where you want to deploy the VM.
    [![Host Name](/kubert-assistant-lite/assets/images/azure-vm/5_define_host_name.png)](/kubert-assistant-lite/assets/images/azure-vm/5_define_host_name.png)
3. Select image and security type.
    [![Image Name](/kubert-assistant-lite/assets/images/azure-vm/6_security_and_image.png)](/kubert-assistant-lite/assets/images/azure-vm/6_security_and_image.png)

    `Note`-> For the security type, select "Standard" to support nested virtualization, more on that in the size section. We selected the Windows 10 Pro image and chose "Run with Azure Spot discount." There is no expectation for this VM, which is used for development and testing, to run for a long time uninterrupted. Therefore, using the spot discount can significantly reduce costs.
4. Select the size.
   [![Size](/kubert-assistant-lite/assets/images/azure-vm/7_size_cpu_ram.png)](/kubert-assistant-lite/assets/images/azure-vm/7_size_cpu_ram.png)

   `Note`-> We plan to run Windows Subsystem for Linux (WSL) within the VM, it's crucial to select a VM size that supports nested virtualization. Nested virtualization  allows you to run a virtual machine inside another virtual machine, which is necessary for WSL.

   [What is Nested Virtualization](https://learn.microsoft.com/en-us/virtualization/hyper-v-on-windows/user-guide/nested-virtualization){:target="_blank"}

   Not all Azure VM sizes support nested virtualization. Typically, VMs in the Dv3, Ev3, and newer series (like Dv4 or Ev4) support this feature. Ensure you select a VM size from a CPU family that offers nested virtualization support.
   List of CPU families that support nested virtualization can be found [here](https://learn.microsoft.com/en-us/azure/virtual-machines/acu){:target="_blank"}.
5. Account and inbound ports.
   [![Size](/kubert-assistant-lite/assets/images/azure-vm/8_account_port.png)](/kubert-assistant-lite/assets/images/azure-vm/8_account_port.png)

   `Note`-> Enter the username and password that will be used to log into Windows 10 pro. Disable the "Public inbound ports". The specific inbound ports will be configured once the VM has been deployed. Accept the licensing and click "Next: Disks >" to continue the configuration.
6. Disks
   [![Size](/kubert-assistant-lite/assets/images/azure-vm/9_disks.png)](/kubert-assistant-lite/assets/images/azure-vm/9_disks.png)

   `Note`-> No updates are required in this section, click on the "Next: Networking >" to continue the configuration.
7. Networking
   [![Size](/kubert-assistant-lite/assets/images/azure-vm/10_delete_public_ip.png)](/kubert-assistant-lite/assets/images/azure-vm/10_delete_public_ip.png)

   `Note`-> Check of the "Delete public IP and NIC when VM is deleted" to help with resource cleanup once the VM has been deleted. Click on the "Next: Management ->" to continue the configuration.
8. Auto-shutdown
   [![Auto Shutdown](/kubert-assistant-lite/assets/images/azure-vm/11_auto-shutdown.png)](/kubert-assistant-lite/assets/images/azure-vm/11_auto-shutdown.png)

   `Note`-> Don't leave you VM running, enable the auto-shutdown and the time and timezone, to shutdown the VM automatically. We will stop the configuration here, click on "Review + create". For advance use case continue the configuration to the monitoring section. 
9. Trigger deployment.
   [![Start VM creation](/kubert-assistant-lite/assets/images/azure-vm/12_create-vm.png)](/kubert-assistant-lite/assets/images/azure-vm/12_create-vm.png.png)

   `Note`-> Review the configuration and click "Create" to start the deployment.
10. Deploying
   [![Deploying](/kubert-assistant-lite/assets/images/azure-vm/13_deploying.png)](/kubert-assistant-lite/assets/images/azure-vm/13_deploying.png)
11. Deployment completed, go to the resource.
   [![Deployed](/kubert-assistant-lite/assets/images/azure-vm/14_done-deployment.png)](/kubert-assistant-lite/assets/images/azure-vm/14_done-deployment.png)
12. Deployed host
   [![Host](/kubert-assistant-lite/assets/images/azure-vm/15_host.png)](/kubert-assistant-lite/assets/images/azure-vm/15_host.png)
13. Set RDP port
   [![Set RDP Port](/kubert-assistant-lite/assets/images/azure-vm/16_set-rdp-port.png)](/kubert-assistant-lite/assets/images/azure-vm/16_set-rdp-port.png)

    `Note`-> Go to the "Operations" section, then "Run command", select the "SetRDPPort"
14. Enter the RDP port and execute the script.
   [![Enter RDP Port](/kubert-assistant-lite/assets/images/azure-vm/17_enter-port.png)](/kubert-assistant-lite/assets/images/azure-vm/17_enter-port.png)
15. RDP port updated
   [![RDP Port Set](/kubert-assistant-lite/assets/images/azure-vm/18_port-set.png)](/kubert-assistant-lite/assets/images/azure-vm/18_port-set.png)
16. Set inbound networking rule
   [![Inbound Rule](/kubert-assistant-lite/assets/images/azure-vm/19_set-inbound-rule.png)](/kubert-assistant-lite/assets/images/azure-vm/19_set-inbound-rule.png)

    `Note`-> Go to the "Networking" section, then "Networking settings", click "Create port rule" and select "inbound port rule"
17. Configure "My IP address" security rule
   [![My IP Rule](/kubert-assistant-lite/assets/images/azure-vm/20_my-ip-rule.png)](/kubert-assistant-lite/assets/images/azure-vm/20_my-ip-rule.png)

    `Note`-> For the source, select "My IP address"; it will auto-populate the Source IP with your IP address. For the "Destination port ranges," add the RDP port used in the previous step. The protocol should be TCP, and provide a description for clarity.
18. Download RDP file
   [![Download RDP File](/kubert-assistant-lite/assets/images/azure-vm/22_download-rdp-file.png)](/kubert-assistant-lite/assets/images/azure-vm/22_download-rdp-file.png)

## Step 4: Remote Desktop

1. Edit the downloaded RDP file.
    [![RDP config](/kubert-assistant-lite/assets/images/azure-vm/23_remote-desktop.png)](/kubert-assistant-lite/assets/images/azure-vm/23_remote-desktop.png)

2. Update the port.
    [![Updated RDP config](/kubert-assistant-lite/assets/images/azure-vm/24_updated-port.png)](/kubert-assistant-lite/assets/images/azure-vm/24_updated-port.png)

3. Start remote desktop and log into Windows.
    [![windows](/kubert-assistant-lite/assets/images/azure-vm/25_logged-in.png)](/kubert-assistant-lite/assets/images/azure-vm/25_logged-in.png)
