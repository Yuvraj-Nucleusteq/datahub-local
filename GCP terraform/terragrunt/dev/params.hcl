local { 

#global
gcp_credential = "C:/Users/opera/Desktop/GCP terraform/credentials.json"
project_id = "nuodata-catalog"
region = "us-west2"
gke_cluster_name = "nuodata-gke-cluster"
gke_zones = ["us-west2-a", "us-west2-b"]
environment = "dev"

#gke cluster
node_pools_name = "Nuodata-node-pool"
service_account_name = "yuvrajbhadouria@nuodata-catalog.iam.gserviceaccount.com"
machine_type = "e2-standard-2"

#sql
database_name = "nuodata-database"
database_user_name = "user"
database_version = "MYSQL_8_0"
database_tier = "db-f1-micro"

}