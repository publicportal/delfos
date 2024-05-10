resource oci_core_vcn delfos {
	cidr_blocks = [
		"10.0.0.0/16",
	]
	compartment_id = var.compartment_ocid
	display_name = "delfos"
	dns_label = "delfos"
	}

resource oci_core_subnet public-subnet-delfos {
	cidr_block = "10.0.0.0/24"
	compartment_id = var.compartment_ocid 
	display_name = "public subnet-delfos"
	dns_label = "public"
	prohibit_internet_ingress = "false"
	prohibit_public_ip_on_vnic = "false"
	vcn_id = oci_core_vcn.delfos.id
}

resource oci_core_subnet private-subnet-delfos {
	cidr_block = "10.0.1.0/24"
	compartment_id = var.compartment_ocid
	display_name = "private subnet-delfos"
	dns_label = "private"
	prohibit_internet_ingress = "true"
	prohibit_public_ip_on_vnic = "true"
	route_table_id = oci_core_route_table.route-table-for-private-subnet-delfos.id
	security_list_ids = [
		oci_core_security_list.security-list-for-private-subnet-delfos.id,
	]
	vcn_id = oci_core_vcn.delfos.id
}

resource oci_core_default_route_table default-route-table-for-delfos {
	compartment_id = var.compartment_ocid
	display_name = "default route table for delfos"
	manage_default_resource_id = oci_core_vcn.delfos.default_route_table_id
	route_rules {
		destination = "0.0.0.0/0"
		destination_type = "CIDR_BLOCK"
		network_entity_id = oci_core_internet_gateway.internet-gateway-delfos.id
	}
}



resource oci_core_default_security_list default-security-list-for-delfos {
  compartment_id = var.compartment_ocid
  display_name = "Default Security List for delfos"
  egress_security_rules {
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    protocol  = "all"
    stateless = "false"
  }
  ingress_security_rules {
    protocol    = "6"
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    stateless   = "false"
    tcp_options {
      max = "22"
      min = "22"
    }
  }
  ingress_security_rules {
    icmp_options {
      code = "4"
      type = "3"
    }
    protocol    = "1"
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    stateless   = "false"
  }
  ingress_security_rules {
    icmp_options {
      code = "-1"
      type = "3"
    }
    protocol    = "1"
    source      = "10.0.0.0/16"
    source_type = "CIDR_BLOCK"
    stateless   = "false"
  }
  manage_default_resource_id = oci_core_vcn.delfos.default_security_list_id
}




resource oci_core_route_table route-table-for-private-subnet-delfos {
	compartment_id = var.compartment_ocid
	display_name = "route table for private subnet-delfos"
	route_rules {
		destination = "0.0.0.0/0"
		destination_type = "CIDR_BLOCK"
		network_entity_id = oci_core_nat_gateway.nat-gateway-delfos.id
	}
	route_rules {
		destination = "all-mad-services-in-oracle-services-network"
		destination_type = "SERVICE_CIDR_BLOCK"
		network_entity_id = oci_core_service_gateway.service-gateway-delfos.id
	}
	vcn_id = oci_core_vcn.delfos.id
}

resource oci_core_security_list security-list-for-private-subnet-delfos {
	compartment_id = var.compartment_ocid
	display_name = "security list for private subnet-delfos"
	egress_security_rules {
		destination = "0.0.0.0/0"
		destination_type = "CIDR_BLOCK"
		protocol = "all"
		stateless = "false"
	}
	ingress_security_rules {
		protocol = "6"
		source = "10.0.0.0/16"
		source_type = "CIDR_BLOCK"
		stateless = "false"
		tcp_options {
			max = "22"
			min = "22"
		}
	}
	ingress_security_rules {
		icmp_options {
			code = "4"
			type = "3"
		}
		protocol = "1"
		source = "0.0.0.0/0"
		source_type = "CIDR_BLOCK"
		stateless = "false"
	}
	ingress_security_rules {
		icmp_options {
			code = "-1"
			type = "3"
		}
		protocol = "1"
		source = "10.0.0.0/16"
		source_type = "CIDR_BLOCK"
		stateless = "false"
	}
	vcn_id = oci_core_vcn.delfos.id
}

resource oci_core_nat_gateway nat-gateway-delfos {
	block_traffic = "false"
	compartment_id = var.compartment_ocid
	display_name = "NAT gateway-delfos"
	#TODO:review if ip is auto-assigned
	#public_ip_id = "ocid1.publicip.oc1.eu-madrid-1.aaaaaaaasnmv7gj76u7n25hjij2jec56nebsiksv2kc3pjz6tt2lo42w2bpq"
	vcn_id = oci_core_vcn.delfos.id
}

