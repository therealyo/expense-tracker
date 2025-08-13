defmodule ExpenseTracker.CurrenciesTest do
  use ExUnit.Case, async: true
  alias ExpenseTracker.Currencies

  test "format cents USD" do
    assert Currencies.format_cents(0, "USD") == "$0.00"
    assert Currencies.format_cents(12345, "USD") == "$123.45"
    assert Currencies.format_cents(-205, "USD") == "-$2.05"
  end

  test "parse dollars to cents" do
    assert {:ok, 0} = Currencies.parse_dollars_to_cents("$0")
    assert {:ok, 12345} = Currencies.parse_dollars_to_cents("123.45")
    assert {:ok, 199} = Currencies.parse_dollars_to_cents("1.99")
    assert {:ok, 9900} = Currencies.parse_dollars_to_cents("99.")
    assert {:ok, 0} = Currencies.parse_dollars_to_cents("")
  end

  test "normalize_money/2" do
    assert %{"amount" => 123} = Currencies.normalize_money(%{"amount" => "1.23"}, "amount")
    assert %{"amount" => 123} = Currencies.normalize_money(%{"amount" => "1.23"}, :amount)
    assert %{amount: 123} = Currencies.normalize_money(%{amount: "1.23"}, :amount)
    assert %{amount: 123} = Currencies.normalize_money(%{amount: "1.23"}, "amount")
  end
end
