%%%-------------------------------------------------------------------
%%% @author urszula
%%% @copyright (C) 2024, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 23. Apr 2024 11:34
%%%-------------------------------------------------------------------
-module(sensor_dist2).
-author("urszula").

%% API
-compile(nowarn_export_all).
-compile(export_all).


get_rand_locations(N) ->
  [{rand:uniform(10000), rand:uniform(10000)} || _ <- lists:seq(1, N)].

dist({X1, Y1}, {X2, Y2}) ->
  math:sqrt((math:pow((X1 - X2), 2) + math:pow((Y1 - Y2), 2))).


find_for_person(PersonLocation, SensorsLocations) ->
  lists:min([{dist(PersonLocation, Sensor), {PersonLocation, Sensor}} || Sensor <- SensorsLocations]).

find_closest(PeopleLocations, SensorsLocations) ->
  lists:min([find_for_person(Person, SensorsLocations) || Person <- PeopleLocations]).

find_for_person(PersonLocation, SensorsLocations, ParentPID) ->
  ParentPID ! lists:min([{dist(PersonLocation, Sensor), {PersonLocation, Sensor}} || Sensor <- SensorsLocations]).

find_closest_parallel(PeopleLocations, SensorsLocations) ->
  [spawn(?MODULE, find_for_person,[Person, SensorsLocations, self()]) || Person <- PeopleLocations],
  lists:min([receive Res -> Res end || _ <- PeopleLocations]).




