defmodule ExpenseTrackerWeb.CategoryLive.Show do
  use ExpenseTrackerWeb, :live_view

  alias ExpenseTracker.Categories

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Category {@category.name}
        <:subtitle>Overview and recent expenses.</:subtitle>
        <:actions>
          <.button navigate={~p"/categories"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/categories/#{@category}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit category
          </.button>
        </:actions>
      </.header>

      <div class="space-y-6">
        <section class="rounded-lg border border-base-300 p-4">
          <h3 class="text-base font-semibold mb-2">Summary</h3>
          <.list>
            <:item title="Name">{@category.name}</:item>
            <:item title="Description">{@category.description}</:item>
            <:item title="Monthly budget (cents)">{@category.monthly_budget}</:item>
            <:item title="Total spent (cents)">{@category.total_spent}</:item>
            <:item title="Spending %">
              {spending_percent(@category.total_spent, @category.monthly_budget)}%
            </:item>
          </.list>

          <.progress spent={@category.total_spent} budget={@category.monthly_budget} class="mt-4" />
        </section>

        <section class="rounded-lg border border-base-300 p-4">
          <h3 class="text-base font-semibold mb-4">Recent Expenses</h3>

          <div id="expenses" phx-update="stream">
            <div id="expenses-empty" class="hidden only:block" phx-update="ignore">
              No expenses yet
            </div>
            <div
              :for={{id, expense} <- @streams.expenses}
              id={id}
              class="border border-base-200 rounded-lg p-3 mb-2"
            >
              <div class="flex items-start justify-between">
                <div>
                  <div class="font-medium">{expense.description}</div>
                  <div class="text-sm opacity-80">
                    Amount: {expense.amount} • Date: {format_dt(expense.date)}
                    {if expense.notes && expense.notes != "", do: " • Notes: #{expense.notes}"}
                  </div>
                </div>
              </div>
            </div>
          </div>
        </section>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    category = Categories.get_category!(id)

    {:ok,
     socket
     |> assign(:page_title, "Show Category")
     |> assign(:category, category)
     |> stream(:expenses, category.expenses)}
  end

  defp spending_percent(_spent, budget) when budget in [nil, 0], do: 0

  defp spending_percent(spent, budget) do
    percent = trunc(spent * 100 / budget)
    if percent < 0, do: 0, else: percent
  end

  defp format_dt(nil), do: ""
  defp format_dt(dt), do: Calendar.strftime(dt, "%Y-%m-%d %H:%M")
end
