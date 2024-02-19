defmodule Skool.DateHelpers do
  @moduledoc """
  Date helper functions.
  """

  alias Skool.Accounts.User

  @spec today(User.t()) :: Date.t()
  def today(%User{} = user) do
    DateTime.utc_now()
    |> DateTime.shift_zone!(user.preferred_timezone, Tz.TimeZoneDatabase)
    |> DateTime.to_date()
  end
end
