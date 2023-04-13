defmodule PublisherTweets do
  use Application
  require Logger

  @impl true
  def start(_type, _args) do
    Logger.info("Publisher Tweets started")
    MySuper.start_link()
  end
end