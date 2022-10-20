variable "env" {
  type        = string
  description = "Environment (Typically one of 'test', 'stage' or 'prod')"
}
variable "lambda_code_dir" {}
variable "name_prefix" {}
variable "lambda_name" {}
variable "lambda_source_dir_name" {
  type        = string
  description = "The name of the folder within lambda_code_dir that contains the source code for the lambda"
}
variable "query_dir" {
  type        = string
  description = "The local path of the directory with SQL queries"
  default     = "../../queries"
}
variable "upsert_query" {
  type        = string
  description = "The path/filename (starting from query_dir) of the upsert sql"
  default     = ""
}
variable "runtime" {
  default = "python3.8"
}
variable "resource_policy" {}
variable "security_group_ids" {
  type    = list(any)
  default = []
}
variable "subnet_ids" {
  type    = list(any)
  default = []
}
variable "environment_variables" {
  default = {}
  type    = map(any)
}
variable "layers" {
  type    = list(any)
  default = []
}
variable "timeout" {
  default = 120
}
variable "memory" {
  default = 128
}
variable "log_alarm_filters" {
  type    = map(any)
  default = {}
}
variable "reserved_concurrent_executions" {
  default = -1
}
variable "invoke_from_s3" {
  type        = bool
  default     = false
  description = "Whether the lambda will be invoked from an S3 bucket notification. Use with allow_bucket."
}
variable "allow_bucket" {
  default = ""
}
variable "python_version" {
  type    = string
  default = "python3.8"
}
variable "lambda_layers" {
  description = "A list of lambda layers that this lambda will use"
  type = list(object({
    arn = string
  }))
  default = []
}
