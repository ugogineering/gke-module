data "google_client_config" "default" {}

provider "kubernetes" {
  host = "https://${module.gke.endpoint}"
  token = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke.ca_certificate)
}

module "gcp-network" {
  source  = "terraform-google-modules/network/google"
  version = ">= 7.5"

  project_id   = var.project_id
  network_name = var.network

  subnets = [
    {
      subnet_name   = var.subnetwork
      subnet_ip     = "10.0.0.0/17"
      subnet_region = var.region
    },
  ]

  secondary_ranges = {
    (var.subnetwork) = [
      {
        range_name    = var.ip_range_pods_name
        ip_cidr_range = "192.168.0.0/18"
      },
      {
        range_name    = var.ip_range_services_name
        ip_cidr_range = "192.168.64.0/18"
      },
    ]
  }
}

module "gke" {
  #depends_on = [
  #  google_project.project,
  #  google_project_service.google_project_services
  #]
  source  = "terraform-google-modules/kubernetes-engine/google"
  version = "30.0.0"
  # variables 
  project_id = var.project_id
  name = var.cluster_name
  release_channel = "REGULAR"
  region = var.region
  zones = var.zones
  network = module.gcp-network.network_name
  subnetwork = module.gcp-network.subnets_names[0]
  ip_range_pods = var.ip_range_pods_name
  ip_range_services = var.ip_range_services_name
  create_service_account = false
  remove_default_node_pool = true
  disable_legacy_metadata_endpoints = false
  cluster_autoscaling = var.cluster_autoscaling
  # authenticator_security_group = "gke-security-group@company.com"

  node_pools = [
    {
        name = "pool-01"
        machine_type = "e2-medium"
        autoscaling = true 
        min_count = 1
        max_count = 20
        local_ssd_count = 0
        disk_size_gb = 100
        disk_type = "pd-standard"
        image_type = "cos_containerd"
        auto_repair = true
        auto_upgrade = true
        node_metadata = "GKE_METADATA"
        pod_range = var.ip_range_pods_name
        enable_private_nodes = true 
    },
  ]
  node_pools_metadata = {
    all = {}
  }
  node_pools_taints = {
    all = []
  }
  node_pools_oauth_scopes = {
    all = [
        "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}