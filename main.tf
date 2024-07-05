data "aws_iam_policy_document" "assume_role" {
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
  name              = "/aws/lambda/${var.lambda_name}"
  retention_in_days = 90
}

resource "aws_iam_role" "lambda_role" {
  name               = "${var.lambda_name}-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_policy" "no_log_group_lambda_policy" {
  name = "${var.lambda_name}-no-log-group-policy"
  path = "/"
  // description = "Policy for creating log groups and logging to cloudwatch for lambda"
  policy = data.aws_iam_policy_document.lambda_exec_role_policy_sans_log_group.json
}

resource "aws_iam_role_policy_attachment" "no_log_group_lambda_policy_attachment" {
  policy_arn = aws_iam_policy.no_log_group_lambda_policy.arn
  role       = aws_iam_role.lambda_role.name
}

resource "aws_iam_policy" "lambda_policy" {
  count = var.resource_policy_json != "" ? 1 : 0
  name   = "${var.lambda_name}-policy"
  policy = var.resource_policy_json
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  count = var.resource_policy_json != "" ? 1 : 0
  policy_arn = aws_iam_policy.lambda_policy.arn
  role       = aws_iam_role.lambda_role.name
}

data "local_file" "lambda_handler" {
  filename = "${var.lambda_dir}/${var.lambda_subdir}/handler.py"
}

data "local_file" "upsert_query" {
  count    = var.upsert_query != "" ? 1 : 0
  filename = "${var.query_dir}/${var.upsert_query}"
}

data "archive_file" "lambda_deploy_package" {
  output_path = "${var.lambda_dir}/out/${var.lambda_name}.zip"
  type        = "zip"

  source {
    content  = data.local_file.lambda_handler.content
    filename = "handler.py"
  }

  source {
    content  = var.upsert_query != "" ? data.local_file.upsert_query[0].content : ""
    filename = "upsert.sql"
  }
}

resource "aws_lambda_function" "lambda" {
  filename                       = data.archive_file.lambda_deploy_package.output_path
  function_name                  = var.lambda_name
  role                           = aws_iam_role.lambda_role.arn
  handler                        = "handler.handler"
  timeout                        = var.timeout
  source_code_hash               = data.archive_file.lambda_deploy_package.output_base64sha256
  layers                         = [for layer in var.lambda_layers : layer.arn]
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

resource "aws_cloudwatch_log_subscription_filter" "log_error_filter" {
  for_each        = "stage" == var.env ? {} : var.log_alarm_filters
  destination_arn = each.value
  filter_pattern  = each.key
  log_group_name  = aws_cloudwatch_log_group.log_group.name
  name            = "log_error_filter_${var.lambda_name}"
}
