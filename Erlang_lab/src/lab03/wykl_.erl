
%%%-------------------------------------------------------------------
%%% @author urszula
%%% @copyright (C) 2024, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 27. Mar 2024 08:14
%%%-------------------------------------------------------------------
-module(wykl_).
-author("urszula").

%% API
-export([createAndAsk/0, reply/0,pass/0,pass/1,start/0,stop/0,mul/1,loop/0]).

%%PID=spawn(fun()->receive A-> erlang:display("got message") end end).
%%PID !alamakota

createAndAsk() ->
  Pid=spawn(wykl,reply,[]),
  Pid ! {self(), question},
  receive
    answer -> io:format("Received! ~n")
  end.

reply() ->
  receive
    {Pid, question} -> Pid ! answer
  end.

pass(Count)->
  {_,Sec,_}=erlang:timestamp(),
  Pid = spawn (?MODULE, pass,[]),
  Pid ! {self(), Count},
  receive
    _->
        {_,Sec2,_} = erlang:timestamp(),
        io:format("took: ~w ~n",[Sec2 -Sec]),
        ok
  end.

pass() ->
  receive
    {ParentPid, Count} when Count >0 ->
      Pid=spawn(?MODULE,pass,[]),
      Pid ! {self(), Count -1},
      receive
        _-> ParentPid ! ok
      end;
    {ParentPid, _} -> ParentPid ! ok
  end.

start() ->
  register(m3server,spawn(?MODULE, loop,[])).

loop()->
  receive
    stop -> ok;
    {Pid, N} ->
      Result=N*5,
      io:format("Server got ~w, returning ~w ~n",[N,Result]),
      Pid ! Result,
      ?MODULE:loop()
  end.

stop() -> m3server ! stop.

mul(N) ->
  m3server ! {self(), N},
  receive
    M->M
  end,
  io:format("Result: ~p ~n", [M]),
  M.