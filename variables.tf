variable "name" {
  description = "The name of the service you're referring to."
  type        = string
}

variable "location" {
  description = "The location to use for your service."
  type        = string
}

variable "project_id" {
  description = "The project to deploy the ressources to."
  type        = string
}

variable "labels" {
  description = "Labels to apply to the service."
  type        = map(string)
  default = {
    "terraform" = "true",
  }
}

variable "force_destroy" {
  description = "The feature flag to allow destroying bucket event if it contains files."
  type        = bool
  default     = false
}
