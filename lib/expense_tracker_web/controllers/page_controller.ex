defmodule ExpenseTrackerWeb.PageController do
  use ExpenseTrackerWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
