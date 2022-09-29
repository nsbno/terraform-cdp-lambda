variable "env" {}
variable "lambda_code_dir" {}
variable "name_prefix" {}
variable "lambda_name" {}
variable "lambda_source_dir_name" {
  type = string
  default = var.lambda_name
  description = "The name of the folder within lambda_code_dir that contains the source code for the lambda"
}
variable "runtime" {
  default = "python3.8"
}
variable "resource_policy" {}
variable "security_group_ids" {
  type = list
  default = []
}
variable "subnet_ids" {
  type = list
  default = []
}
variable "environment_variables" {
  default = {}
  type = map
}
variable "layers" {
  type = list
  default = []
}
variable "timeout" {
  default = 120
}
variable "memory" {
  default = 128
}
variable "log_alarm_filters" {
  type = map
  default = {}
}
variable "reserved_concurrent_executions" {
  default = -1
}
variable "allow_bucket" {
  default = ""
}
variable "python_version" {
  type = string
  default = "python3.8"
}
