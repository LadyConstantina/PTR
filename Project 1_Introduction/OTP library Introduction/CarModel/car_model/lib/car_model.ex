defmodule CarModel do
  use Application
  require Logger

  def start(_args,_type) do
      Logger.info("Starting App")
      IO.puts("Starting")
      MainSupervisor.start_link()
  end

  def prep_stop(_state) do
    Logger.notice("Deploy Airbags!")
  end

end
