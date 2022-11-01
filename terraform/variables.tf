variable "prefix_name" {
  type        = string
  description = "String to prefix to resources names"
}

variable "upload_bucket_name" {
  type        = string
  description = "Name of S3 bucket Rekognition should read files from"
}

variable "domain_name" {
  type        = string
  default     = ""
  description = "The hosted zone domain name used by the HTML frontend"
}

variable "lambda" {
  type        = string
  description = "The hosted zone domain name used by the HTML frontend"
}


variable "create_eventbridge" {
  default = false
}

variable "create_api_gw" {
  default = false
}

variable "runtime" {
  type = string
}

variable "handler" {
  type = string
}

variable "policy" {
  type = string
}

variable "file_name" {
  type        = string
  description = "Name of S3 bucket Rekognition should read files from"
}

variable "stage_name" {
  default     = ""
  type        = string
  description = "Name of S3 bucket Rekognition should read files from"
}

variable "aws_acm_certificate" {
  default     = ""
  type        = string
  description = "Name of S3 bucket Rekognition should read files from"
}

variable "r53_zone" {
  default     = ""
  type        = string
  description = "Name of S3 bucket Rekognition should read files from"
}
