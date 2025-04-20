terraform{
    required_providers{
        google = {
            source = "hashicorp/google"
            version = "6.30.0"
        }
    }
}


# provider configuration
provider "google" {
    region = "us-central1"
}

# new project
resource "google_project" "project_trial"{
    name = "third-time-is-a-charm"
    project_id = "project-20-04-2025"
    billing_account = "013D15-5C95AE-6B9BD4"
}


# required to create a new project and resources
resource "google_project_iam_member" "project_owner"{
    project = google_project.project_trial.project_id
    role = "roles/owner"
    member = "user:eklovyasharma77@gmail.com"
    lifecycle {
    prevent_destroy = true
  }
}

# required to create vm,s
resource "google_project_service" "compute_api" {
    project = google_project.project_trial.project_id
    service = "compute.googleapis.com"
}


# required to create GCP cluster
resource "google_project_service" "k8s_api" {
    project = google_project.project_trial.project_id
    service = "container.googleapis.com"
}

# network configuration for cluster
resource "google_compute_network" "k8s_network" {
    project = google_project.project_trial.project_id
    name = "cluster-network"
    auto_create_subnetworks = false
}

# subnetwork for cluster
resource "google_compute_subnetwork" "k8s_Subnet" {
    project = google_project.project_trial.project_id
    name = "cluster-subnetwork"
    network = google_compute_network.k8s_network.name
    ip_cidr_range = "10.0.0.0/27"
    region = "us-central1"
}

resource "google_container_cluster" "cluster_of_magic" {
    name = "cluster-abra-ca-dabra"
    project = google_project.project_trial.project_id
    location = "us-central1-c"
    initial_node_count = 1
    remove_default_node_pool = true
    network = google_compute_network.k8s_network.name
    subnetwork = google_compute_subnetwork.k8s_Subnet.name
}

resource "google_container_node_pool" "node_pool_de_magic" {
    name = "mystery-node-pool"
    project = google_project.project_trial.project_id
    location = "us-central1-c"
    cluster = google_container_cluster.cluster_of_magic.name
    node_count = 1
    node_config {
        machine_type = "e2-micro"
        disk_type = "pd-standard"
        disk_size_gb = 12
        oauth_scopes  = ["https://www.googleapis.com/auth/cloud-platform"]
    }
}

