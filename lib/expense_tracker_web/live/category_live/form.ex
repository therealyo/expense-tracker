defmodule ExpenseTrackerWeb.CategoryLive.Form do
  use ExpenseTrackerWeb, :live_view

  alias ExpenseTracker.Categories
  alias ExpenseTracker.Categories.Category

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage category records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="category-form" phx-change="validate" phx-submit="save">
        <div class="space-y-6">
          <section class="rounded-lg border border-base-300 p-4">
            <h3 class="text-base font-semibold mb-4">Category</h3>
            <div class="grid gap-4 md:grid-cols-2">
              <.input field={@form[:name]} type="text" label="Name" required />
              <.input
                field={@form[:monthly_budget]}
                type="text"
                label="Monthly Budget (USD)"
                required
              />
              <div class="md:col-span-2">
                <.input field={@form[:description]} type="text" label="Description" required />
              </div>
            </div>
          </section>

          <section class="rounded-lg border border-base-300 p-4">
            <div class="flex items-center justify-between mb-4">
              <h3 class="text-base font-semibold">Expenses</h3>
              <button
                type="button"
                class="btn btn-sm btn-outline"
                name="category[expenses_sort][]"
                value="new"
                phx-click={JS.dispatch("change")}
              >
                <.icon name="hero-plus" class="w-5 h-5" /> Add Expense
              </button>
            </div>

            <div class="space-y-4">
              <.inputs_for :let={expense_f} field={@form[:expenses]}>
                <div class="rounded-lg border border-base-200 p-4">
                  <div class="grid gap-4 md:grid-cols-4">
                    <input type="hidden" name={expense_f[:id].name} value={expense_f[:id].value} />
                    <.input field={expense_f[:description]} type="text" label="Description" required />
                    <.input
                      field={expense_f[:amount]}
                      type="number"
                      label="Amount (cents)"
                      step="1"
                      required
                    />
                    <.input
                      field={expense_f[:date]}
                      value={expense_f[:date].value || now()}
                      type="datetime-local"
                      label="Date"
                      required
                    />
                    <.input field={expense_f[:notes]} type="text" label="Notes (optional)" />
                  </div>
                  <div class="mt-3 flex justify-end">
                    <button
                      type="button"
                      class="btn btn-sm btn-ghost text-error"
                      name="category[expenses_drop][]"
                      value={expense_f.index}
                      phx-click={JS.dispatch("change")}
                      aria-="Remove expense"
                    >
                      <.icon name="hero-x-mark" class="w-5 h-5" /> Remove
                    </button>
                  </div>
                </div>
              </.inputs_for>
            </div>
          </section>

          <footer class="flex gap-2">
            <.button phx-disable-with="Saving..." variant="primary">Save Category</.button>
            <.button navigate={return_path(@return_to, @category)}>Cancel</.button>
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
     |> assign(:return_to, return_to(params["return_to"]))
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  defp apply_action(socket, :edit, %{"id" => id}) do
    category = Categories.get_category!(id)

    socket
    |> assign(:page_title, "Edit Category")
    |> assign(:category, category)
    |> assign(:form, to_form(Categories.change_category(category)))
  end

  defp apply_action(socket, :new, _params) do
    category = %Category{}

    socket
    |> assign(:page_title, "New Category")
    |> assign(:category, category)
    |> assign(:form, to_form(Categories.change_category(category)))
  end

  @impl true
  def handle_event("validate", %{"category" => category_params}, socket) do
    changeset = Categories.change_category(socket.assigns.category, category_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"category" => category_params}, socket) do
    save_category(socket, socket.assigns.live_action, category_params)
  end

  defp save_category(socket, :edit, category_params) do
    case Categories.update_category(socket.assigns.category, category_params) do
      {:ok, category} ->
        {:noreply,
         socket
         |> put_flash(:info, "Category updated successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, category))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_category(socket, :new, category_params) do
    case Categories.create_category(category_params) do
      {:ok, category} ->
        {:noreply,
         socket
         |> put_flash(:info, "Category created successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, category))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path("index", _category), do: ~p"/categories"
  defp return_path("show", category), do: ~p"/categories/#{category}"

  defp now(),
    do:
      NaiveDateTime.local_now()
      |> NaiveDateTime.to_string()
      |> String.replace(" ", "T")
end
