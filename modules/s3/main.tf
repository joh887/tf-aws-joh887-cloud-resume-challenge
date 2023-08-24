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

resource "aws_s3_object" "index" {
  bucket = aws_s3_bucket.cloud_resume_site_bucket.id
  key    = "index.html"
  source = "src/index.html"
  etag = filemd5("src/index.html")
}

resource "aws_s3_object" "error" {
  bucket = aws_s3_bucket.cloud_resume_site_bucket.id
  key    = "error.html"
  source = "src/error.html"
  etag = filemd5("src/error.html")
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

resource "aws_s3_bucket_policy" "cloud_resume_site_bucket" {
  bucket = aws_s3_bucket.cloud_resume_site_bucket.id
  policy = data.aws_iam_policy_document.cloud_resume_site_bucket.json
}

data "aws_iam_policy_document" "cloud_resume_site_bucket" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions = [
      "s3:GetObject"
      #TODO: "s3:ListBucket" Not sure if needed yet.
    ]

    resources = [
      aws_s3_bucket.cloud_resume_site_bucket.arn,
      "${aws_s3_bucket.cloud_resume_site_bucket.arn}/*",
    ]

    condition {
      test     = "ForAnyValue:StringLike"
      variable = "AWS:SourceArn"
      values   = ["arn:aws:cloudfront::966294396589::distribution/*"]
    }
  }
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