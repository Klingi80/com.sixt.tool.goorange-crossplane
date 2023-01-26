data "terraform_remote_state" "crossplane_ek_cluster" {
  backend = "s3"

  config = {
    bucket = "sixt-terraform-state"
    key    = "goorange/dev/crossplane_ek_cluster/terraform.tfstate"
    region = "eu-west-1"
  }
}