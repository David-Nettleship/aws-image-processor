provider "aws" {
  region = var.aws_region
}

# Get current AWS account ID
data "aws_caller_identity" "current" {}

# Create Lambda function
resource "aws_lambda_function" "resizer" {
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  function_name    = "image-resizer"
  role            = aws_iam_role.lambda_role.arn
  handler         = "resizer.lambda_handler"
  runtime         = "python3.9"
  timeout         = 30
  memory_size     = 256

  layers = [aws_lambda_layer_version.pillow_layer.arn]

  environment {
    variables = {
      THUMBNAIL_SIZE = "128"
    }
  }
}

# Create ZIP file for Lambda function
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda/resizer.py"
  output_path = "${path.module}/lambda/resizer.zip"
}

# Create ZIP file for Pillow layer
data "archive_file" "pillow_layer" {
  type        = "zip"
  source_dir  = "${path.module}/lambda/layer"
  output_path = "${path.module}/lambda/pillow_layer.zip"
  depends_on  = [null_resource.pillow_layer]
}

# Prepare Pillow layer files
resource "null_resource" "pillow_layer" {
  triggers = {
    shell_script = filesha256("${path.module}/create_pillow_layer.sh")
  }

  provisioner "local-exec" {
    command = "bash ${path.module}/create_pillow_layer.sh"
  }
}

# Create Lambda Layer for Pillow
resource "aws_lambda_layer_version" "pillow_layer" {
  filename            = data.archive_file.pillow_layer.output_path
  layer_name         = "pillow-layer"
  compatible_runtimes = ["python3.9"]
  description        = "Layer containing Pillow library for image processing"
  source_code_hash   = data.archive_file.pillow_layer.output_base64sha256
}

# Create IAM role for Lambda
resource "aws_iam_role" "lambda_role" {
  name = "image_resizer_lambda_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# Attach basic Lambda execution policy
resource "aws_iam_role_policy_attachment" "lambda_basic" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda_role.name
}

# Create S3 buckets for input and output images
resource "aws_s3_bucket" "input_bucket" {
  bucket = "image-resizer-input-${data.aws_caller_identity.current.account_id}"
}

resource "aws_s3_bucket" "output_bucket" {
  bucket = "image-resizer-output-${data.aws_caller_identity.current.account_id}"
}

# S3 bucket notifications to trigger Lambda
resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.input_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.resizer.arn
    events              = ["s3:ObjectCreated:*"]
  }
}

# Allow S3 to invoke Lambda
resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.resizer.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.input_bucket.arn
}

# Additional S3 permissions for Lambda
resource "aws_iam_role_policy" "lambda_s3_policy" {
  name = "lambda_s3_policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject"
        ]
        Resource = ["${aws_s3_bucket.input_bucket.arn}/*"]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject"
        ]
        Resource = ["${aws_s3_bucket.output_bucket.arn}/*"]
      }
    ]
  })
}
