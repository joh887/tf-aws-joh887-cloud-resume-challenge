#tfsec:ignore:aws-s3-enable-versioning
resource "aws_s3_bucket" "cloud_resume_site_bucket" {
  bucket = "tf-aws-joh887-cloud-resume-challenge-${var.environment}-site"
}

#tfsec:ignore:aws-s3-encryption-customer-key
resource "aws_s3_bucket_server_side_encryption_configuration" "cloud_resume_site_bucket" {
  bucket = aws_s3_bucket.cloud_resume_site_bucket.id

  rule {
    bucket_key_enabled = true
    
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "cloud_resume_site_bucket" {
  bucket = aws_s3_bucket.cloud_resume_site_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

locals {
  content_types = {
    ".html" = "text/html"
    ".css"  = "text/css"
    ".js"   = "application/javascript"
    ".png"  = "image/png"
    ".jpg"  = "image/jpeg"
    ".eot"  = "application/vnd.ms-fontobject"
    ".svg"  = "image/svg+xml"
    ".ttf"  = "font/ttf"
    ".woff" = "font/woff"
    ".woff2"= "font/woff2"
    #".scss"= "<mime-type>"
    // Check if scss is needed.
 }
}

resource "aws_s3_bucket_object" "HarryJoh-ezcv-website-recursive" {
 bucket   = aws_s3_bucket.cloud_resume_site_bucket.id
 for_each = fileset("${var.website_path}", "**/*.*")

 key      = each.value
 source   = "${var.website_path}${each.value}"

 // Default to binary/octet-stream if no match found in map.
 content_type = lookup(local.content_types, regex("\\.[^.]+$", each.value), "binary/octet-stream")
 etag     = filemd5("${var.website_path}${each.value}")
}

resource "aws_s3_object" "index" {
  bucket = aws_s3_bucket.cloud_resume_site_bucket.id
  key    = "index.html"
  source = "site/index.html"
  etag = filemd5("site/index.html")
  content_type = "text/html"
}

resource "aws_s3_object" "error" {
  bucket = aws_s3_bucket.cloud_resume_site_bucket.id
  key    = "error.html"
  source = "src/error.html"
  etag = filemd5("src/error.html")
  content_type = "text/html"
}

resource "aws_s3_bucket_website_configuration" "cloud_resume_site_bucket" {
  bucket = aws_s3_bucket.cloud_resume_site_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_cloudfront_origin_access_identity" "cloud_resume_site_bucket" {
  comment = "Used for the cloud_resume_site_bucket."
}

resource "aws_cloudfront_distribution" "cloud_resume_site_bucket" {
  origin {
    domain_name = aws_s3_bucket.cloud_resume_site_bucket.bucket_regional_domain_name
    origin_id   = "cloudResumeSiteOrigin"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.cloud_resume_site_bucket.cloudfront_access_identity_path
    }
  }

  enabled = true
  is_ipv6_enabled = true
  default_root_object = "index.html"

  logging_config {
    include_cookies = false
    bucket          = aws_s3_bucket.cloud_resume_logging_bucket.bucket_domain_name
    prefix          = "cloud-resume-cf-logs"
  }

  default_cache_behavior {
    # Using the CachingDisabled managed policy during active development of this page. This should be changed upon completion.
    cache_policy_id  = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods = ["GET", "HEAD"]
    target_origin_id = "cloudResumeSiteOrigin"
    viewer_protocol_policy = "redirect-to-https"
  }

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["AU","US","KR"]
    }
  }
      
  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

data "aws_iam_policy_document" "cloud_resume_site_bucket" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.cloud_resume_site_bucket.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.cloud_resume_site_bucket.iam_arn]
    }
  }
}

resource "aws_s3_bucket_policy" "cloud_resume_site_bucket" {
  bucket = aws_s3_bucket.cloud_resume_site_bucket.id
  policy = data.aws_iam_policy_document.cloud_resume_site_bucket.json
}


#tfsec:ignore:aws-s3-enable-bucket-logging
#tfsec:ignore:aws-s3-encryption-customer-key
resource "aws_s3_bucket" "cloud_resume_logging_bucket" {
  bucket = "tf-aws-joh887-cloud-resume-challenge-logging-${var.environment}"
}

resource "aws_s3_bucket_versioning" "cloud_resume_logging_bucket" {
  bucket = aws_s3_bucket.cloud_resume_logging_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "cloud_resume_logging_bucket" {
  bucket = aws_s3_bucket.cloud_resume_logging_bucket.id

  rule {
    bucket_key_enabled = true

    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "cloud_resume_logging_bucket" {
  bucket = aws_s3_bucket.cloud_resume_logging_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "cloud_resume_logging_bucket" {
  bucket = aws_s3_bucket.cloud_resume_logging_bucket.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "cloud_resume_logging_bucket" {
  bucket = aws_s3_bucket.cloud_resume_logging_bucket.id
  acl    = "log-delivery-write"
}

resource "aws_s3_bucket_logging" "cloud_resume_logging_bucket" {
  bucket = aws_s3_bucket.cloud_resume_site_bucket.id

  target_bucket = aws_s3_bucket.cloud_resume_logging_bucket.id
  target_prefix = "log/"
}


#TODO: prevent billshock in AWS
#TODO: introduce best practice tf project structure
#TODO: add default tags