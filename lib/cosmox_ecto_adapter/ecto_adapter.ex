defmodule CosmoxEctoAdapter.EctoAdapter do
  @moduledoc """
  Implements the Ecto.Adapter behaviour for Cosmox.
  """

  @behaviour Ecto.Adapter
  @behaviour Ecto.Adapter.Storage
  @behaviour Ecto.Adapter.Schema
  @behaviour Ecto.Adapter.Queryable

  ## Adapter

  @doc false
  @impl true
  defmacro __before_compile__(_env) do
  end

  @doc """
  Initialises the Cosmos connection.
  """
  @impl true
  def init(_config) do
    {:ok, [
      %{
        id: Cosmox.Application,
        start: {Cosmox.Application, :start, [nil, nil]}
      }
    ], %{}}
  end

  @doc false
  @impl true
  def ensure_all_started(_config, _type) do
    # TODO
    true
  end

  @impl true
  def loaders(:time, type), do: [&load_time/1, type]
  def loaders(:date, type), do: [&load_date/1, type]
  def loaders(:utc_datetime, type), do: [&load_datetime/1, type]
  def loaders(:utc_datetime_usec, type), do: [&load_datetime/1, type]
  def loaders(:naive_datetime, type), do: [&load_datetime/1, type]
  def loaders(:naive_datetime_usec, type), do: [&load_datetime/1, type]
  def loaders(:integer, type), do: [&load_integer/1, type]

  def loaders(_base, type) do
    [type]
  end

  defp load_time(time), do: time

  defp load_date(date) do
    {:ok, date |> DateTime.to_date()}
  end

  defp load_datetime(datetime) do
    {:ok, datetime}
  end

  defp load_integer(map) do
    {:ok, map}
  end

  @impl true
  def dumpers(:time, type), do: [type, &dump_time/1]
  def dumpers(:date, type), do: [type, &dump_date/1]
  def dumpers(:utc_datetime, type), do: [type, &dump_utc_datetime/1]
  def dumpers(:utc_datetime_usec, type), do: [type, &dump_utc_datetime/1]
  def dumpers(:naive_datetime, type), do: [type, &dump_naive_datetime/1]
  def dumpers(:naive_datetime_usec, type), do: [type, &dump_naive_datetime/1]
  def dumpers(_base, type), do: [type]

  defp dump_time({h, m, s, _}), do: Time.from_erl({h, m, s})
  defp dump_time(%Time{} = time), do: time
  defp dump_time(_), do: :error

  defp dump_date({_, _, _} = date) do
    dt =
      {date, {0, 0, 0}}
      |> NaiveDateTime.from_erl!()
      |> DateTime.from_naive!("Etc/UTC")

    {:ok, dt}
  end

  defp dump_date(%Date{} = date) do
    {:ok, date}
  end

  defp dump_date(_) do
    :error
  end

  defp dump_utc_datetime({{_, _, _} = date, {h, m, s, ms}}) do
    datetime =
      {date, {h, m, s}}
      |> NaiveDateTime.from_erl!({ms, 6})
      |> DateTime.from_naive!("Etc/UTC")

    {:ok, datetime}
  end

  defp dump_utc_datetime({{_, _, _} = date, {h, m, s}}) do
    datetime =
      {date, {h, m, s}}
      |> NaiveDateTime.from_erl!({0, 6})
      |> DateTime.from_naive!("Etc/UTC")

    {:ok, datetime}
  end

  defp dump_utc_datetime(datetime) do
    {:ok, datetime}
  end

  defp dump_naive_datetime({{_, _, _} = date, {h, m, s, ms}}) do
    datetime =
      {date, {h, m, s}}
      |> NaiveDateTime.from_erl!({ms, 6})
      |> DateTime.from_naive!("Etc/UTC")

    {:ok, datetime}
  end

  defp dump_naive_datetime(%NaiveDateTime{} = dt) do
    datetime =
      dt
      |> DateTime.from_naive!("Etc/UTC")

    {:ok, datetime}
  end

  defp dump_naive_datetime(dt) do
    datetime =
      dt
      |> DateTime.from_naive!("Etc/UTC")

    {:ok, datetime}
  end

  @impl Ecto.Adapter.Storage
  def storage_down([database: database]) do
    case Cosmox.Database.delete_database(database) do
      :ok -> :ok
      %Cosmox.Response.ErrorMessage{
        errors: errors
      }   -> {:error, errors}
    end
  end

  @impl Ecto.Adapter.Storage
  def storage_status([database: _database]) do
    # TODO
    :up
  end 

  @impl Ecto.Adapter.Storage
  def storage_up([database: database]) do
    case Cosmox.Database.create_database(database) do
      :ok -> :ok
      %Cosmox.Response.ErrorMessage{
        errors: errors
      }   -> {:error, errors}
    end
  end

  @impl Ecto.Adapter.Schema
  def autogenerate(:id) do
    UUID.uuid4()
  end

  @impl Ecto.Adapter.Schema
  def delete(_adapter_meta, _schema_meta, _filters, _options) do
    # TODO
    {:error, :stale}
  end

  @impl Ecto.Adapter.Schema
  def insert(_adapter_meta, _schema_meta, _fields, _on_conflict, _returning, _options) do
    {:ok, []} 
  end

  @impl Ecto.Adapter.Schema
  def insert_all(_adapter_meta, _schema_meta, _header, _list, _on_conflict, _returning, _placeholders, _options) do
    {:ok, []} 
  end

  @impl Ecto.Adapter.Schema
  def update(_adapter_meta, _schema_meta, _fields, _filters, _returning, _options) do
    {:ok, []} 
  end

  @impl Ecto.Adapter.Queryable
  def execute(_adapter_meta, _query_meta, _query_cache, _params, _options) do
    {1, nil}
  end

  @impl Ecto.Adapter.Queryable
  def prepare(_atom, _query) do
    {:nocache, nil}
  end
  
  @impl Ecto.Adapter.Queryable
  def stream(_adapter_meta, _query_meta, _query_cache, _params, _options) do
    []
  end
end
