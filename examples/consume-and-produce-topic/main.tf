module "tags" {
  source = "github.com/variant-inc/lazy-terraform//submodules/tags?ref=v1"

  user_tags = {
    team    = "devops"
    purpose = "elk module test"
    owner   = "Samir"
  }
  octopus_tags = {
    project         = "actions-test"
    space           = "Default"
    environment     = "development"
    project_group   = "Default Project Group"
    release_channel = "feature"
  }

  name = "Test"
}

module "topics" {
  source = "../../"

  environment  = "enterprise"
  topic_prefix = "dev"
  cluster_name = "non-prod"

  service_account_name = "some-name"

  topics = {
    produce = [
      {
        name             = "test"
        partitions_count = 2
      },
      {
        name = "test1"
      },
      {
        name = "test2"
        config = {
          "max.message.bytes" = "12345"
        }
      }
    ]
    consume = [
      {
        name = "dev-test"
      },
      {
        name = "dev-test1"
      }
    ]
  }

  tags = module.tags.tags
}
