%%%-------------------------------------------------------------------
%%% @author urszula
%%% @copyright (C) 2024, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 23. Apr 2024 12:13
%%%-------------------------------------------------------------------
-module(pollution_server).
-author("urszula").

%% API
-compile(nowarn_export_all).
-compile(export_all).

start() ->
  register(pollution_serv, spawn(fun() -> init() end)).

stop() ->
  pollution_serv ! stop.

init() ->
  loop(pollution:create_monitor()).

loop(Monitor) ->
  receive
    stop -> ok;
    {request, Pid, {add_station, Name, Coordinates}} ->
      Monitor1=pollution:add_station(Name, Coordinates, Monitor),
      case Monitor1 of
        {error,A}-> Pid ! {reply,{error,A}},loop(Monitor);
        _ ->Pid ! {reply, ok},loop(Monitor1)
      end;

    {request, Pid, {get_station, Arg}} ->
      Station = pollution:get_station(Arg, Monitor),
      Pid ! {reply, Station},
      loop(Monitor);
    {request, Pid, {add_value, Arg, Date, Type, Value}} ->
      Monitor1 = pollution:add_value(Arg, Date, Type, Value, Monitor),
      case Monitor1 of
        {error,A}-> Pid ! {reply,{error,A}},loop(Monitor);
        _ ->Pid ! {reply, ok},loop(Monitor1)
      end;

    {request, Pid, {remove_value, Arg, Date, Type}} ->
      Monitor1 = pollution:remove_value(Arg, Date, Type, Monitor),
      case Monitor1 of
        {error,A}-> Pid ! {reply,{error,A}},loop(Monitor);
        _ ->Pid ! {reply, ok},loop(Monitor1)
      end;
    {request, Pid, {get_one_value, Arg, Date, Type}} ->
      Value = pollution:get_one_value(Arg, Date, Type,Monitor),
      Pid ! {reply, Value},
      loop(Monitor);
    {request, Pid, {get_station_mean, Arg, Type}} ->
      Mean = pollution:get_station_mean(Arg, Type, Monitor),
      Pid ! {reply, Mean},
      loop(Monitor);
    {request, Pid, {get_daily_mean, Type, Day}} ->
      Mean = pollution:get_daily_mean(Type, Day, Monitor),
      Pid ! {reply, Mean},
      loop(Monitor);
    {request, Pid, {get_area_mean, Type, Coordinates,R}} ->
      Mean = pollution:get_area_mean(Type, Coordinates,R, Monitor),
      Pid ! {reply, Mean},
      loop(Monitor);
    {request, Pid, {get_monitor}}->
      Pid ! {reply,Monitor},
      loop(Monitor)


  end.
call(Message) ->
  pollution_serv ! {request, self(), Message},
  receive
    {reply, Reply} -> Reply
  end.

add_station(Name, Coordinates) ->
  call({add_station, Name, Coordinates}).

get_station(Name) ->
  call({get_station, Name}).

add_value(Arg, Date, Type, Value) ->
  call({add_value, Arg, Date, Type, Value}).

remove_value(Arg, Date, Type) ->
  call({remove_value, Arg, Date, Type}).

get_one_value(Arg, Date, Type) ->
  call({get_one_value, Arg, Date, Type}).

get_station_mean(Arg, Type) ->
  call({get_station_mean, Arg, Type}).

get_daily_mean(Type, Day) ->
  call({get_daily_mean, Type, Day}).

get_area_mean(Type, Coordinates,R) ->
  call({get_area_mean, Type, Coordinates, R}).

get_monitor()->
  call({get_monitor}).


