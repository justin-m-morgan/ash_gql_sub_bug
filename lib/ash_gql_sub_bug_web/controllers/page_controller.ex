defmodule AshGqlSubBugWeb.PageController do
  use AshGqlSubBugWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
