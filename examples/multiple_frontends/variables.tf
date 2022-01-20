variable "namespace" {
  type        = string
  description = "Namespace use to prefix resource's names"
  default     = "padok"
  validation {
    condition     = length(var.namespace) <= 6
    error_message = "The namespace must be a 6 chars string."
  }
}
