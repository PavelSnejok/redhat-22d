variable "stage" {
  type = string
  validation {
    condition = contains(["dev", "prod"], var.stage)
    error_message = "Stage must be either dev or prod."
  }
}

variable "devops_role" {
  type = string
}

variable "devops_policy" {
  type = string
}