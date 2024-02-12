defmodule SkoolWeb.HTMLHelpers do
  alias Skool.Courses.Assignment

  def day_of_week(date) do
    date
    |> Date.day_of_week()
    |> case do
      1 -> "Monday"
      2 -> "Tuesday"
      3 -> "Wednesday"
      4 -> "Thursday"
      5 -> "Friday"
      6 -> "Saturday"
      7 -> "Sunday"
    end
  end

  def display_repeats(%Assignment{kind: kind}) when kind != :recurring,
    do: ""

  def display_repeats(%Assignment{repeats_every_unit: unit} = assignment)
      when unit == :day or unit == :year,
      do: display_repeats_every(assignment)

  def display_repeats(%Assignment{repeats_every_unit: :week} = assignment) do
    display_repeats_every(assignment) <> " on " <> display_repeats_on(assignment)
  end

  def display_repeats(%Assignment{repeats_every_unit: :month} = assignment) do
    display_repeats_every(assignment) <> " on the " <> display_repeats_on(assignment)
  end

  defp display_repeats_every(%Assignment{} = assignment) do
    if assignment.repeats_every == 1 do
      "Every #{assignment.repeats_every_unit}"
    else
      "Every #{assignment.repeats_every} #{assignment.repeats_every_unit}s"
    end
  end

  defp display_repeats_on(%Assignment{repeats_every_unit: :week} = assignment) do
    assignment.repeats_on
    |> String.split(".")
    |> Enum.map(&String.capitalize/1)
    |> Enum.join(", ")
  end

  defp display_repeats_on(%Assignment{repeats_every_unit: :month} = assignment) do
    "#{assignment.repeats_on} #{day_of_week(assignment.start_date)}"
  end

  def format_date(nil), do: nil
  def format_date(date), do: Calendar.strftime(date, "%b %d, %Y")

  def capitalize(atom) when is_atom(atom) do
    atom
    |> Atom.to_string()
    |> String.capitalize()
  end

  def format_interval(%Assignment{repeats_every: nil, repeats_every_unit: nil}), do: nil

  def format_interval(%Assignment{} = assignment) do
    "Every #{assignment.repeats_every} #{assignment.repeats_every_unit}(s)"
  end

  def round_to(number, places) when is_float(number) and is_integer(places) do
    number
    |> Decimal.from_float()
    |> Decimal.round(places)
  end
end
