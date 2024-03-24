%%%-------------------------------------------------------------------
%%% @author urszula
%%% @copyright (C) 2024, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 14. Mar 2024 11:42
%%%-------------------------------------------------------------------
-module(lab).
-author("urszula").

%% API
-compile(nowarn_export_all).
-compile(export_all).
%%-export([]).

less_than(List, Arg)-> [X || X<-List, X<Arg].

grt_eq_than(List,Arg)-> [X || X<-List, X>=Arg].

qs([])->[];
qs([A])->[A];
qs([Pivot|Tail]) ->  qs(less_than(Tail,Pivot))++[Pivot]++qs( grt_eq_than(Tail,Pivot) ).


random_elems(N,Min,Max)->[rand:uniform(Max-Min+1)+Min-1 || _<-lists:seq(1,N)].

compare_speeds(List, Fun1, Fun2) ->
  {Time1,_}=timer:tc(Fun1,[List]),
  {Time2,_}=timer:tc (Fun2,[List]),
  io:format("Time1: ~p, Time2: ~p ~n",[Time1,Time2]).

%lab:compare_speeds(L,fun lab:qs/1,fun lists:sort/1).



% Fun
% 1. F3=fun (L)-> lists:map(fun F($o) -> $a; F($e)->$o; F(X)->X end, L) end.
% 2. F4=fun(L)->length(lists:filter(fun (X)->X rem 3==0 end, L)) end.
% lub F5=fun (X) when X rem 3==0 -> 1; (_)->0 end.
%     F7= fun (L)->lists:foldl(fun (X,Y)->X+Y end, 0, [1|| X<-L, F5(X)==1]) end.

get_measure_lists (List) -> lists:map(fun F([])->[];F([_,_,T|Tail])->T++F(Tail) end, List).

flattening_func(T1,T2) -> T1++T2.

flatten_list(List)->lists:foldl(fun flattening_func/2,[],List).

mean_measurement(List,Type)->
    A=[X||{D,X}<-flatten_list(get_measure_lists(List)), D==Type],
    lists:sum(A)/length(A).

