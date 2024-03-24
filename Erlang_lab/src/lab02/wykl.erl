%%%-------------------------------------------------------------------
%%% @author urszula
%%% @copyright (C) 2024, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 13. Mar 2024 08:47
%%%-------------------------------------------------------------------
-module(wykl).
-author("urszula").

%% API
-export([catchme/1,testRecord/0,makeG1/0,lessThenMax/1,testNestedRecord/0,testPatterns/1]).

-record(grupa, {nazwa, licznosc, stan=aktywna}).
-record(nadgrupa, {nadnazwa, grp}).
-define(MaxCount,100).
-define(Tuple3(A), {A,A*2,A*3}).

testRecord()->
  Grupa1 = #grupa{nazwa="Grupa1",licznosc=12},
  Grupa2 = #grupa{nazwa="Grupa2",licznosc=2,stan=0},

  io:format("~s~n", [Grupa1#grupa.nazwa]),
  io:format("~B~n", [Grupa2#grupa.stan]).

makeG1()->
  G1= #grupa{nazwa="Nowa Grupa",licznosc=4,stan=23},
  G2= G1#grupa{nazwa="Druga"},
  io:format("~s~n", [G1#grupa.nazwa]),
  io:format("~s~n", [G2#grupa.nazwa]).

testNestedRecord()->
  Nad=#nadgrupa{nadnazwa="Nadgrupa1",
        grp=#grupa{ nazwa="Gr",licznosc=7}},
  Nad.

testPatterns(#grupa{nazwa=Nazwa,licznosc=7})->Nazwa;
testPatterns(#grupa{licznosc = Licznosc})
  when Licznosc > 1 ->
  Licznosc;
testPatterns(#nadgrupa{nadnazwa = NadNazwa,
  grp = #grupa{nazwa = Nazwa}}) ->
  NadNazwa ++ Nazwa.

lessThenMax(X) when X < ?MaxCount ->
  ?Tuple3(X).

catchme(N) ->
  try generate_exception(N) of
    Val -> {N, normal, Val}
  catch
    throw:X -> {N, thw, X};
    exit:X -> {N, ext, X};
    error:X -> {N, err, X}
  end.
generate_exception(1) -> a;
generate_exception(2) -> throw(a);
generate_exception(3) -> exit(a);
generate_exception(4) -> erlang:error(a);
generate_exception(5) -> {'EXIT', a};
%%generate_exception(6) -> 1/0;
generate_exception(7) -> list:seq(1,asd).

