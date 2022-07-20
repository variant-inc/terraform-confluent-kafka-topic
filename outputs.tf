output "write_topics" {
  value = [for t in local.topics.produce : t.create_topic ? (
    "${var.topic_prefix}.${t.name}"
  ) : t.name]
  description = "Topics with Write Access"
}

output "read_topics" {
  value       = [for t in local.topics.consume : t.name]
  description = "Topics with Read Access"
}

output "service_account_name" {
  description = "Name of the service account"
  value       = local.service_account_name
}

output "api_key_id" {
  value       = confluent_api_key.app.id
  description = "API Key ID"
}

output "api_key_secret" {
  value       = confluent_api_key.app.secret
  description = "API Key secret"
}

output "consumer_group" {
  value       = local.consumer_group
  description = "Name of the consumer group"
}

output "bootstrap_server" {
  value       = data.confluent_kafka_cluster.cluster.bootstrap_endpoint
  description = "Kafka Cluster Bootstrap Server"
}

output "rest_endpoint" {
  value       = data.confluent_kafka_cluster.cluster.rest_endpoint
  description = "Kafka Cluster Rest Endpoint"
}
