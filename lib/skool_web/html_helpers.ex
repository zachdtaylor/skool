defmodule SkoolWeb.HTMLHelpers do
  def format_date(date) do
    Calendar.strftime(date, "%b %d, %Y")
  end
end
