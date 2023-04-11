defmodule Project2 do
  use Application

  @impl true
  def start(_type, _args) do
    MySuper.start_link()
  end
end