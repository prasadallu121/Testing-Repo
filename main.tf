# provider 
provider "aws" {
  region  = "${var.aws_region}"
}


# AWS S3 bucket for static hosting
resource "aws_s3_bucket" "website" {
  bucket = "${var.my-website}"
  acl = "public-read"

  
  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["PUT","POST"]
    allowed_origins = ["*"]
    expose_headers = ["ETag"]
    max_age_seconds = 3000
  }

  policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": "PublicReadForGetBucketObjects",
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::${var.my-website}/*"
    }
  ]
}
EOF

  website {
    index_document = "index.html"
    error_document = "error.html"
  }
}

# uploading HTML files
resource "aws_s3_bucket_object" "index" {
  bucket = "${aws_s3_bucket.website.bucket}"
  key    = "index.html"
  source = "scripts/index.html"
  content_type = "text/html"
  etag = "${filemd5("${path.module}/scripts/index.html")}"
  acl = "public-read"
}

resource "aws_s3_bucket_object" "error" {
  bucket = "${aws_s3_bucket.website.bucket}"
  key    = "error.html"
  source = "scripts/error.html"
  content_type = "text/html"
  #etag = "${filemd5("${path.module}../scripts/error.html")}"
  #etag = "${md5(file("scripts/error.html"))}" 
  acl = "public-read"
}

# output of endpoint
output "endpoint" {
    value = aws_s3_bucket.website.website_endpoint
}

# Creating DNS Zone and adding Alias record
resource "aws_route53_zone" "primary" {
  name = "pragnatrainings.xyz"
}

resource "aws_route53_record" "domain" {
   name = "pragnatrainings.xyz"
   zone_id = "${aws_route53_zone.primary.id}"
   type = "A"
   alias {
     name = "${aws_s3_bucket.website.website_domain}"
     zone_id = "${aws_s3_bucket.website.hosted_zone_id}"
     evaluate_target_health = false
   }
}

# Output of DNS name-servers to update if we registered as external eg. godaddy 
output "server-names" {
  value = aws_route53_zone.primary.name_servers
}

/*
# Uploading multiple resources
  resource "aws_s3_bucket_object" "uploading_resources" {
  for_each = fileset(path.module, "scripts/*")
  bucket = "${aws_s3_bucket.website.bucket}"
  key = each.value
  source = "${path.module}/${each.value}"
  acl = "public-read"
}

*/