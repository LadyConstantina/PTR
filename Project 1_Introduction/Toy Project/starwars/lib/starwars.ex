defmodule StarWars do
  use Application
  require Logger

  @impl true
  def start(_type, _args) do
  Logger.info("Starting the SW App")
    children = [
      {Plug.Cowboy, scheme: :http, plug: StarWarsRoute,  options: [port: 8080]}
    ]

    opts = [strategy: :one_for_one, name: StarWarsSupervisor]
    StarWarsDB.start_link()
    Supervisor.start_link(children, opts)
  end

end

defmodule StarWarsDB do

  use Agent
  require Jason

  def start_link() do
    :ets.new(:star_wars_db, [:set, :public, :named_table])
    Agent.start_link(fn -> :ok end, name: __MODULE__)
    insert_json("movies.json")
  end

  def get_all() do
    table_contents =
      :ets.tab2list(:star_wars_db)
      |> Enum.into(%{}, fn {key, value} -> {key, value} end)
  end

  def insert_json(path) do
    contents = File.read!(path)
    json_list = Jason.decode!(contents)
    Enum.each(json_list, fn json ->
      id = Map.get(json, "id")
      :ets.insert(:star_wars_db, {id, json})
    end)
  end

  def get_json_data_by_key(key) do
    case :ets.lookup(:star_wars_db, key) do
      [{_, json}] -> json
      _ -> nil
    end
  end

  def insert_new_data(title, release_year, director) do
    list = :ets.tab2list(:star_wars_db)
    last_id = list
      |> Enum.max_by(&elem(&1, 0))
      |> elem(0)
    json = %{
              "title" => title,
              "release_year" => release_year,
              "id" => last_id + 1,
              "director" => director
            }
    :ets.insert(:star_wars_db, {last_id + 1, json})
  end

  def update_data(title, release_year, director, id) do
    case :ets.lookup(:star_wars_db, id) do
      [{_, _json}] ->
        new_json = %{
          "title" => title,
          "release_year" => release_year,
          "id" => id,
          "director" => director
        }
        :ets.insert(:star_wars_db, {id, new_json})
      _ -> nil
    end
  end

  def delete_data(id) do
    :ets.delete(:star_wars_db, id)
  end

end


defmodule StarWarsRoute do

  use Plug.Router
  require Jason
  require Logger

  plug(:match)
  plug(:dispatch)

  plug(Plug.Parsers,
  parsers: [:json],
  pass: ["application/json"],
  json_decoder:  Jason
  )

  get "/movies" do
    movie_list =
      StarWarsDB.get_all()
      |> Jason.encode_to_iodata!()
      |> Jason.Formatter.pretty_print()
    send_resp(conn, 200, movie_list)
  end

  get "/movies/:id" do
    movie =
      conn.path_params["id"]
      |> String.to_integer()
      |> StarWarsDB.get_json_data_by_key()
      |> Jason.encode_to_iodata!()
      |> Jason.Formatter.pretty_print()

      case movie do
        "null" ->
          conn
          |> send_resp(404, "Not found")
        movie ->
          conn
          |> send_resp(200, movie)
      end

  end

  post "/movies" do
    {:ok, body, conn} =
      conn
      |> Plug.Conn.read_body()
    {:ok,
     %{
       "title" => title,
       "release_year" => release_year,
       "director" => director
     }}
     = body
      |> Jason.decode()
    StarWarsDB.insert_new_data(title, release_year, director)
    send_resp(conn, 201, "OK")
  end

  put "/movies/:id" do
    id_new =
      conn.path_params["id"]
      |> String.to_integer()
    {:ok, body, conn} =
      conn
        |> Plug.Conn.read_body()
    {:ok,
     %{
       "title" => title,
       "id" => id,
       "release_year" => release_year,
       "director" => director
     }}
     = body
      |> Jason.decode()
    StarWarsDB.update_data(title, release_year, director, id_new)
    send_resp(conn, 200, "OK")
  end

  patch "/movies/:id" do
    id =
      conn.path_params["id"]
      |> String.to_integer()
    {:ok, body, conn} =
      conn
        |> Plug.Conn.read_body()
    {:ok,
     %{
       "title" => title,
       "id" => id,
       "release_year" => release_year,
       "director" => director
     }}
     = body
      |> Jason.decode()
    StarWarsDB.update_data(title, release_year, director, id)
    send_resp(conn, 200, "OK")
  end

  delete "/movies/:id" do
    id =
      conn.path_params["id"]
      |> String.to_integer()
      |> StarWarsDB.delete_data()
    send_resp(conn, 200, "OK")
  end

  match _ do
    send_resp(conn, 404, "Wrong address")
  end

end