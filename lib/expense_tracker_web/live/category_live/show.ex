defmodule ExpenseTrackerWeb.CategoryLive.Show do
  use ExpenseTrackerWeb, :live_view

  alias ExpenseTracker.Categories

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Category {@category.id}
        <:subtitle>This is a category record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/categories"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/categories/#{@category}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit category
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Name">{@category.name}</:item>
        <:item title="Description">{@category.description}</:item>
        <:item title="Monthly budget">{@category.monthly_budget}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Show Category")
     |> assign(:category, Categories.get_category!(id))}
  end
end
