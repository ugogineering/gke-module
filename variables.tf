variable "project_id" {
  description = "The project ID to host the cluster in"
}

variable "cluster_name" {
  description = "The name for the GKE cluster"
  default     = "gke-on-vpc-cluster"
}

variable "region" {
  description = "The region to host the cluster in"
  default     = "us-east1"
}

variable "network" {
  description = "The VPC network created to host the cluster in"
  default     = "gke-network"
}

variable "subnetwork" {
  description = "The subnetwork created to host the cluster in"
  default     = "gke-subnet"
}

variable "ip_range_pods_name" {
  description = "The secondary ip range to use for pods"
  default     = "ip-range-pods"
}

variable "ip_range_services_name" {
  description = "The secondary ip range to use for services"
  default     = "ip-range-svc"
}
variable "cluster_name_suffix" {
    description = "A suffix to append to the default cluster name"
    default = "ter-01" #
}

variable "zones" {
    type = list(string)
    description = "The zone to host the cluster in (required in zonal cluster)"
    default = ["us-east1-b", "us-east1-c", "us-east1-d"]
}

variable "cluster_autoscaling" {
    type = object( {
        enabled = bool
        autoscaling_profile = string
        min_cpu_cores = number
        max_cpu_cores = number
        min_memory_gb = number
        max_memory_gb = number
        auto_repair = bool
        auto_upgrade = bool
        gpu_resources = list(object({
            resource_type = string 
            minimum = number 
            maximum = number
        }))
    })
    default = {
        enabled = false
        auto_repair = true
        auto_upgrade = true 
        autoscaling_profile = "BALANCED"
        max_cpu_cores = 100
        min_cpu_cores = 0
        max_memory_gb = 120
        min_memory_gb = 0
        gpu_resources = [{
            resource_type = "avidia-tesla-t4"
            minimum =  0
            maximum = 6
        }]
    }
    description = "Cluster autoscaling configuration. See more at: https://cloud.google.com/kubernetes-engine/docs/reference/rest/v1beta1/projects.location.clusters#clusterautoscaling"
}