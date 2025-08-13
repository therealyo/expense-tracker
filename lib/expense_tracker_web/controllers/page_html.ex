defmodule ExpenseTrackerWeb.PageHTML do
  @moduledoc """
  This module contains pages rendered by PageController.

  See the `page_html` directory for all templates available.
  """
  use ExpenseTrackerWeb, :html

  embed_templates "page_html/*"

  defp format_dt(nil), do: ""
  defp format_dt(dt), do: Calendar.strftime(dt, "%Y-%m-%d %H:%M")
end
