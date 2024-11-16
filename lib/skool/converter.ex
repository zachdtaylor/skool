defmodule Skool.Converter do
  def to_ingeter(value) when is_binary(value), do: String.to_integer(value)
  def to_ingeter(value) when is_integer(value), do: value
end
