output "lambda_function_name" {
  value = aws_lambda_function.resizer.function_name
}

output "input_bucket_name" {
  value = aws_s3_bucket.input_bucket.id
}

output "output_bucket_name" {
  value = aws_s3_bucket.output_bucket.id
}
