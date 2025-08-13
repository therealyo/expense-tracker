defmodule ExpenseTrackerWeb.ExpenseLive.Form do
  use ExpenseTrackerWeb, :live_view

  alias ExpenseTracker.Categories
  alias ExpenseTracker.Expenses
  alias ExpenseTracker.Expenses.Expense

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage expense records.</:subtitle>
      </.header>

      <.form for={@form} id="expense-form" phx-change="validate" phx-submit="save">
        <div class="space-y-6">
          <section class="rounded-lg border border-base-300 p-4">
            <h3 class="text-base font-semibold mb-4">Expense</h3>
            <div class="grid gap-4 md:grid-cols-2">
              <.input field={@form[:description]} type="text" label="Description" required />
              <.input field={@form[:amount]} type="text" label="Amount (USD)" required />
              <.input
                field={@form[:date]}
                value={@form[:date].value || now()}
                type="datetime-local"
                label="Date"
                required
              />
              <.input
                field={@form[:category_id]}
                type="select"
                label="Category"
                required
                options={@category_options}
              />
              <div class="md:col-span-2">
                <.input field={@form[:notes]} type="text" label="Notes (optional)" />
              </div>
            </div>
          </section>

          <footer class="flex gap-2">
            <.button phx-disable-with="Saving..." variant="primary">Save Expense</.button>
            <.button navigate={~p"/expenses"}>Cancel</.button>
          </footer>
        </div>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    {:ok,
     socket
     |> assign(:category_options, Categories.categories_select_options())
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    expense = Expenses.get_expense!(id)

    socket
    |> assign(:page_title, "Edit Expense")
    |> assign(:expense, expense)
    |> assign(:form, to_form(Expenses.change_expense(expense)))
  end

  defp apply_action(socket, :new, _params) do
    expense = %Expense{}

    socket
    |> assign(:page_title, "New Expense")
    |> assign(:expense, expense)
    |> assign(:form, to_form(Expenses.change_expense(expense)))
  end

  @impl true
  def handle_event("validate", %{"expense" => expense_params}, socket) do
    changeset = Expenses.change_expense(socket.assigns.expense, expense_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"expense" => expense_params}, socket) do
    save_expense(socket, socket.assigns.live_action, expense_params)
  end

  defp save_expense(socket, :edit, expense_params) do
    case Expenses.update_expense(socket.assigns.expense, expense_params) do
      {:ok, expense} ->
        {:noreply,
         socket
         |> put_flash(:info, "Expense updated successfully")
         |> push_navigate(to: ~p"/expenses/#{expense}")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_expense(socket, :new, expense_params) do
    case Expenses.create_expense(expense_params) do
      {:ok, expense} ->
        {:noreply,
         socket
         |> put_flash(:info, "Expense created successfully")
         |> push_navigate(to: ~p"/expenses/#{expense}")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp now(),
    do:
      NaiveDateTime.local_now()
      |> NaiveDateTime.to_string()
      |> String.replace(" ", "T")
end
