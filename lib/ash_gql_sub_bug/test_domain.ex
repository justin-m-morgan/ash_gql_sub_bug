defmodule AshGqlSubBug.TestDomain do
  use Ash.Domain, otp_app: :ash_gql_sub_bug, extensions: [AshGraphql.Domain]

  resources do
    resource AshGqlSubBug.TestDomain.TestResource
  end
end
