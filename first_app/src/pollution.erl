%%%-------------------------------------------------------------------
%%% @author urszula
%%% @copyright (C) 2024, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 23. Mar 2024 19:36
%%%-------------------------------------------------------------------
-module(pollution).
-author("urszula").

%% API
-compile(nowarn_export_all).
-compile(export_all).
%%-export([]).

-record(station, {name, coordinates}).
-record(measureMeta, {date, type}).

testStation() ->
  Station1 = #station{name = "Station1", coordinates = {2, 3}},
  Station2 = #station{name = "Station2", coordinates = {2, 5}},

  Meta1 = #measureMeta{date = calendar:local_time(), type = 'PM10'},
  Meta2 = #measureMeta{date = calendar:local_time(), type = 'PM2.5'},

  io:format("~s~n", [Station1#station.name]),
  io:format("~tp~n", [Station2#station.coordinates]),
  io:format("~s~n", [Meta1#measureMeta.type]),
%%  io:format("~tp~n", [Station2#station.coordinates]),
  D = dict:new(),
  D1 = dict:store(Meta1, 23, D),
  D2 = dict:store(Meta2, 12, D1),

  S1 = dict:from_list([{Station1, D2}]),
  S1
.


create_monitor() ->
  #{}.

station_name_exists(_, [], Sol) -> Sol;
station_name_exists(Name, [{{_, N, _}, _}], Sol) ->
  if
    Name == N -> true;
    true -> Sol
  end;
station_name_exists(Name, [{{_, N, _}, _} | T], Sol) ->
  if
    Name == N -> true;
    true -> station_name_exists(Name, T, Sol)
  end.


station_coordinates_exist(_, [], Sol) -> Sol;
station_coordinates_exist(Coordinates, [{{_, _, C}, _}], Sol) ->
  if
    Coordinates == C -> true;
    true -> Sol
  end;
station_coordinates_exist(Coordinates, [{{_, _, C}, _} | T], Sol) ->
  if
    Coordinates == C -> true;
    true -> station_name_exists(Coordinates, T, Sol)
  end.


add_station(Name, Coordinates, M) ->
  List = maps:to_list(M),
  case station_name_exists(Name, List, false) or station_coordinates_exist(Coordinates, List, false) of
    true -> {error, "Name or coordinates are already used for some other station!"};
    false ->
      Station = #station{name = Name, coordinates = Coordinates},
      M#{Station => dict:new()}
  end.


get_station({C1, C2}, M) ->
  M1 = maps:filter(fun(#station{name = _, coordinates = Coords}, _) -> Coords == {C1, C2} end, M),
  A = (maps:keys(M1)),
  if
    length(A) == 0 -> {error, "No station of such coordinates!"};
    true -> lists:nth(1, A)
  end;
get_station(Name, M) ->
  M1 = maps:filter(fun(#station{name = N, coordinates = _}, _) -> Name == N end, M),
  A = (maps:keys(M1)),
  if
    erlang:length(A) == 0 -> {error, "No station of such name!"};
    true -> lists:nth(1, A)
  end.

measurement_exists(Measurement, Dict) ->
  try
    dict:fetch(Measurement, Dict),
    true
  catch
    error:badarg -> false
  end.


add_value({C1, C2}, Date, Type, Value, M) ->
  case lists:member(Type, pollutionCalc:get_types()) of
    false -> {error, "Type does not exist!"};
    true ->
      Station = get_station({C1, C2}, M),
      case Station of
        {error, _} -> Station;
        _ ->
          Measures = maps:get(Station, M),
          New_measure = #measureMeta{date = Date, type = Type},
          case measurement_exists(New_measure, Measures) of
            true -> {error, "Measurement of this date, coordinates and type exists!"};
            _ -> M#{Station => dict:store(New_measure, Value, Measures)}
          end
      end
  end;
add_value(Name, Date, Type, Value, M) ->
  case lists:member(Type, pollutionCalc:get_types()) of
    false -> {error, "Type does not exist!"};
    _ ->
      Station = get_station(Name, M),
      case Station of
        {error, _} -> Station;
        _ ->
          Measures = maps:get(Station, M),
          New_measure = #measureMeta{date = Date, type = Type},
          case measurement_exists(New_measure, Measures) of
            true -> {error, "Measurement of this date, coordinates and type exists!"};
            _ -> M#{Station => dict:store(New_measure, Value, Measures)}
          end
      end
  end.

remove_value({C1, C2}, Date, Type, M) ->
  case lists:member(Type, pollutionCalc:get_types()) of
    false -> {error, "Type does not exist!"};
    _ ->
      Station = get_station({C1, C2}, M),
      case Station of
        {error, _} -> Station;
        _ ->
          Old_dict = maps:get(Station, M),
          Measure = #measureMeta{date = Date, type = Type},
          New_dict = dict:filter(fun(K, _) -> not (K == Measure) end, Old_dict),
          case measurement_exists(Measure, Old_dict) of
            false -> {error, "Measurement of this date, coordinates and type does not exist!"};
            _ -> M#{Station := New_dict}
          end
      end
  end;
remove_value(Name, Date, Type, M) ->
  case lists:member(Type, pollutionCalc:get_types()) of
    false -> {error, "Type does not exist!"};
    _ ->
      Station = get_station(Name, M),
      case Station of
        {error, _} -> Station;
        _ ->
          Old_dict = maps:get(Station, M),
          Measure = #measureMeta{date = Date, type = Type},
          New_dict = dict:filter(fun(K, _) -> not (K == Measure) end, Old_dict),
          case measurement_exists(Measure, Old_dict) of
            false -> {error, "Measurement of this date, name and type does not exist!"};
            _ -> M#{Station := New_dict}
          end
      end
  end.

get_one_value({C1, C2}, Date, Type, M) ->
  case lists:member(Type, pollutionCalc:get_types()) of
    false -> {error, "Type does not exist!"};
    _ ->
      Station = get_station({C1, C2}, M),
      case Station of
        {error, _} -> Station;
        _ ->
          Dict = maps:get(Station, M),
          Measure = #measureMeta{date = Date, type = Type},
          case measurement_exists(Measure, Dict) of
            false -> {error, "Measurement of this date, coordinates and type does not exist!"};
            _ -> dict:fetch(Measure, Dict)
          end
      end
  end;
get_one_value(Name, Date, Type, M) ->
  case lists:member(Type, pollutionCalc:get_types()) of
    false -> {error, "Type does not exist!"};
    _ ->
      Station = get_station(Name, M),
      case Station of
        {error, _} -> Station;
        _ ->
          Dict = maps:get(Station, M),
          Measure = #measureMeta{date = Date, type = Type},
          case measurement_exists(Measure, Dict) of
            false -> {error, "Measurement of this date, name and type does not exist!"};
            _ -> dict:fetch(Measure, Dict)
          end
      end
  end.


get_measure_of_type(Type, D) ->
  case lists:member(Type, pollutionCalc:get_types()) of
    false -> {error, "Type does not exist!"};
    _ -> lists:map(fun({_, V}) -> V end, dict:to_list(dict:filter(fun(K, _) -> K#measureMeta.type == Type end, D)))
  end.

get_mean(List) ->
  case length(List) of
    0 -> {error, "Unable to calculate mean, division by zero!"};
    _ -> lists:foldl(fun(X, Y) -> X + Y end, 0, List) / length(List)
  end.

get_station_mean({C1, C2}, Type, M) ->
  case lists:member(Type, pollutionCalc:get_types()) of
    false -> {error, "Type does not exist!"};
    _ ->
      Station = get_station({C1, C2}, M),
      case Station of
        {error, _} -> Station;
        _ ->
          Dict = maps:get(Station, M),
          Measures = get_measure_of_type(Type, Dict),
          get_mean(Measures)
      end
  end;
get_station_mean(Name, Type, M) ->
  case lists:member(Type, pollutionCalc:get_types()) of
    false -> {error, "Type does not exist!"};
    _ ->
      Station = get_station(Name, M),
      case Station of
        {error, _} -> Station;
        _ ->
          Dict = maps:get(Station, M),
          Measures = get_measure_of_type(Type, Dict),
          get_mean(Measures)
      end
  end.

get_dicts(M) -> [dict:to_list(V) || {_K, V} <- maps:to_list(M)].

flattening_func(T1, T2) -> T1 ++ T2.

flatten_list(List) -> lists:foldl(fun flattening_func/2, [], List).

get_measure_list(Type, Day, M) ->
  A = [V || {K, V} <- flatten_list(get_dicts(M)), Day == element(1, K#measureMeta.date), K#measureMeta.type == Type],
  case length(A) of
    0 -> {error, "No such measurements!"};
    _ -> A
  end.

get_daily_mean(Type, Day, M) ->
  case lists:member(Type, pollutionCalc:get_types()) of
    false -> {error, "Type does not exist!"};
    _ ->
      List = get_measure_list(Type, Day, M),
      case List of
        {error, _} -> List;
        _ -> get_mean(List)
      end
  end.

get_radius_dicts({C1, C2}, R, M) ->
  [dict:to_list(V) || {K, V} <- maps:to_list(M),
    ((element(1, K#station.coordinates) - C1) * (element(1, K#station.coordinates) - C1) +
      (element(2, K#station.coordinates) - C2) * (element(2, K#station.coordinates) - C2)) =< (R * R)].
get_measurements_in_radius(Type, {C1, C2}, R, M) ->
  A = [V || {K, V} <- flatten_list(get_radius_dicts({C1, C2}, R, M)), K#measureMeta.type == Type],
  case length(A) of
    0 -> {error, "No such measurements!"};
    _ -> A
  end.

get_area_mean(Type, {C1, C2}, R, M) ->
  case lists:member(Type, pollutionCalc:get_types()) of
    false -> {error, "Type does not exist!"};
    _ ->
      List = get_measurements_in_radius(Type, {C1, C2}, R, M),
      case List of
        {error, _} -> List;
        _ -> get_mean(List)
      end
  end.