resource oci_core_internet_gateway internet-gateway-delfos {
	compartment_id = var.compartment_ocid
	display_name = "Internet gateway-delfos"
	enabled = "true"
	vcn_id = oci_core_vcn.delfos.id
}

data "oci_core_services" "all_oci_services" {
	filter {
		name = "name"
		values = ["All .* Services In Oracle Services Network"]
		regex = true
	}
	count = 1
}

resource oci_core_service_gateway service-gateway-delfos {
	compartment_id = var.compartment_ocid
	display_name = "Service gateway-delfos"
	services {
		service_id = lookup(data.oci_core_services.all_oci_services[0].services[0], "id")
	}
	vcn_id = oci_core_vcn.delfos.id
}

resource "oci_core_volume" "pitia-storage" {
	availability_domain = "fkND:EU-MADRID-1-AD-1"
	compartment_id = var.compartment_ocid
	display_name = "pitia-storage"
	is_auto_tune_enabled = "false"
	size_in_gbs = "50"
	vpus_per_gb = "10"
}

data "template_file" "cloud-config" {
    template = <<YAML
#cloud-config
runcmd:
 - sudo snap install microk8s --classic

 - sudo usermod -a -G microk8s ubuntu
 - mkdir -p ~/.kube
 - chmod 0700 ~/.kube

 - sudo sed -i '$a auth       [success=ignore default=1] pam_succeed_if.so user = ubuntu' /etc/pam.d/su
 - sudo sed -i '$a auth       sufficient   pam_succeed_if.so use_uid user ingroup ubuntu' /etc/pam.d/su

 - su - $USER

 - microk8s stop

 - sudo iptables --flush
 - sudo iptables -tnat --flush
 - sudo iptables -P FORWARD ACCEPT

 - microk8s start
 - microk8s status --wait-ready


 - microk8s enable dashboard
 - alias kubectl='microk8s kubectl'
YAML
}

resource "oci_core_instance" "pitia" {
	agent_config {
		is_management_disabled = "false"
		is_monitoring_disabled = "false"
		plugins_config {
			desired_state = "DISABLED"
			name = "Vulnerability Scanning"
		}
		plugins_config {
			desired_state = "DISABLED"
			name = "Management Agent"
		}
		plugins_config {
			desired_state = "ENABLED"
			name = "Custom Logs Monitoring"
		}
		plugins_config {
			desired_state = "DISABLED"
			name = "Compute RDMA GPU Monitoring"
		}
		plugins_config {
			desired_state = "ENABLED"
			name = "Compute Instance Monitoring"
		}
		plugins_config {
			desired_state = "DISABLED"
			name = "Compute HPC RDMA Auto-Configuration"
		}
		plugins_config {
			desired_state = "DISABLED"
			name = "Compute HPC RDMA Authentication"
		}
		plugins_config {
			desired_state = "ENABLED"
			name = "Cloud Guard Workload Protection"
		}
		plugins_config {
			desired_state = "DISABLED"
			name = "Block Volume Management"
		}
		plugins_config {
			desired_state = "DISABLED"
			name = "Bastion"
		}
	}
	availability_config {
		is_live_migration_preferred = "false"
		recovery_action = "RESTORE_INSTANCE"
	}
	availability_domain = "fkND:EU-MADRID-1-AD-1"
	compartment_id = var.compartment_ocid
	create_vnic_details {
		assign_ipv6ip = "false"
		assign_private_dns_record = "true"
		assign_public_ip = "true"
		subnet_id = oci_core_subnet.public-subnet-delfos.id
	}
	display_name = "pitia"
	instance_options {
		are_legacy_imds_endpoints_disabled = "false"
	}
	is_pv_encryption_in_transit_enabled = "true"
	metadata = {
		"ssh_authorized_keys" = var.ssh_authorized_keys
        user_data = "${base64encode(data.template_file.cloud-config.rendered)}"
	}
	shape = "VM.Standard.A1.Flex"
	shape_config {
		memory_in_gbs = "4"
		ocpus = "1"
	}
	source_details {
		source_id = var.source_id
		source_type = "image"
	}
}

resource "oci_core_volume_attachment" "pitia_storage_attachment" {
	#Required
	attachment_type = "paravirtualized"
	instance_id = oci_core_instance.pitia.id
	volume_id = oci_core_volume.pitia-storage.id

	#Optional
	display_name = "pitia_storage"
	is_pv_encryption_in_transit_enabled = "true"
	is_read_only = "false"
	is_shareable = "false"
	depends_on = [
		oci_core_volume.pitia-storage,
		oci_core_instance.pitia
	]
}
