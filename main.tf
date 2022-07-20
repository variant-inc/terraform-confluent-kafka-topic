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
  topics = defaults(var.topics, {
    produce = {
      create_topic     = true
      partitions_count = var.topic_prefix != "" ? 2 : 6
    }
    consume = {}
  })

  create_topics = [for t in local.topics.produce :
    merge(t, {
      name = "${var.topic_prefix}.${t.name}"
    })
  if(t.create_topic)]

  existing_topics = distinct(concat(
    [for t in local.topics.produce : t.create_topic ? (
      "${var.topic_prefix}.${t.name}"
    ) : t.name],
    [for t in local.topics.consume : t.name]
  ))

  service_account_name = "${var.topic_prefix}.${var.service_account_name}"
  consumer_group       = "confluent_cli_consumer_${confluent_service_account.app.id}"

  description = join(" ", [for k in keys(var.tags) :
    "${k}: ${var.tags[k]};"
  ])
}

resource "confluent_kafka_topic" "topics" {
  for_each = {
    for t in local.create_topics :
    t.name => t
  }

  topic_name       = each.value.name
  rest_endpoint    = data.confluent_kafka_cluster.cluster.rest_endpoint
  config           = each.value.config
  partitions_count = each.value.partitions_count

  kafka_cluster {
    id = data.confluent_kafka_cluster.cluster.id
  }
}

data "confluent_kafka_topic" "topics" {
  for_each = {
    for t in local.existing_topics :
    t => t
  }

  rest_endpoint = data.confluent_kafka_cluster.cluster.rest_endpoint
  topic_name    = each.value

  kafka_cluster {
    id = data.confluent_kafka_cluster.cluster.id
  }

  depends_on = [
    confluent_kafka_topic.topics
  ]
}

resource "aws_ssm_parameter" "topics" {
  for_each = {
    for t in local.create_topics :
    t.name => t
  }

  name  = "topic-${each.value.name}"
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

resource "confluent_kafka_acl" "app_producer_write_on_topic" {
  for_each = {
    for t in local.topics.produce :
    t.name => t
  }

  resource_type = "TOPIC"
  resource_name = each.value.create_topic ? (
    data.confluent_kafka_topic.topics["${var.topic_prefix}.${each.key}"].topic_name
    ) : (
    data.confluent_kafka_topic.topics[each.key].topic_name
  )
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

resource "confluent_kafka_acl" "app_consumer_read_on_topic" {
  for_each = {
    for t in local.topics.consume :
    t.name => t
  }

  resource_type = "TOPIC"
  resource_name = data.confluent_kafka_topic.topics[each.key].topic_name
  pattern_type  = "LITERAL"
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
  count = length(local.topics.consume) == 0 ? 0 : 1

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
