locals {
  bucket_name = var.bucket_name
}

resource "aws_s3_bucket" "frontend" {
  bucket = local.bucket_name

  tags = {
    Project   = var.project
    ManagedBy = "Terraform"
  }
}

locals {
  bucket_id     = aws_s3_bucket.frontend.id
  bucket_arn    = aws_s3_bucket.frontend.arn
  bucket_domain = aws_s3_bucket.frontend.bucket_regional_domain_name
}

resource "random_id" "oac" {
  byte_length = 2
}

resource "aws_s3_bucket_website_configuration" "frontend" {
  bucket = local.bucket_id
  index_document { suffix = "index.html" }
  error_document { key = "index.html" }
}

resource "aws_s3_bucket_public_access_block" "frontend" {
  bucket                  = local.bucket_id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_cloudfront_origin_access_control" "frontend" {
  name                              = "${var.project}-oac-${random_id.oac.hex}"
  description                       = "OAC for ${var.project} frontend"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "frontend" {
  enabled             = true
  comment             = "${var.project} frontend"
  default_root_object = "index.html"

  origin {
    domain_name = local.bucket_domain
    origin_id   = "s3-frontend"

    origin_access_control_id = aws_cloudfront_origin_access_control.frontend.id
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "s3-frontend"

    viewer_protocol_policy = "redirect-to-https"
    compress               = true

    forwarded_values {
      query_string = false
      cookies { forward = "none" }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  custom_error_response {
    error_code            = 404
    response_code         = 200
    response_page_path    = "/index.html"
    error_caching_min_ttl = 0
  }

  custom_error_response {
    error_code            = 403
    response_code         = 200
    response_page_path    = "/index.html"
    error_caching_min_ttl = 0
  }
}

data "aws_iam_policy_document" "frontend_s3_policy" {
  statement {
    sid     = "AllowCloudFrontRead"
    effect  = "Allow"
    actions = ["s3:GetObject"]
    resources = [
      "${local.bucket_arn}/*"
    ]
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.frontend.arn]
    }
  }
}

resource "aws_s3_bucket_policy" "frontend_cf_only" {
  bucket = local.bucket_id
  policy = data.aws_iam_policy_document.frontend_s3_policy.json
}
