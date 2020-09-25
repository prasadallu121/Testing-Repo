

module "my-web1" {
  source = "../s3-web"
  my-website = "my-third-website-today"
  #etag = "${file("${path.module}/index.html")}"
 #etag = "${filemd5("${path.module}/scripts/index.html")}"
 #etag = "${filemd5("${path.module}/scripts/error.html")}"
}