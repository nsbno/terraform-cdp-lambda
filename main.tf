locals {
  lambda_dir       = "${var.lambda_code_dir}/${var.lambda_source_dir_name}"
  lambda_name_full = "${var.name_prefix}-${var.lambda_name}"
  lambda_layers    = concat([{ arn : "arn:aws:lambda:eu-west-1:336392948345:layer:AWSSDKPandas-Python39:1" }], var.lambda_layers)
}

data "aws_iam_policy_document" "lambda_assume_role_policy" {
  statement {
    actions = [
      "sts:AssumeRole"
    ]
    principals {
      identifiers = [
        "lambda.amazonaws.com"
      ]
      type = "Service"
    }
    effect = "Allow"
  }
}

data "aws_iam_policy_document" "lambda_exec_role_policy_sans_log_group" {
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "arn:aws:logs:*:*:*"
    ]
  }
}

resource "aws_cloudwatch_log_group" "log_group" {
  name              = "/aws/lambda/${aws_lambda_function.lambda.function_name}"
  retention_in_days = 365
}

resource "aws_iam_role" "lambda_role" {
  name               = "${local.lambda_name_full}-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json
}

resource "aws_iam_policy" "no_log_group_lambda_policy" {
  name   = "${local.lambda_name_full}-no-log-group-policy"
  policy = data.aws_iam_policy_document.lambda_exec_role_policy_sans_log_group.json
}

resource "aws_iam_role_policy_attachment" "no_log_group_lambda_policy_attachment" {
  policy_arn = aws_iam_policy.no_log_group_lambda_policy.arn
  role       = aws_iam_role.lambda_role.name
}

resource "aws_iam_policy" "lambda_policy" {
  name   = "${local.lambda_name_full}-policy"
  policy = var.resource_policy
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  policy_arn = aws_iam_policy.lambda_policy.arn
  role       = aws_iam_role.lambda_role.name
}

data "archive_file" "lambda_deploy_package" {
  output_path = "${local.lambda_dir}.zip"
  source_dir  = local.lambda_dir
  type        = "zip"
}

resource "aws_lambda_function" "lambda" {
  filename                       = data.archive_file.lambda_deploy_package.output_path
  function_name                  = local.lambda_name_full
  role                           = aws_iam_role.lambda_role.arn
  handler                        = "handler.handler"
  timeout                        = var.timeout
  source_code_hash               = data.archive_file.lambda_deploy_package.output_base64sha256
  layers                         = [for layer in local.lambda_layers : layer.arn]
  runtime                        = var.runtime
  memory_size                    = var.memory
  reserved_concurrent_executions = var.reserved_concurrent_executions
  environment {
    variables = var.environment_variables
  }
  vpc_config {
    security_group_ids = var.security_group_ids
    subnet_ids         = var.subnet_ids
  }
}

resource "aws_lambda_permission" "allow_bucket" {
  count         = var.allow_bucket != "" ? 1 : 0
  statement_id  = "AllowExecutionFromS3${local.lambda_name_full}"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = var.allow_bucket
}

resource "aws_cloudwatch_log_subscription_filter" "log_error_filter" {
  for_each        = "stage" == var.env ? {} : var.log_alarm_filters
  destination_arn = each.value
  filter_pattern  = each.key
  log_group_name  = aws_cloudwatch_log_group.log_group.name
  name            = "log_error_filter_${local.lambda_name_full}"
}
