defmodule Skool.DateHelpers do
  @moduledoc """
  Date helper functions.
  """

  alias Skool.Accounts.User

  @doc """
  Returns the current date in the user's preferred timezone.
  """
  @spec today(User.t()) :: Date.t()
  def today(%User{} = user) do
    DateTime.utc_now()
    |> DateTime.shift_zone!(user.preferred_timezone, Tz.TimeZoneDatabase)
    |> DateTime.to_date()
  end

  @doc """
  This function is used for building the calendar grid.

  Given row and column indexes in the calendar grid and the day of the week
  for the first of the month, determine the day of the month that should go
  in that cell.

  ## Assumptions

  - The row and column indexes are 0-based.
  - The day of the week for the first of the month is 1-based, with 1 being
    Sunday and 7 being Saturday. See `Date.day_of_week/1` for more information.
    So in November 2024, for example, the first of the month is a Friday, so
    `first_of_month_day_of_week` would be 6.

  ## Examples

        iex> day_of_month(0, 0, 1)
        1
        iex> day_of_month(1, 0, 1)
        8
        iex> day_of_month(0, 5, 6)
        1
        iex> day_of_month(0, 4, 6)
        -1
  """
  @spec day_of_month(integer(), integer(), integer()) :: integer()
  def day_of_month(0, column, first_of_month_day_of_week) do
    column - first_of_month_day_of_week + 2
  end

  def day_of_month(row, column, first_of_month_day_of_week) do
    day_of_month(0, column, first_of_month_day_of_week) + row * 7
  end
end
