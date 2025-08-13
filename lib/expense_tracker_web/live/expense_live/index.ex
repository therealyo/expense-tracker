defmodule ExpenseTrackerWeb.ExpenseLive.Index do
  alias ExpenseTracker.Expenses
  use ExpenseTrackerWeb, :live_view

  alias ExpenseTracker.Expenses

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Expenses
        <:actions>
          <.button variant="primary" navigate={~p"/expenses/new"}>
            <.icon name="hero-plus" /> New Expense
          </.button>
        </:actions>
      </.header>

      <.table
        id="expenses"
        rows={@streams.expenses}
        row_click={fn {_id, expense} -> JS.navigate(~p"/expenses/#{expense}") end}
        row_id={fn {id, _} -> id end}
      >
        <:col :let={{_id, expense}} label="Description">{expense.description}</:col>
        <:col :let={{_id, expense}} label="Amount">
          {ExpenseTracker.Currencies.format_cents(expense.amount, to_string(expense.currency))}
        </:col>
        <:col :let={{_id, expense}} label="Date">{format_dt(expense.date)}</:col>
        <:col :let={{_id, expense}} label="Category">
          {expense.category && expense.category.name}
        </:col>
        <:action :let={{_id, expense}}>
          <div class="sr-only">
            <.link navigate={~p"/expenses/#{expense}"}>Show</.link>
          </div>
          <.link navigate={~p"/expenses/#{expense}/edit"}>Edit</.link>
        </:action>
        <:action :let={{_id, expense}}>
          <.link
            phx-click={JS.push("delete", value: %{"id" => expense.id})}
            data-confirm="Delete this expense?"
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
    expenses = Expenses.list_expenses()

    {:ok,
     socket
     |> assign(:page_title, "Listing Expenses")
     |> stream(:expenses, expenses)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    expense = Expenses.get_expense!(id)
    {:ok, _} = Expenses.delete_expense(expense)

    {:noreply, stream_delete(socket, :expenses, expense)}
  end

  defp format_dt(nil), do: ""
  defp format_dt(dt), do: Calendar.strftime(dt, "%Y-%m-%d %H:%M")
end
