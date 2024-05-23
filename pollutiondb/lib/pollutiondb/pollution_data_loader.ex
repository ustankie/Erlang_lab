
defmodule PollutionDataLoader do
  def add_all_stations(station_map) do
    for x <- station_map do
      Pollutiondb.Station.add("#{x.stationName}#{x.stationId}", elem(x.location,0), elem(x.location,1))
    end
  end

  def add_all_values(measures) do
    for x <- measures do
      station=Enum.at(Pollutiondb.Station.find_by_location(elem(x.location,0),elem(x.location,1)),0)
      Pollutiondb.Reading.add(
        station,
        Date.from_erl!(elem(x.datetime,0)),
        Time.from_erl!(elem(x.datetime,1)),
        x.pollutionType,
        x.pollutionLevel
      )
    end
  end

  def load_all_data() do
    data_list=ParserLoader.configure()
    stations=ParserLoader.get_stations(data_list)
    measures=ParserLoader.get_measures(data_list)

    add_all_stations(stations)
    add_all_values(measures)

  end
end
