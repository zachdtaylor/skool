defmodule SkoolWeb.AssignmentLive.Helpers do
  alias Skool.Courses.Assignment

  import SkoolWeb.HTMLHelpers, only: [day_of_week: 1]

  def kinds, do: Ecto.Enum.mappings(Assignment, :kind)

  def repeats_every_units,
    do: [Day: :day, Week: :week, Month: :month, Year: :year]

  def repeats_ons(:week),
    do: [
      Monday: :monday,
      Tuesday: :tuesday,
      Wednesday: :wednesday,
      Thursday: :thursday,
      Friday: :friday,
      Saturday: :saturday,
      Sunday: :sunday
    ]

  def repeats_ons(:month, start_date) do
    day_of_week = day_of_week(start_date)

    week_of_month = (start_date.day / 7) |> Float.ceil() |> trunc()

    additional_options =
      case week_of_month do
        1 -> [{"First #{day_of_week}", "first"}]
        2 -> [{"Second #{day_of_week}", "second"}]
        3 -> [{"Third #{day_of_week}", "third"}]
        4 -> [{"Fourth #{day_of_week}", "fourth"}, {"Last #{day_of_week}", "last"}]
        5 -> [{"Last #{day_of_week}", "last"}]
      end

    [{"Day #{start_date.day}", "day"} | additional_options]
  end

  def transform_repeats_on(params) do
    case Map.get(params, "repeats_on", nil) do
      nil ->
        params

      repeats_on when is_list(repeats_on) ->
        Map.put(params, "repeats_on", Enum.join(repeats_on, "."))

      _ ->
        params
    end
  end
end
