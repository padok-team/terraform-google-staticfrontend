variable "name" {
  description = "The name of the service."
  type        = string
}

variable "location" {
  description = "The location to deploy the service to."
  type        = string
}

variable "project_id" {
  description = "The project to deploy the resources to."
  type        = string
}

variable "labels" {
  description = "A list of labels to apply to the service."
  type        = map(string)
  default = {
    "terraform" = "true",
  }
}

variable "force_destroy" {
  description = "A flag to allow destroying bucket even if it contains files."
  type        = bool
  default     = false
}
variable "uniform_bucket_level_access" {
  description = "Whether to enable uniform bucket-level access for the bucket."
  type        = bool
  default     = true
}
