require Ecto.Query
defmodule Pollutiondb.Reading do
  use Ecto.Schema

  schema "readings" do
    field :date, :date
    field :time, :time
    field :type, :string
    field :value, :float
    belongs_to :station, Pollutiondb.Station
  end

  def add_now(station, type, value) do
    %Pollutiondb.Reading{}
    |>validate_reading(%{date: Date.utc_today,time: Time.utc_now,type: type,value: value, station_id: station.id})
    |>Pollutiondb.Repo.insert()
  end

  defp validate_reading(reading, changes_map) do
    reading
    |> Ecto.Changeset.cast(changes_map, [:date,:time,:type,:value, :station_id])
    |> Ecto.Changeset.cast_assoc(:station)
    |> Ecto.Changeset.validate_required([:date,:time, :type, :value, :station_id])
  end

  def find_by_date(date) do
    Pollutiondb.Repo.all(
      Ecto.Query.where(Pollutiondb.Reading, date: ^date) )
  end

  def add(station, date, time, type, value) do
    %Pollutiondb.Reading{}
    |>validate_reading(%{date: date,time: time,type: type,value: value, station_id: station.id})
    |>Pollutiondb.Repo.insert()
  end
end
