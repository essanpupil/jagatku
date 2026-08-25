data "terraform_remote_state" "vpc" {
  backend = "consul"
  config = {
    address = "consul.laptop1.local"
    scheme  = "http"
    path    = "gcp/global/vpc"
  }
}
