%%%-------------------------------------------------------------------
%%% @author urszula
%%% @copyright (C) 2024, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 11. Apr 2024 12:11
%%%-------------------------------------------------------------------
-module(sensor_dist).
-author("urszula").

%% API
-compile(nowarn_export_all).
-compile(export_all).


get_rand_locations(N)->
  [{rand:uniform(1000),rand:uniform(1000)} || _ <-lists:seq(1,N)].

dist({X1,Y1},{X2,Y2})->
  math:sqrt((math:pow((X1-X2),2)+math:pow((Y1-Y2),2))).

find_for_person(PersonLocation, SensorsLocations)->
  lists:min([{dist(PersonLocation,SensorsLocation),{PersonLocation,SensorsLocation}} || SensorsLocation <- SensorsLocations]).

find_for_person(PersonLocation, SensorsLocations, ParentPID)->
  ParentPID ! lists:min([{dist(PersonLocation,SensorsLocation),{PersonLocation,SensorsLocation}}
    || SensorsLocation <- SensorsLocations]).

find_closest(PeopleLocations, SensorsLocations) ->
  PeopleClosest=[find_for_person(Person, SensorsLocations) || Person <- PeopleLocations],
  lists:min(PeopleClosest).

find_closest_parallel(PeopleLocations, SensorsLocations)->
    [spawn(?MODULE, find_for_person,[Person, SensorsLocations,self()]) || Person <- PeopleLocations],
    timer:sleep(100),
    spawn(fun () -> loop([], self()) end),
    receive
      People-> io:format("~w",[People])
%%                lists:min(People)
    end.

loop(People, Parent) ->
  receive
    stop -> Parent ! People;
    Result->loop(People ++ Result,Parent)

  end.

find_closest_parallel2(PeopleLocations, SensorsLocations)->
  [spawn(?MODULE, find_for_person,[Person, SensorsLocations,self()]) || Person <- PeopleLocations],
  lists:min([receive M-> M end || _ <-PeopleLocations]).



