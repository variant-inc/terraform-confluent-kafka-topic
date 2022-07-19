variable "environment" {
  description = "Environment where the cluster is located"
  type        = string
}


variable "topic_prefix" {
  description = <<EOF
  Prefix of the Topic.
  It is the first 3 characters of the environment.

  For non-prod, it is empty
  EOF
  type        = string
  default     = ""
}


variable "cluster_name" {
  description = "Confluent Kafka Cluster Name"
  type        = string
}

variable "topics" {
  description = "List of Topics"
  type = object({
    produce = optional(list(object({
      name             = string
      partitions_count = optional(number)
      config           = optional(map(string))
    })))
    consume = optional(list(object({
      name = string
    })))
  })
}

variable "service_account_name" {
  description = "Name of the service account"
  type        = string
}

variable "tags" {
  description = "Tags"
  type        = map(string)
}
