module "alldb" {
  count           = length(var.DB)
  source          = "./module"
  ENV             = var.ENV
  INSTANCE_TYPE   = var.INSTANCE_TYPE
  KEY_NAME        = var.KEY_NAME
  bucket          = var.bucket
  component       = element(var.DB, count.index)
  PORT            = element(var.PORTS, count.index)
}

variable "DB" {
  default = ["rabbitmq", "mysql", "redis", "mongo"]
}
variable "PORTS" {
  default = [5672, 3306, 6379, 27017]
}
