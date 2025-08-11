defmodule AshGqlSubBug.Repo do
  use Ecto.Repo,
    otp_app: :ash_gql_sub_bug,
    adapter: Ecto.Adapters.Postgres
end
