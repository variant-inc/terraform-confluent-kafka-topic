data "confluent_environment" "environment" {
  display_name = var.environment
}

data "confluent_kafka_cluster" "cluster" {
  display_name = var.cluster_name
  environment {
    id = data.confluent_environment.environment.id
  }
}

locals {
  prefix           = var.confluent_prefix == "" ? "" : "${var.confluent_prefix}."
  partitions_count = local.prefix != "" ? 2 : 6

  service_account_name = "${local.prefix}${var.service_account_name}"
  consumer_group       = "confluent_cli_consumer_${confluent_service_account.app.id}"

  description = join(" ", [for k in keys(var.tags) :
    "${k}: ${var.tags[k]};"
  ])
}

resource "confluent_kafka_topic" "topics" {
  for_each = {
    for t in var.topics.managed :
    t.name => t
  }

  topic_name       = "${local.prefix}${each.value.name}"
  rest_endpoint    = data.confluent_kafka_cluster.cluster.rest_endpoint
  config           = each.value.config
  partitions_count = each.value.partitions_count != null && each.value.partitions_count != local.partitions_count ? each.value.partitions_count : local.partitions_count

  kafka_cluster {
    id = data.confluent_kafka_cluster.cluster.id
  }
}

resource "aws_ssm_parameter" "topics" {
  for_each = {
    for t in var.topics.managed :
    t.name => t
  }

  name  = "topic-${each.value.name}-${data.confluent_kafka_cluster.cluster.id}"
  type  = "String"
  value = yamlencode(var.tags)
  tags  = var.tags
}

resource "confluent_service_account" "app" {
  display_name = local.service_account_name
  description  = substr(local.description, 0, 127)
}

resource "confluent_api_key" "app" {
  display_name = local.service_account_name
  description  = "Kafka API Key that is owned by '${local.service_account_name}' service account"
  owner {
    id          = confluent_service_account.app.id
    api_version = confluent_service_account.app.api_version
    kind        = confluent_service_account.app.kind
  }

  managed_resource {
    id          = data.confluent_kafka_cluster.cluster.id
    api_version = data.confluent_kafka_cluster.cluster.api_version
    kind        = data.confluent_kafka_cluster.cluster.kind

    environment {
      id = data.confluent_environment.environment.id
    }
  }
}

resource "confluent_kafka_acl" "app_producer_write_on_managed_topic" {
  for_each = confluent_kafka_topic.topics

  resource_type = "TOPIC"
  resource_name = each.value.topic_name
  pattern_type  = "LITERAL"
  principal     = "User:${confluent_service_account.app.id}"
  host          = "*"
  operation     = "WRITE"
  permission    = "ALLOW"
  rest_endpoint = data.confluent_kafka_cluster.cluster.rest_endpoint

  kafka_cluster {
    id = data.confluent_kafka_cluster.cluster.id
  }
}

resource "confluent_kafka_acl" "app_producer_write_on_existing_topic" {
  for_each = {
    for t in var.topics.existing :
    t.full_name => t if t.write_access
  }

  resource_type = "TOPIC"
  resource_name = each.key
  pattern_type  = each.value.pattern_type
  principal     = "User:${confluent_service_account.app.id}"
  host          = "*"
  operation     = "WRITE"
  permission    = "ALLOW"
  rest_endpoint = data.confluent_kafka_cluster.cluster.rest_endpoint

  kafka_cluster {
    id = data.confluent_kafka_cluster.cluster.id
  }
}

resource "confluent_kafka_acl" "app_consumer_read_on_topic" {
  for_each = {
    for t in var.topics.existing :
    t.full_name => t if !t.write_access
  }

  resource_type = "TOPIC"
  resource_name = each.key
  pattern_type  = each.value.pattern_type
  principal     = "User:${confluent_service_account.app.id}"
  host          = "*"
  operation     = "READ"
  permission    = "ALLOW"
  rest_endpoint = data.confluent_kafka_cluster.cluster.rest_endpoint

  kafka_cluster {
    id = data.confluent_kafka_cluster.cluster.id
  }
}

resource "confluent_kafka_acl" "app_consumer_read_on_group" {
  count = length([for t in var.topics.existing : t if !t.write_access]) == 0 ? 0 : 1

  resource_type = "GROUP"
  resource_name = local.consumer_group
  pattern_type  = "PREFIXED"
  principal     = "User:${confluent_service_account.app.id}"
  host          = "*"
  operation     = "READ"
  permission    = "ALLOW"
  rest_endpoint = data.confluent_kafka_cluster.cluster.rest_endpoint

  kafka_cluster {
    id = data.confluent_kafka_cluster.cluster.id
  }
}
