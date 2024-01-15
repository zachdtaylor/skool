defmodule SkoolWeb.HTMLHelpers do
  alias Skool.Courses.Assignment

  def format_date(date) do
    Calendar.strftime(date, "%b %d, %Y")
  end

  def capitalize(atom) when is_atom(atom) do
    atom
    |> Atom.to_string()
    |> String.capitalize()
  end

  def format_interval(%Assignment{recurrance_interval: nil, recurrance_unit: nil}), do: nil

  def format_interval(%Assignment{recurrance_interval: recurrance_interval} = assignment)
      when recurrance_interval <= 0.5 do
    "#{round_to(1 / recurrance_interval, 2)} times per #{assignment.recurrance_unit}"
  end

  def format_interval(%Assignment{} = assignment) do
    "Every #{round_to(assignment.recurrance_interval, 2)} #{assignment.recurrance_unit}(s)"
  end

  def round_to(number, places) when is_float(number) and is_integer(places) do
    number
    |> Decimal.from_float()
    |> Decimal.round(places)
  end
end
