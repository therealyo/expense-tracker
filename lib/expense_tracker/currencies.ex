defmodule ExpenseTracker.Currencies do
  @moduledoc """
  Currency helpers. Amounts are stored as integer cents.
  """

  @available_currencies ~w(USD)a

  def available_currencies(), do: @available_currencies

  @type currency :: String.t()

  @spec default_currency() :: currency
  def default_currency, do: "USD"

  @spec format_cents(integer | nil, currency) :: String.t()
  def format_cents(nil, _currency), do: "$0.00"

  def format_cents(cents, currency) when is_integer(cents) do
    sign = if cents < 0, do: "-", else: ""
    abs = abs(cents)
    dollars = div(abs, 100)
    rem2 = rem(abs, 100) |> Integer.to_string() |> String.pad_leading(2, "0")

    case currency do
      "USD" -> "#{sign}$#{dollars}.#{rem2}"
      _ -> "#{sign}#{dollars}.#{rem2} #{currency}"
    end
  end

  @spec parse_dollars_to_cents(String.t()) :: {:ok, integer} | {:error, :invalid}
  def parse_dollars_to_cents(input) when is_binary(input) do
    s = input |> String.trim() |> String.replace(",", "")
    sign = if String.starts_with?(s, "-"), do: -1, else: 1
    s = if sign == -1, do: String.trim_leading(s, "-"), else: s
    s = String.trim_leading(s, "$")

    cond do
      s == "" ->
        {:ok, 0}

      Regex.match?(~r/^\d+$/, s) ->
        {:ok, sign * String.to_integer(s) * 100}

      Regex.match?(~r/^\d+\.$/, s) ->
        {:ok, sign * String.to_integer(String.trim_trailing(s, ".")) * 100}

      Regex.match?(~r/^\.\d{1,2}$/, s) ->
        cents =
          s |> String.trim_leading(".") |> String.pad_trailing(2, "0") |> String.to_integer()

        {:ok, sign * cents}

      Regex.match?(~r/^\d+\.\d{1,2}$/, s) ->
        [d, c] = String.split(s, ".")

        cents =
          String.to_integer(d) * 100 + (c |> String.pad_trailing(2, "0") |> String.to_integer())

        {:ok, sign * cents}

      true ->
        {:error, :invalid}
    end
  end

  @spec valid_currency?(currency) :: boolean
  def valid_currency?(cur) when is_binary(cur),
    do: cur in Enum.map(@available_currencies, &to_string/1)

  def valid_currency?(_), do: false

  def normalize_money(%{} = attrs, key) when is_atom(key) do
    case Map.fetch(attrs, Atom.to_string(key)) do
      {:ok, v} when is_binary(v) ->
        case parse_dollars_to_cents(v) do
          {:ok, cents} -> Map.put(attrs, key, cents)
          {:error, _} -> attrs
        end

      _ ->
        attrs
    end
  end

  def normalize_money(%{} = attrs, key) when is_binary(key) do
    case Map.fetch(attrs, key) do
      {:ok, v} when is_binary(v) ->
        case parse_dollars_to_cents(v) do
          {:ok, cents} ->
            Map.put(attrs, key, cents)

          {:error, _} ->
            attrs
        end

      _ ->
        attrs
    end
  end
end
