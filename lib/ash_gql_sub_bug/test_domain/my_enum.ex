defmodule AshGqlSubBug.TestDomain.MyEnum do
  use Ash.Type.Enum, values: [:a, :b, :c]

  def graphql_type(_), do: :my_enum
end
