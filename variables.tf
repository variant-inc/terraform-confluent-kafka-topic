variable "environment" {
  description = "Environment where the cluster is located"
  type        = string
}


variable "confluent_prefix" {
  description = <<EOF
  Prefix of the Resources

  For non-prod, it is empty
  EOF
  type        = string
}


variable "cluster_name" {
  description = "Confluent Kafka Cluster Name"
  type        = string
}

variable "topics" {
  description = <<EOT
List of Topics

1. For existing, full name has to be provided.
2. For managed, a prefix is added to non-prod environments.
3. To get write/produce access to existing topic, set `write_access=true`
EOT
  type = object({
    managed = optional(list(object({
      name             = string
      partitions_count = optional(number)
      config           = optional(map(string))
    })))
    existing = optional(list(object({
      full_name    = string
      pattern_type = optional(string)
      write_access = optional(bool)
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
