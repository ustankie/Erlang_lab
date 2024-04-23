%%%-------------------------------------------------------------------
%%% @author urszula
%%% @copyright (C) 2024, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 23. Apr 2024 11:17
%%%-------------------------------------------------------------------
-module(ping_pong2).
-author("urszula").

%% API
-compile(nowarn_export_all).
-compile(export_all).

start()->
  register(ping,spawn(?MODULE,ping,[0])),
  register(pong,spawn(fun ()-> pong(0) end)).

stop()->
  ping ! stop,
  pong ! stop.

play(N)->
  ping ! N.

ping()->
  receive
    stop-> ok;
    0 ->io:format("Ping: 0 ~n"),
        ping();
    N -> io:format("Ping: ~w ~n",[N]),
      timer:sleep(1000),
      pong ! (N-1),
      ping()
  after
    20000-> ok
  end.

pong()->
  receive
    stop-> ok;
    0 ->io:format("Pong: 0 ~n"),
        pong();
    N -> io:format("Pong: ~w ~n",[N]),
      timer:sleep(1000),
      ping ! (N-1),
      pong()
  after
    20000-> ok
  end.

ping(Count)->
  receive
    stop-> ok;
    0 ->Count2=Count+1,
      io:format("Ping: 0, Count: ~w ~n",[Count2]),
      ping(Count2);
    N -> Count2=Count+1,
      io:format("Ping: ~w, Count: ~w ~n",[N,Count2]),
      timer:sleep(1000),
      pong ! (N-1),
      ping(Count2)
  after
    20000-> ok
  end.

pong(Count)->
  receive
    stop-> ok;
    0 ->Count2=Count+1,
      io:format("Pong: 0, Count: ~w ~n",[Count2]),
      pong(Count2);
    N -> Count2=Count+1,
      io:format("Pong: ~w, Count: ~w ~n",[N,Count]),
      timer:sleep(1000),
      ping ! (N-1),
      pong(Count2)
  after
    20000-> ok
  end.