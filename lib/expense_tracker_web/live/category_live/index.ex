defmodule ExpenseTrackerWeb.CategoryLive.Index do
  use ExpenseTrackerWeb, :live_view

  alias ExpenseTracker.Categories

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Listing Categories
        <:actions>
          <.button type="button" onclick="quick_add_expense_modal.showModal()">
            Quick Add Expense
          </.button>
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
        <:col :let={{_id, category}} label="Total Spent">{category.total_spent}</:col>
        <:col :let={{_id, category}} label="Monthly budget">{category.monthly_budget}</:col>
        <:col :let={{_id, category}} label="Progress">
          <.progress spent={category.total_spent} budget={category.monthly_budget} />
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

      <dialog
        id="quick_add_expense_modal"
        class="modal"
        phx-mounted={JS.ignore_attributes(["open"])}
      >
        <div class="modal-box">
          <h3 class="text-lg font-bold">Add Expense</h3>
          <.button type="button" phx-click="edit_strategy">Confirm</.button>
          <.button type="button" onclick="quick_add_expense_modal.close()">
            Close
          </.button>
        </div>
      </dialog>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
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
end
