defmodule SkoolWeb.Layouts do
  use SkoolWeb, :html

  embed_templates "layouts/*"

  attr :active?, :boolean, doc: "Whether the nav link is active", default: false
  attr :class, :string, doc: "Additional classes to apply to the nav link", default: ""
  attr :icon, :string, doc: "The name of the icon to render"
  attr :text, :string, doc: "The text to render"
  attr :href, :string, doc: "The href to link to"
  attr :navigate, :string, doc: "The path to navigate to"
  attr :method, :string, doc: "The method to use for the link", default: "get"

  defp app_nav_link(assigns) do
    ~H"""
    <li class={[
      "px-2 grid grid-cols-[min-content_1fr] items-center gap-x-2 hover:bg-white",
      "border-b border-b-solid border-b-slate-200 transition-colors duration-300",
      "rounded-sm md:border-b-0",
      @active? && "bg-white"
    ]}>
      <.icon name={@icon} class="text-zinc-900" />
      <.link
        class="text-[0.8125rem] leading-6 text-zinc-900 font-semibold py-4 md:py-2"
        navigate={if assigns[:navigate], do: @navigate}
        href={if assigns[:href], do: @href}
        method={@method}
      >
        <%= @text %>
      </.link>
    </li>
    """
  end
end
