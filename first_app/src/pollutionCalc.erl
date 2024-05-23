%%%-------------------------------------------------------------------
%%% @author urszula
%%% @copyright (C) 2024, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 29. Feb 2024 11:44
%%%-------------------------------------------------------------------
-module(pollutionCalc).
-author("urszula").

%% API
-export([get_types/0, calculate_max/2, readings/0, calculate_station_max/2,
  sum_elements/4,calculate_mean/2,count_readings/3]).

get_types() -> ["PM10", "PM2.5", "humidity", "temperature","PM1","PM25","TEMPERATURE","HUMIDITY", "PRESSURE", "CO", "NO2","SO2","O3"].

readings() -> [
  ["Stacja1", {2012, 12, 02, 22, 03, 03}, [{'PM10', 2.5}, {'PM10', 40}, {'humidity', 50}]],
  ["Stacja2", {2012, 12, 02, 22, 03, 03}, [{'PM10', 2.5}, {'PM2.5', 40}, {'temperature', 50}]],
  ["Stacja3", {2013, 01, 02, 12, 43, 03}, [{'PM2.5', 8}, {'temperature', 40}, {'humidity', 10}]],
  ["Stacja4", {2020, 01, 22, 22, 43, 03}, [{'PM2.5', 3}, {'temperature', 20}]],
  ["Stacja5", {2021, 01, 02, 12, 43, 03}, [{'PM10', 8}, {'temperature', 34}, {'humidity', 13},{'PM2.5', 3}]]
].

calculate_max([[_, _, Measure] | T], Type) ->
  case lists:member(Type, get_types()) of
    false -> io:format("~s",[Type]), "Type does not exist!";
    _ -> MaxTail = calculate_max(T, Type),
      StationMax = calculate_station_max(Measure, Type),
      io:format("Station max: ~w~n", [StationMax]),
      case MaxTail > StationMax of
        true -> MaxTail;
        _ -> StationMax
      end
  end;

calculate_max([], Type) ->
  case lists:member(Type, get_types()) of
    false -> "Type does not exist!";
    _ -> 0
  end.

calculate_station_max([{Name, Value} | T], Type) ->
  case lists:member(Type, get_types()) of
    false -> "Type does not exist!";
    _ -> case (Name == Type) of
           false -> calculate_station_max(T, Type);
           _ ->
             MaxTail = calculate_station_max(T, Type),
             case MaxTail > Value of
               true -> MaxTail;
               _ -> Value
             end
         end
  end;

calculate_station_max([], Type) ->
  case lists:member(Type, get_types()) of
    false -> "Type does not exist!";
    _ -> 0
  end.

sum_station_elements([{Name, Value} | T], Type, Sum, Counter) ->
  case lists:member(Type, get_types()) of
    false -> "Type does not exist station!";
    _ -> case (Name == Type) of
           false -> sum_station_elements(T, Type, Sum, Counter);
           _ -> sum_station_elements(T, Type, Sum + Value, Counter + 1)
         end
  end;

sum_station_elements([], Type, Sum, Counter) ->
  case lists:member(Type, get_types()) of
    false -> "Type does not exist station!";
    _ -> {Sum, Counter}
  end.

sum_elements([[_, _, Measure] | T],Type,Sum,Counter)->
  case lists:member(Type,get_types()) of
    false->"Type does not exist";
    true->
      {Station_sum,Station_counter}=sum_station_elements(Measure,Type,0,0),
      sum_elements(T,Type,Sum+Station_sum,Counter+Station_counter)
  end;

sum_elements([], Type,Sum,Counter) ->
case lists:member(Type, get_types()) of
  false -> "Type does not exist second!";
  _ -> {Sum,Counter}
end.


calculate_mean(Readings, Type) ->
  {Sum,Counter}=sum_elements(Readings,Type,0,0),
  case lists:member(Type, get_types()) of
    false -> "Type does not exist!";
    _ -> Sum/Counter
  end.

count_readings([[_,{Year,Month,Day,_,_,_},_]|T],Date,Counter)->
  Curr_date={Year,Month,Day},
  case Curr_date==Date of
      true->count_readings(T,Date,Counter+1);
      false->count_readings(T,Date,Counter)
  end;
count_readings([],_,Counter)->Counter.



