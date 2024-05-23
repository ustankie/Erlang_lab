%%%-------------------------------------------------------------------
%%% @author urszula
%%% @copyright (C) 2024, <COMPANY>
%%% @doc
%%% @end
%%%-------------------------------------------------------------------
-module(pollution_gen_server).

-behaviour(gen_server).

-export([start_link/0]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2,
  code_change/3, crash/0, get_monitor/0, incValue/0, get_station/1, add_station/2, get_value/1, get_daily_mean/2, get_area_mean/3, get_station_mean/2, get_one_value/3, remove_value/3, add_value/4, stop/0]).

-define(SERVER, ?MODULE).

-record(pollution_gen_server_state, {}).

%%%===================================================================
%%% Spawning and gen_server implementation
%%%===================================================================

start_link() ->
  gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

init([]) ->
  {ok, pollution:create_monitor()}.

crash()-> gen_server:call(?SERVER,{crash}).

get_monitor()->
  gen_server:call(?SERVER, {get_monitor}).

get_value(Value)->
  gen_server:call(?SERVER,{set_value, Value}).

add_station(Name,Coordinates)->
  gen_server:call(?SERVER,{add_station, Name,Coordinates}).

add_value(Arg, Date, Type, Value)->
  gen_server:call(?SERVER,{add_value, Arg, Date, Type, Value}).

remove_value(Arg, Date, Type)->
  gen_server:call(?SERVER,{remove_value, Arg, Date, Type}).


get_station(Arg)->
  gen_server:call(?SERVER,{get_station, Arg}).

get_one_value(Arg, Date, Type) ->
  gen_server:call(?SERVER,{get_one_value, Arg, Date, Type}).

get_station_mean(Arg, Type) ->
  gen_server:call(?SERVER,{get_station_mean, Arg, Type}).

get_daily_mean(Type, Day) ->
  gen_server:call(?SERVER,{get_daily_mean, Type, Day}).

get_area_mean(Type, Coordinates,R) ->
  gen_server:call(?SERVER,{get_area_mean, Type, Coordinates, R}).

stop()->
  gen_server:cast(?SERVER, {stop}).

incValue()->
  gen_server:cast(var_server,{incValue}).

handle_cast({set_monitor,Value},  _State) ->
  {noreply, Value};
handle_cast({stop},  Monitor) ->
  {stop, normal, Monitor}.


handle_call({get_monitor}, _From, State) ->
  {reply, State, State};

handle_call({add_station, Name,Coordinates},_From,  Monitor) ->
  Monitor1=pollution:add_station(Name, Coordinates, Monitor),
  case Monitor1 of
    {error,A}-> {reply,{error,A}, Monitor};
    _ ->{reply, ok, Monitor1}
  end;

handle_call({add_value, Arg, Date, Type, Value},_From,  Monitor) ->
  Monitor1 = pollution:add_value(Arg, Date, Type, Value, Monitor),
  case Monitor1 of
    {error,A}-> {reply,{error,A},Monitor};
    _ ->{reply, ok,Monitor1}
  end;

handle_call({remove_value, Arg, Date, Type},_From,  Monitor) ->
  Monitor1 = pollution:remove_value(Arg, Date, Type, Monitor),
  case Monitor1 of
    {error,A}->{reply,{error,A},Monitor};
    _ ->{reply, ok,Monitor1}
  end;

handle_call({get_one_value, Arg, Date, Type},_From,  Monitor) ->
  Value = pollution:get_one_value(Arg, Date, Type,Monitor),
  {reply, Value, Monitor};

handle_call( {get_station_mean, Arg, Type},_From,  Monitor) ->
  Mean = pollution:get_station_mean(Arg, Type, Monitor),
  {reply, Mean,Monitor};

handle_call({get_daily_mean, Type, Day},_From,  Monitor) ->
  Mean = pollution:get_daily_mean(Type, Day, Monitor),
  {reply, Mean,Monitor};

handle_call({get_area_mean, Type, Coordinates,R},_From,  Monitor) ->
  Mean = pollution:get_area_mean(Type, Coordinates,R, Monitor),
  {reply, Mean,Monitor};

handle_call({get_station,Arg}, _From, Monitor) ->
  Station = pollution:get_station(Arg, Monitor),
  case Station of
    {error,A}->{reply,{error,A}, Monitor};
    S->{reply,S,Monitor}
  end;


handle_call({get_value}, _From, State) ->
  {reply, State, State};

handle_call({crash}, _From, State = #pollution_gen_server_state{}) ->
  a:b(),
  {reply, ok, State};

handle_call(_Request, _From, State = #pollution_gen_server_state{}) ->
  {reply, ok, State}.



%%handle_cast(_Request, State = #pollution_gen_server_state{}) ->
%%  {noreply, State}.

handle_info(_Info, State = #pollution_gen_server_state{}) ->
  {noreply, State}.

terminate(_Reason, _State ) ->
  ok.

code_change(_OldVsn, State = #pollution_gen_server_state{}, _Extra) ->
  {ok, State}.


%%%===================================================================
%%% Internal functions
%%%===================================================================
