# A simple S3 bucket, intended here for storing things like deployment
# artifacts or database backups in later projects. Bucket names must be
# globally unique across ALL AWS accounts (not just yours), so a suffix
# variable is required rather than using the project name alone.

resource "aws_s3_bucket" "app_storage" {
  bucket = "${var.project_name}-storage-${var.bucket_suffix}"

  tags = {
    Name    = "${var.project_name}-storage"
    Project = var.project_name
  }
}

# Blocks all forms of public access by default. S3 buckets being
# accidentally left public is one of the most common real-world cloud
# security mistakes, so this is set explicitly rather than relying on
# whatever AWS's current default happens to be.
resource "aws_s3_bucket_public_access_block" "app_storage_block" {
  bucket = aws_s3_bucket.app_storage.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Versioning protects against accidental overwrites/deletions —
# every version of an object is kept rather than only the latest.
resource "aws_s3_bucket_versioning" "app_storage_versioning" {
  bucket = aws_s3_bucket.app_storage.id

  versioning_configuration {
    status = "Enabled"
  }
}
