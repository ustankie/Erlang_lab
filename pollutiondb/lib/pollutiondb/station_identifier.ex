defmodule StationIdentifier do
  def identifyStations(stationMap) do
    stationMap
    |> Enum.filter(&(String.length(&1) > 0))
    |> Enum.map(&ParserLoader.parse_line/1)
    |> Enum.uniq_by(& &1.location)
  end

  def identifyTypes(stationMap) do
    stationMap
    |> Enum.filter(&(String.length(&1) > 0))
    |> Enum.map(&ParserLoader.parse_line/1)
    |> Enum.uniq_by(& &1.pollutionType)
  end
end