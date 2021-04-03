# Configure the AWS Provider
provider "aws" {
  region = "ap-south-1" 
}

resource "aws_s3_bucket" "tf_course" {
  bucket = "tf-course-20210403"
  acl    = "private"
}
