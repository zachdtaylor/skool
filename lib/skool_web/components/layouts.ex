defmodule SkoolWeb.Layouts do
  use SkoolWeb, :html

  embed_templates "layouts/*"

  attr :icon, :string, doc: "The name of the icon to render"
  attr :text, :string, doc: "The text to render"
  attr :href, :string, doc: "The href to link to"
  attr :method, :string, doc: "The method to use for the link", default: "get"

  defp app_nav_link(assigns) do
    ~H"""
    <li class="p-2 grid grid-cols-[min-content_1fr] items-center gap-x-2 hover:bg-white transition-colors duration-300">
      <.icon name={@icon} class="text-zinc-900" />
      <.link
        class="text-[0.8125rem] leading-6 text-zinc-900 font-semibold"
        navigate={@href}
        method={@method}
      >
        <%= @text %>
      </.link>
    </li>
    """
  end
end
