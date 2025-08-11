defmodule AshGqlSubBugWeb.Gql.Subscriptions.NewTestResourceTest do
  alias AshGqlSubBug.TestDomain.MyEnum
  # The default endpoint for testing
  @endpoint AshGqlSubBugWeb.Endpoint

  use AshGqlSubBugWeb.ConnCase, async: true
  use Absinthe.Phoenix.SubscriptionTest, schema: AshGqlSubBugWeb.GraphqlSchema

  import Phoenix.ChannelTest

  describe "new_test_resource (subscription)" do
    setup do
      {:ok, socket} = Phoenix.ChannelTest.connect(AshGqlSubBugWeb.GraphqlSocket, %{})
      {:ok, socket} = Absinthe.Phoenix.SubscriptionTest.join_absinthe(socket)

      {:ok, %{socket: socket}}
    end

    test "receives an event for each option", %{
      socket: socket
    } do
      variables = %{filter: %{}}
      subscription_id = subscribe(socket, %{variables: variables})

      MyEnum.values()
      |> Enum.each(fn option ->
        created_resource = create_test_resource!(option)

        %{id: id, choice: choice} = created_resource
        choice = choice |> to_string() |> String.upcase()

        expected_payload = %{data: data_payload(%{"id" => id, "choice" => choice})}

        assert_subscription_message(subscription_id, expected_payload)
      end)
    end

    test "filter allows specific choices", %{
      socket: socket
    } do
      variables = %{
        filter: %{
          choice: %{
            in: ["A", "B"]
          }
        }
      }

      subscription_id = subscribe(socket, %{variables: variables})

      assert ["A", "B"]
             |> Enum.each(fn option ->
               created_resource = create_test_resource!(option)

               %{id: id} = created_resource

               expected_payload = %{data: data_payload(%{"id" => id, "choice" => option})}
               assert_subscription_message(subscription_id, expected_payload)
             end)
    end

    test "filter should result in no event being received", %{
      socket: socket
    } do
      variables = %{
        filter: %{
          choice: %{
            in: ["A", "B"]
          }
        }
      }

      subscription_id = subscribe(socket, %{variables: variables})

      create_test_resource!("C")

      refute_subscription_message(subscription_id)
    end
  end

  defp subscribe(socket, options) do
    ref = push_doc(socket, subscription(), options)
    assert_reply(ref, :ok, %{subscriptionId: subscription_id})

    subscription_id
  end

  defp create_test_resource!(choice) do
    Ash.create!(AshGqlSubBug.TestDomain.TestResource, %{choice: choice})
  end

  defp subscription() do
    """
    subscription($filter: TestResourceFilterInput) {
      testResourceCreated(filter:$filter) {
        created {
          id
          choice
        }
      }
    }
    """
  end

  def assert_subscription_message(subscription_id, result) do
    assert_push(
      "subscription:data",
      %{
        subscriptionId: ^subscription_id,
        result: ^result
      }
    )
  end

  def refute_subscription_message(subscription_id) do
    refute_push(
      "subscription:data",
      %{
        subscriptionId: ^subscription_id
      }
    )
  end

  defp data_payload(payload) do
    %{
      "testResourceCreated" => %{
        "created" => payload
      }
    }
  end
end
