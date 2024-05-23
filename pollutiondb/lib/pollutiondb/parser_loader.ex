
defmodule ParserLoader do
  def configure() do
    data_list = File.read!("../Erlang_lab/src/lab05/AirlyData-ALL-50k.csv") |> String.split("\n")

    Code.append_path("../first_app/_build/default/lib/first_app/ebin")

    Application.start(:first_app)

    data_list
  end

  def get_stations(data_list) do
    data_list |> StationIdentifier.identifyStations()

  end

  def get_measures(data_list) do
    data_list|> Enum.filter(&(String.length(&1) > 0)) |> Enum.map(&ParserLoader.parse_line/1)

  end

  def parse_line(line) do
    [datetime, pollutionType, pollutionLevel, stationId, stationName, location] =
      String.split(line, ";")

    [date, time] = datetime |> String.split("T")

    %{
      :datetime =>
        {date
         |> String.split("-")
         |> Enum.map(&String.to_integer/1)
         |> List.to_tuple(),
        time
        |> String.slice(0..7)
        |> String.split(":")
        |> Enum.map(&String.to_integer/1)
        |> List.to_tuple()},
      :location =>
        location
        |> String.split(",")
        |> Enum.map(&String.to_float/1)
        |> :erlang.list_to_tuple(),
      :stationId =>
        stationId
        |> String.to_integer(),
      :stationName => stationName,
      :pollutionType => pollutionType,
      :pollutionLevel => pollutionLevel |> String.to_float()
    }
  end
end
