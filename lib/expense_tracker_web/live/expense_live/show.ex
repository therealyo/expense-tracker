defmodule ExpenseTrackerWeb.ExpenseLive.Show do
  alias ExpenseTracker.Expenses
  use ExpenseTrackerWeb, :live_view

  alias ExpenseTracker.Expenses

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Expense {@expense.id}
        <:subtitle>Details for this expense.</:subtitle>
        <:actions>
          <.button navigate={~p"/expenses"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/expenses/#{@expense}/edit"}>
            <.icon name="hero-pencil-square" /> Edit expense
          </.button>
        </:actions>
      </.header>

      <section class="rounded-lg border border-base-300 p-4">
        <.list>
          <:item title="Description">{@expense.description}</:item>
          <:item title="Amount (cents)">{@expense.amount}</:item>
          <:item title="Date">{format_dt(@expense.date)}</:item>
          <:item title="Notes">{@expense.notes}</:item>

          <:item title="Category">
            <.link
              navigate={~p"/categories/#{@expense.category}"}
              class="underline underline-offset-2
    hover:no-underline"
            >
              {@expense.category.name}
            </.link>
          </:item>
        </.list>
      </section>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    expense = Expenses.get_expense!(id)

    {:ok,
     socket
     |> assign(:page_title, "Show Expense")
     |> assign(:expense, expense)}
  end

  defp format_dt(nil), do: ""
  defp format_dt(dt), do: Calendar.strftime(dt, "%Y-%m-%d %H:%M")
end
