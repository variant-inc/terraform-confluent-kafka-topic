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
  description = <<EOT
List of Topics

1. By default, `create_topic = true` for all topics under produce.
2. If topic is created in this repo using `create_topic = true`,
   then a prefix is added.
3. If topic is not created as part of this repo,
   then prefix is not added and the full name has to be provided
EOT
  type = object({
    produce = optional(list(object({
      name             = string
      partitions_count = optional(number)
      config           = optional(map(string))
      create_topic     = optional(bool)
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
