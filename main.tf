#tfsec:ignore:aws-s3-enable-versioning
#tfsec:ignore:aws-s3-encryption-customer-key

resource "aws_s3_bucket" "cloud_resume_site_bucket" {
  bucket = "tf-aws-joh887-cloud-resume-challenge"

   server_side_encryption_configuration {
     rule {
        bucket_key_enabled = true

        apply_server_side_encryption_by_default {
         sse_algorithm     = "AES256"
       }
     }
   }
}

resource "aws_s3_bucket_public_access_block" "cloud_resume_site_bucket" {
  bucket = aws_s3_bucket.cloud_resume_site_bucket.id
  block_public_acls = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets = true
}






#TODO: prevent billshock in AWS
#TODO: introduce tfsec
#TODO: introduce best practice tf project structure
#TODO: add state lock dynamodb
#TODO: add default tags