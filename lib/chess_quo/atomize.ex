defmodule ChessQuo.Atomize do
  # Safely convert maps with string keys to atom keys (existing atoms only)
  def deep_atomize_keys_existing!(map) when is_map(map) do
    Enum.reduce(map, %{}, fn {k, v}, acc ->
      nk =
        if is_binary(k) do
          String.to_existing_atom(k)
        else
          k
        end

      nv = if is_map(v), do: deep_atomize_keys_existing!(v), else: v
      Map.put(acc, nk, nv)
    end)
  end
end
