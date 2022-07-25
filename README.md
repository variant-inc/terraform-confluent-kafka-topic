# Terraform Confluent Kafka Topic

## Confluent Provider Variables

Set the following environment variables
and it will be picked up by the provider

```shell
CONFLUENT_CLOUD_API_KEY
CONFLUENT_CLOUD_API_SECRET
KAFKA_API_KEY
KAFKA_API_SECRET
KAFKA_REST_ENDPOINT
```

## Topic Names

1. For existing, full name has to be provided.
2. For managed, a prefix is added to non-prod environments.

## Topic Permissions

1. `managed` topics has access to write.
2. `existing` topics has access to read by default.
3. To get write/produce access to existing topic, set `write_access=true`

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.1 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.0.0, < 5.0.0 |
| <a name="requirement_confluent"></a> [confluent](#requirement\_confluent) | ~> 1.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.0.0, < 5.0.0 |
| <a name="provider_confluent"></a> [confluent](#provider\_confluent) | ~> 1.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_ssm_parameter.topics](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [confluent_api_key.app](https://registry.terraform.io/providers/confluentinc/confluent/latest/docs/resources/api_key) | resource |
| [confluent_kafka_acl.app_consumer_read_on_group](https://registry.terraform.io/providers/confluentinc/confluent/latest/docs/resources/kafka_acl) | resource |
| [confluent_kafka_acl.app_consumer_read_on_topic](https://registry.terraform.io/providers/confluentinc/confluent/latest/docs/resources/kafka_acl) | resource |
| [confluent_kafka_acl.app_producer_write_on_existing_topic](https://registry.terraform.io/providers/confluentinc/confluent/latest/docs/resources/kafka_acl) | resource |
| [confluent_kafka_acl.app_producer_write_on_managed_topic](https://registry.terraform.io/providers/confluentinc/confluent/latest/docs/resources/kafka_acl) | resource |
| [confluent_kafka_topic.topics](https://registry.terraform.io/providers/confluentinc/confluent/latest/docs/resources/kafka_topic) | resource |
| [confluent_service_account.app](https://registry.terraform.io/providers/confluentinc/confluent/latest/docs/resources/service_account) | resource |
| [confluent_environment.environment](https://registry.terraform.io/providers/confluentinc/confluent/latest/docs/data-sources/environment) | data source |
| [confluent_kafka_cluster.cluster](https://registry.terraform.io/providers/confluentinc/confluent/latest/docs/data-sources/kafka_cluster) | data source |
| [confluent_kafka_topic.topics](https://registry.terraform.io/providers/confluentinc/confluent/latest/docs/data-sources/kafka_topic) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Confluent Kafka Cluster Name | `string` | n/a | yes |
| <a name="input_confluent_prefix"></a> [confluent\_prefix](#input\_confluent\_prefix) | Prefix of the Resources<br><br>  For non-prod, it is empty | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment where the cluster is located | `string` | n/a | yes |
| <a name="input_service_account_name"></a> [service\_account\_name](#input\_service\_account\_name) | Name of the service account | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags | `map(string)` | n/a | yes |
| <a name="input_topics"></a> [topics](#input\_topics) | List of Topics<br><br>1. For existing, full name has to be provided.<br>2. For managed, a prefix is added to non-prod environments.<br>3. To get write/produce access to existing topic, set `write_access=true` | <pre>object({<br>    managed = optional(list(object({<br>      name             = string<br>      partitions_count = optional(number)<br>      config           = optional(map(string))<br>    })))<br>    existing = optional(list(object({<br>      full_name    = string<br>      write_access = optional(bool)<br>    })))<br>  })</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_api_key_id"></a> [api\_key\_id](#output\_api\_key\_id) | API Key ID |
| <a name="output_api_key_secret"></a> [api\_key\_secret](#output\_api\_key\_secret) | API Key secret |
| <a name="output_bootstrap_server"></a> [bootstrap\_server](#output\_bootstrap\_server) | Kafka Cluster Bootstrap Server |
| <a name="output_consumer_group"></a> [consumer\_group](#output\_consumer\_group) | Name of the consumer group |
| <a name="output_read_topics"></a> [read\_topics](#output\_read\_topics) | Topics with Read Access |
| <a name="output_rest_endpoint"></a> [rest\_endpoint](#output\_rest\_endpoint) | Kafka Cluster Rest Endpoint |
| <a name="output_service_account_name"></a> [service\_account\_name](#output\_service\_account\_name) | Name of the service account |
| <a name="output_write_topics"></a> [write\_topics](#output\_write\_topics) | Topics with Write Access |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
