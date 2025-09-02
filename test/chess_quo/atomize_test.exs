defmodule ChessQuo.AtomizeTest do
  use ExUnit.Case, async: true

  describe "deep_atomize_keys_existing!/1" do
    test "atomizes a shallow map" do
      input = %{"key1" => "value1", "key2" => "value2"}
      expected = %{key1: "value1", key2: "value2"}
      assert ChessQuo.Atomize.deep_atomize_keys_existing!(input) == expected
    end

    test "atomizes a nested map" do
      input = %{"outer_key" => %{"inner_key" => "inner_value"}}
      expected = %{outer_key: %{inner_key: "inner_value"}}
      assert ChessQuo.Atomize.deep_atomize_keys_existing!(input) == expected
    end

    test "atomizes a shallow map with mixed keys" do
      input = %{"string_key" => "value", :atom_key => "value"}
      expected = %{string_key: "value", atom_key: "value"}
      assert ChessQuo.Atomize.deep_atomize_keys_existing!(input) == expected
    end

    test "atomizes a nested map with mixed keys" do
      input = %{"outer_key" => %{"inner_key" => "inner_value", :atom_key => "value"}}
      expected = %{outer_key: %{inner_key: "inner_value", atom_key: "value"}}
      assert ChessQuo.Atomize.deep_atomize_keys_existing!(input) == expected
    end

    test "atomizes a deeply nested map with mixed keys" do
      input = %{
        "outer_key" => %{"inner_key" => %{"deep_key" => "deep_value", :atom_key => "value"}},
        outer_key_atom: %{"inner_key" => %{"deep_key" => "deep_value", :atom_key => "value"}}
      }

      expected = %{
        outer_key: %{inner_key: %{deep_key: "deep_value", atom_key: "value"}},
        outer_key_atom: %{inner_key: %{deep_key: "deep_value", atom_key: "value"}}
      }

      assert ChessQuo.Atomize.deep_atomize_keys_existing!(input) == expected
    end
  end
end
