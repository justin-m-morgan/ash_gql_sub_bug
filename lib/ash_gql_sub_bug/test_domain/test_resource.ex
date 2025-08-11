defmodule AshGqlSubBug.TestDomain.TestResource do
  use Ash.Resource,
    otp_app: :ash_gql_sub_bug,
    domain: AshGqlSubBug.TestDomain,
    extensions: [AshGraphql.Resource],
    data_layer: AshPostgres.DataLayer

  postgres do
    table "test_resources"
    repo AshGqlSubBug.Repo
  end

  graphql do
    type :test_resource

    queries do
      list :test_resources, :read
    end

    mutations do
      create :test_resource, :create
    end

    subscriptions do
      pubsub AshGqlSubBugWeb.Endpoint
      subscribe :test_resource_created, action_types: [:create]
    end
  end

  actions do
    defaults [:read, :create]
    default_accept [:choice]
  end

  attributes do
    uuid_v7_primary_key :id
    attribute :choice, :my_enum, public?: true
  end
end
