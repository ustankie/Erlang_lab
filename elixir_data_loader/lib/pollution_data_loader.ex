
defmodule PollutionDataLoader do
  def add_all_stations(station_map) do
    for x <- station_map do
      :pollution_gen_server.add_station("#{x.stationName}#{x.stationId}", x.location)
    end
  end

  def add_all_values(measures) do
    for x <- measures do
      :pollution_gen_server.add_value(
        x.location,
        x.datetime,
        String.to_charlist(x.pollutionType),
        x.pollutionLevel
      )
    end
  end
end
