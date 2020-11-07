provider "azurerm" {

    features {}
}

# Create Virtal network
resource "azurerm_virtual_network" "test" {
 name                = "acctvn"
 address_space       = ["10.0.0.0/16"]
 location            = var.location
 resource_group_name = var.resource_group_name
 
   tags = {
        environment = "Terraform Demo"
    }
 
}

# Create Subnet
resource "azurerm_subnet" "test" {
 name                 = "acctsub"
 resource_group_name  = var.resource_group_name
 virtual_network_name = azurerm_virtual_network.test.name
 address_prefixes       = ["10.0.2.0/24"]
 
 
 
}

# Create Public IP for Loadbalancer
resource "azurerm_public_ip" "test" {
 name                         = "publicIPForLB"
 location                     = var.location
 resource_group_name          = var.resource_group_name
 allocation_method            = "Static"
 
   tags = {
        environment = "Terraform Demo"
    }
 
}


# Create Loadbalancer
resource "azurerm_lb" "test" {
 name                = "loadBalancer"
 location            = var.location
 resource_group_name = var.resource_group_name

 frontend_ip_configuration {
   name                 = "publicIPAddress"
   public_ip_address_id = azurerm_public_ip.test.id
 }
 
   tags = {
        environment = "Terraform Demo"
    }
 
}


# Create NSG to explicitly allow access to other VMs in the subnet and deny access from the internet
resource "azurerm_network_security_group" "test" {
    name                = "myNSG"
    location            = var.location
    resource_group_name = var.resource_group_name
	

security_rule {
		name                       = "allow-lb"
        priority                   = 110
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "TCP"
        source_port_range          = "*"
        destination_port_range     = "80"
        source_address_prefix      = "AzureLoadBalancer"
        destination_address_prefix = "*"
  }

  security_rule {
        name                       = "deny-internet"
        priority                   = 120
        direction                  = "Inbound"
        access                     = "Deny"
        protocol                   = "TCP"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
  }
  
    security_rule {
		name 						= "allow-all-vmss"
		priority 					= 100
		direction 					= "Inbound"
		access 						= "Allow"
		protocol 					= "TCP"
		source_port_range 			= "*"
		destination_port_range 		= "*"
		source_address_prefix 		= "VirtualNetwork"
		destination_address_prefix 	= "*"
  }
    
    tags = {
        environment = "Terraform Demo"
    }
}


# Create backend address pool
resource "azurerm_lb_backend_address_pool" "test" {
 resource_group_name = var.resource_group_name
 loadbalancer_id     = azurerm_lb.test.id
 name                = "BackEndAddressPool"
 
  
 
}


# Create Network Interface
resource "azurerm_network_interface" "test" {
 count               = var.num_instance
 name                = "acctni${count.index}"
 location            = var.location
 resource_group_name = var.resource_group_name

 ip_configuration {
   name                          = "ipconfig${count.index}" 
   subnet_id                     = azurerm_subnet.test.id
   private_ip_address_allocation = "dynamic"
 }
 
   tags = {
        environment = "Terraform Demo"
    }
 
}


# Create backend address pool and NI association
resource "azurerm_network_interface_backend_address_pool_association" "test" {
	count = var.num_instance
	network_interface_id  =  element(azurerm_network_interface.test.*.id, count.index)
	ip_configuration_name = "ipconfig${count.index}"
	backend_address_pool_id = azurerm_lb_backend_address_pool.test.id

  
}


# Create Azure Managed Disc
resource "azurerm_managed_disk" "test" {
 count                = var.num_instance
 name                 = "datadisk_existing_${count.index}"
 location             = var.location
 resource_group_name  = var.resource_group_name
 storage_account_type = "Standard_LRS"
 create_option        = "Empty"
 disk_size_gb         = "1023"
 
   tags = {
        environment = "Terraform Demo"
    }
}


# Create Availability Set
resource "azurerm_availability_set" "avset" {
 name                         = "avset"
 location                     = var.location
 resource_group_name          = var.resource_group_name
 platform_fault_domain_count  = var.num_instance
 platform_update_domain_count = var.num_instance
 managed                      = true
 
   tags = {
        environment = "Terraform Demo"
    }
}






# Access Packer Image created previously

data "azurerm_image" "image" {
  name                = var.image_name
  resource_group_name = var.resource_group_name
}


# Create Linux VM

  resource "azurerm_linux_virtual_machine" "vm" {
		count = var.num_instance
		name = "acctvm${count.index}"
		resource_group_name = var.resource_group_name
		location = var.location
		size = "Standard_DS1_v2"
		
		admin_username = "vmtest"
		admin_password = "Goodday@123"
		availability_set_id = azurerm_availability_set.avset.id
		disable_password_authentication = false
		
		network_interface_ids = [
			azurerm_network_interface.test[count.index].id,
		]

		source_image_id = data.azurerm_image.image.id
		
		os_disk {
			storage_account_type = "Standard_LRS"
			caching = "ReadWrite"
		}
		
		
		  tags = {
        environment = "Terraform Demo"
    }

}