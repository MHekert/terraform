variable "asc_max_size" {
  type    = number
  default = 1
}

variable "asc_min_size" {
  type    = number
  default = 1
}

variable "desired_count" {
  type    = number
  default = 1
}

variable "app_port" {
  type    = number
  default = 8080
}

variable "app_container_name" {
  type    = string
  default = "app-container"
}

variable "task_memory" {
  type    = number
  default = 512
}

variable "EXAMPLE_SECRET" {
  type    = string
  default = "<placeholder>"
}
