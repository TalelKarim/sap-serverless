variable "function_name" {
  type        = string
  description = "Lambda function name."
}

variable "description" {
  type        = string
  description = "Lambda description."
  default     = ""
}

variable "runtime" {
  type        = string
  description = "Lambda runtime (e.g. python3.12)."
  default     = "python3.12"
}

variable "handler" {
  type        = string
  description = "Lambda handler (e.g. app.handler)."
  default     = "app.handler"
}

variable "source_dir" {
  type        = string
  description = "Directory containing the Lambda source code."
}

variable "timeout" {
  type        = number
  description = "Lambda timeout in seconds."
  default     = 10
}

variable "memory_size" {
  type        = number
  description = "Lambda memory size in MB."
  default     = 256
}

variable "environment" {
  type        = map(string)
  description = "Environment variables for the Lambda."
  default     = {}
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to resources."
  default     = {}
}

variable "architectures" {
  type        = list(string)
  description = "Architectures for the Lambda (e.g. [\"x86_64\"] or [\"arm64\"])."
  default     = ["x86_64"]
}

variable "log_retention_in_days" {
  type        = number
  description = "CloudWatch Logs retention in days."
  default     = 14
}
