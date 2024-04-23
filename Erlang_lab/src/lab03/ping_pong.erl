%%%-------------------------------------------------------------------
%%% @author urszula
%%% @copyright (C) 2024, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 11. Apr 2024 11:44
%%%-------------------------------------------------------------------
-module(ping_pong).
-author("urszula").

%% API
-compile(nowarn_export_all).
-compile(export_all).

start() ->
    register(ping,spawn(fun()->ping(0) end)),
    register(pong,spawn(?MODULE,pong,[])).

play(N)->
  ping ! N.

ping(Count)->
  receive
    stop -> ok;
    0 -> io:format("Counting ended, Communicates: ~w ~n",[Count+1]), ping(Count+1);
    N -> io:format("ping ~w, Communicates: ~w ~n", [N,Count+1]),
            timer:sleep(1000),
            pong ! (N-1),
            ping(Count+1)

    after
      20000-> ok
  end.

pong() ->
  receive
    stop -> ok;
    0 -> io:format("Counting ended ~n"), pong();
    N -> io:format("pong ~w ~n",[N]),
      timer:sleep(1000),
      ping ! (N-1),
      pong()

  after
    20000-> ok
  end.


stop()->
  ping ! stop,
  pong ! stop.