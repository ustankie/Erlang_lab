%%%-------------------------------------------------------------------
%%% @author urszula
%%% @copyright (C) 2024, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 24. Apr 2024 11:45
%%%-------------------------------------------------------------------
-module(var_server).
-behavior(gen_server).
-author("urszula").

%% API
-compile(nowarn_export_all).
-compile(export_all).

start_link(InitialValue)->
  gen_server:start_link({local,var_server},?MODULE, InitialValue,[]).

init(InitialValue)->
  {ok, InitialValue}.

getValue()->
  gen_server:call(var_server,{getValue}).

handle_call({getValue},_From,Value)->
  {reply,Value,Value}.


setValue(NewValue)->
  gen_server:cast(var_server,{setValue,NewValue}).

incValue()->
  gen_server:cast(var_server,{incValue}).

stop()->
  gen_server:cast(var_server,stop).

handle_cast({setValue,NewValue},_Value)->
  {noreply,NewValue};

handle_cast({incValue},Value)->
  {noreply,Value+1};

handle_cast(stop,Value)->
  {stop,normal, Value}.


terminate(Reason,Value)->
  io:format("Server: exit with value ~p ~n",[Value]),
  Reason.


