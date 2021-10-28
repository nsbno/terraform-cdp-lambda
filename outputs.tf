output "arn" {
  value = aws_lambda_function.lambda.arn
}
output "invoke_arn" {
  value = aws_lambda_function.lambda.invoke_arn
}
output "function_name" {
  value = aws_lambda_function.lambda.function_name
}
output "lambda_permission" {
  value = var.allow_bucket != "" ? aws_lambda_permission.allow_bucket[0].id : ""
}