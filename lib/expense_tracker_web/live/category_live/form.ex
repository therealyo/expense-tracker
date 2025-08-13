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
        <.input field={@form[:name]} type="text" label="Name" required />
        <.input field={@form[:description]} type="text" label="Description" required />
        <.input field={@form[:monthly_budget]} type="number" label="Monthly budget" required />

        <section>
          <.inputs_for :let={expense_f} field={@form[:expenses]}>
            <.input field={expense_f[:description]} type="text" label="Description" required />
            <.input field={expense_f[:amount]} type="number" label="Amount" step="any" required />
            <.input field={expense_f[:date]} type="datetime-local" label="Date" required />
            <.input field={expense_f[:notes]} type="text" label="Notes(Optional)" />
            <button
              type="button"
              name="category[expenses_drop][]"
              value={expense_f.index}
              phx-click={JS.dispatch("change")}
            >
              <.icon name="hero-x-mark" class="w-6 h-6 relative top-2" />
            </button>
          </.inputs_for>

          <button
            type="button"
            name="category[expenses_sort][]"
            value="new"
            phx-click={JS.dispatch("change")}
          >
            Add Expense
          </button>
        </section>
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Category</.button>
          <.button navigate={return_path(@return_to, @category)}>Cancel</.button>
        </footer>
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
end
