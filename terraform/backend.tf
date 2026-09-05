terraform {
  backend "s3" {
    bucket       = "terraform-s3-backend-e-commerce"
    key          = "terraform.tfstate"
    region       = "ap-south-1"
    use_lockfile = true
  }
}
