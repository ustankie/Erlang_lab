%%%-------------------------------------------------------------------
%%% @author urszula
%%% @copyright (C) 2024, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 13. Mar 2024 22:44
%%%-------------------------------------------------------------------
-module(increaser_test).
-author("urszula").

-include_lib("/usr/lib/erlang/lib/eunit-2.9/include/eunit.hrl").
-compile(nowarn_export_all).
-compile([export_all]).
%%-export([increase_empty_list_test/0]).

increase_integer_test() -> 45 = increaser:increase(3).
increase_empty_list_test() -> [] = increaser:increase([]).
increase_list_test() -> [2,3,4,aaa,5] = increaser:increase([1,2,3,aaa,4]).
increase_nested_list_test() -> [1,[2],[3,4],[]] = increaser:increase([0,[1],[2,3],[]]).
