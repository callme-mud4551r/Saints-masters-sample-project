terraform {
  backend "s3" {
    bucket = "your-terraform-state-bucket"
    key    = "eks/terraform.tfstate"
    region = "ap-south-1"
  }
}
