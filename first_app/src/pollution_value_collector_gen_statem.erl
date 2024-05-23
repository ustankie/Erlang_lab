%%%-------------------------------------------------------------------
%%% @author urszula
%%% @copyright (C) 2024, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 08. May 2024 21:04
%%%-------------------------------------------------------------------
-module(pollution_value_collector_gen_statem).
-author("urszula").

-behaviour(gen_statem).

%% API
-export([start_link/0]).

%% gen_statem callbacks
-compile(nowarn_export_all).
-compile(export_all).

-define(SERVER, ?MODULE).
%%-record(state, {monitor, station=none, values=[]}).

%%-record(pollution_value_collector_gen_statem_state, {}).

%%%===================================================================
%%% API
%%%===================================================================

%% @doc Creates a gen_statem process which calls Module:init/1 to
%% initialize. To ensure a synchronized start-up procedure, this
%% function does not return until Module:init/1 has returned.
%%start_link(Monitor) ->
%%  gen_statem:start_link({local, ?SERVER}, ?MODULE, Monitor, []).
%%
%%%%%===================================================================
%%%%% gen_statem callbacks
%%%%%===================================================================
%%
%%%% @private
%%%% @doc Whenever a gen_statem is started using gen_statem:start/[3,4] or
%%%% gen_statem:start_link/[3,4], this function is called by the new
%%%% process to initialize.
%%init(Monitor) ->
%%  {ok, set_station, #state{monitor = Monitor}}.
%%
%%stop() -> gen_statem:stop(?SERVER).
%%
%%set_station(Arg)->gen_statem:cast(?MODULE,{set_station, Arg}).
%%add_val(Date, Type, Value)->gen_statem:cast(?MODULE,{add_value,Date, Type, Value}).
%%store_data()->gen_statem:cast(?MODULE,{store_data}).
%%get_values()->gen_statem:cast(?MODULE,{get_values}).
%%
%%callback_mode() ->
%%  state_functions.
%%
%%format_status(_Opt, [_PDict, _StateName, _State]) ->
%%  Status = some_term,
%%  Status.
%%
%%set_station(_Event,{set_station,Arg}, State) ->
%%  Station= pollution_gen_server:get_station(Arg),
%%  case Station of
%%    {error,A}->io:format(A),{next_state,set_station, State};
%%    _->{next_state, add_value, State#state{station = Station}}
%%  end;
%%
%%set_station(_Event,{get_values}, _State)->
%%  print_values([]),
%%  {next_state, add_value, _State}.
%%
%%add_value(_Event,{add_value,Date, Type, Value}, State) ->
%%  {next_state, add_value, State#state{values =[{Date, Type, Value} |State#state.values]}};
%%
%%add_value(_Event,{store_data}, State) ->
%%  Values=State#state.values,
%%  lists:foreach(
%%    fun({Date, Type, Value}) ->
%%      ReturnVal=pollution:add_value(State#state.station,Date, Type, Value,State#state.monitor),
%%      case ReturnVal of
%%        {error,A}->print_error(A);
%%          _->io:format("success")
%%      end,
%%      ReturnVal
%%    end,
%%    Values
%%  ),
%%  {next_state, set_station, []};
%%
%%add_value(_Event,{get_values}, State)->
%%  {_Station,Values}=State,
%%  print_values(Values),
%%  {next_state, add_value, State}.
%%
%%print_values([]) ->
%%  _;
%%print_values([{Date, Type, Value} | Rest]) ->
%%  io:format("Date: ~p, Type: ~p, Value: ~p~n", [Date, Type, Value]),
%%  print_values(Rest).


start_link() ->
  gen_statem:start_link({local, ?SERVER}, ?MODULE, [], []).
init([]) ->
  {ok, set_station, []}.

stop() -> gen_statem:stop(?SERVER).

set_station(Arg)->gen_statem:cast(?MODULE,{set_station, Arg}).
add_val(Date, Type, Value)->gen_statem:cast(?MODULE,{add_value,Date, Type, Value}).
store_data()->gen_statem:cast(?MODULE,{store_data}).
get_values()->gen_statem:cast(?MODULE,{get_values}).

callback_mode() ->
  state_functions.

format_status(_Opt, [_PDict, _StateName, _State]) ->
  Status = some_term,
  Status.

set_station(_Event,{set_station,Arg}, []) ->
  Station= pollution_gen_server:get_station(Arg),
  case Station of
    {error,A}->io:format(A),{next_state,set_station, []};
    _->{next_state, add_value, {Station,[]}}
  end;

set_station(_Event,{get_values}, _State)->
  print_values([]),
  {next_state, add_value, _State}.

add_value(_Event,{add_value,Date, Type, Value}, State) ->
  {Station,Values}=State,
  {next_state, add_value, {Station,[{Date, Type, Value}|Values]}};

add_value(_Event,{store_data}, State) ->
  {{station,Station,_Coords},Values}=State,
  erlang:display(Station),
  lists:foreach(
    fun({Date, Type, Value}) ->
      ReturnVal=pollution_gen_server:add_value(Station, Date, Type, Value),
      case ReturnVal of
        {error,A}->erlang:display(A);
        _->erlang:display("success")
      end,
      ReturnVal
    end,
    Values
  ),
  {next_state, set_station, []};

add_value(_Event,{get_values}, State)->
  {_Station,Values}=State,
  print_values(Values),
  {next_state, add_value, State}.

print_values([]) ->
  ok;
print_values([{Date, Type, Value} | Rest]) ->
  erlang:display({Date, Type, Value}),
  print_values(Rest).



