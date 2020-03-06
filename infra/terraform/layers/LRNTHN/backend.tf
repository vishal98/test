terraform {
     backend "local" {
       path = "/var/jenkins_home/terraform.tfstate"
     }
}
