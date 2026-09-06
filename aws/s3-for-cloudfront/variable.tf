variable "bucket_prefix_name" {
  description = "The prefix name of the S3 bucket"
  type        = string
  validation {
    condition     = length(var.bucket_prefix_name) > 0
    error_message = "The bucket prefix name must not be empty."
  }

  validation {
    condition     = length(var.bucket_prefix_name) <= 54
    error_message = "The bucket prefix name must not exceed 54 characters."
  }

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.bucket_prefix_name))
    error_message = "The bucket prefix name must only contain lowercase letters, numbers, and hyphens."
  }

  validation {
    condition     = !can(regex("^-|-$", var.bucket_prefix_name))
    error_message = "The bucket prefix name must not start or end with a hyphen."
  }
}

variable "tags" {
  description = "A map of tags to assign to the bucket"
  type        = map(string)
  default     = {}
}

variable "force_destroy" {
  description = "A boolean that indicates all objects should be deleted from the bucket so that the bucket can be destroyed without error"
  type        = bool
  default     = false
}