variable "api_port" {
  default = {
    dev = "4002"
    qa  = "5002"
  }
}

variable "web_port" {
  default = {
    dev = "4001"
    qa  = "5001"
  }
}