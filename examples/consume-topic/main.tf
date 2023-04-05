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

  environment      = "enterprise"
  confluent_prefix = "dev"
  cluster_name     = "non-prod"

  service_account_name = "some-name"

  topics = {
    existing = [
      {
        full_name = "dev.Event.Trailers"
      },
      {
        full_name = "dev.DataChange.Trailers"
      }
    ]
  }

  tags = module.tags.tags
}
