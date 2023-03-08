defmodule Quotes do
  require HTTPoison
  require Floki
  require Jason


  def start() do
    HTTPoison.start()
    spawn(Quotes,:loop,[])
  end

  def loop() do
    receive do
      {:visit,link} -> request(link)
      {:scrap,link} -> IO.inspect(scrap(link))
      {:to_file,link} -> scrap_to_json(link)
    end
    loop()
  end

  def request(link) do
    response = HTTPoison.get!(link)
    IO.puts("Status code: #{response.status_code()}")
    IO.inspect(response.headers())
    IO.puts(response.body())
  end

  def scrap(link) do
    response = HTTPoison.get!(link)
    doc = Floki.parse(response.body())
    quotes = doc 
        |> Floki.find(".quote span.text ") 
        |> Enum.map(fn {"span", [{"class", "text"}, {"itemprop", "text"}], [text]} -> text end) 
        |> Enum.map(fn(s) -> String.slice(s,1,String.length(s)-2) end)
    authors = doc
        |> Floki.find("small.author")
        |> Enum.map(fn {"small", [{"class", "author"}, {"itemprop", "author"}], [text]} -> "by #{text}" end)
        
    tags = doc
        |> Floki.find("meta.keywords")
        |> Enum.map(fn {"meta",[ {"class", "keywords"},{"itemprop", "keywords"},{"content", tags}],[]} -> tags end)
        |> Enum.map(fn(s) -> String.split(s,",") end)

    list = quotes
        |> Enum.zip(authors)
        |> Enum.zip(tags)
        |> Enum.map(fn {{quotes,author},tags} -> %{quote: quotes, author: author, tags: tags} end)
        
    list
  end

  def scrap_to_json(link) do
    info = scrap(link)
        |> Jason.encode_to_iodata!()
        |> Jason.Formatter.pretty_print()
    File.write!("quotes.json",info)
  end
end
