defmodule ExpenseTrackerWeb.CategoryLive.Index do
  alias ExpenseTracker.Expenses.Expense
  alias ExpenseTracker.Expenses
  use ExpenseTrackerWeb, :live_view

  alias ExpenseTracker.Categories

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Listing Categories
        <:actions>
          <.button variant="primary" navigate={~p"/categories/new"}>
            <.icon name="hero-plus" /> New Category
          </.button>
        </:actions>
      </.header>

      <.table
        id="categories"
        rows={@streams.categories}
        row_click={fn {_id, category} -> JS.navigate(~p"/categories/#{category}") end}
      >
        <:col :let={{_id, category}} label="Name">{category.name}</:col>
        <:col :let={{_id, category}} label="Description">{category.description}</:col>
        <:col :let={{_id, category}} label="Total Spent">
          {ExpenseTracker.Currencies.format_cents(category.total_spent, to_string(category.currency))}
        </:col>
        <:col :let={{_id, category}} label="Monthly budget">
          {ExpenseTracker.Currencies.format_cents(
            category.monthly_budget,
            to_string(category.currency)
          )}
        </:col>
        <:col :let={{_id, category}} label="Progress">
          <.progress
            spent={category.total_spent}
            budget={category.monthly_budget}
            currency={category.currency}
          />
        </:col>
        <:action :let={{_id, category}}>
          <div class="sr-only">
            <.link navigate={~p"/categories/#{category}"}>Show</.link>
          </div>
          <.link navigate={~p"/categories/#{category}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, category}}>
          <.link
            phx-click={JS.push("delete", value: %{id: category.id}) |> hide("##{id}")}
            data-confirm="Are you sure?"
          >
            Delete
          </.link>
        </:action>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Expenses.subscribe_to_changes()
    end

    {:ok,
     socket
     |> assign(:page_title, "Listing Categories")
     |> stream(:categories, Categories.list_categories())}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    category = Categories.get_category!(id)
    {:ok, _} = Categories.delete_category(category)

    {:noreply, stream_delete(socket, :categories, category)}
  end

  @impl true
  def handle_info({:expense_created, %Expense{} = expense}, socket) do
    updated_category = Categories.get_category!(expense.category_id)
    {:noreply, stream_insert(socket, :categories, updated_category)}
  end

  @impl true
  def handle_info({:expense_updated, %Expense{} = expense}, socket) do
    updated_category = Categories.get_category!(expense.category_id)
    {:noreply, stream_insert(socket, :categories, updated_category)}
  end
end
