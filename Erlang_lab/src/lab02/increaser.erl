%%%-------------------------------------------------------------------
%%% @author urszula
%%% @copyright (C) 2024, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 13. Mar 2024 22:42
%%%-------------------------------------------------------------------
-module(increaser).
-export([increase/1]).

increase(X) when is_integer(X) or is_float(X) -> X + 1;
increase([H|T]) when is_integer(H) or is_float(H) -> [H+1 | increase(T)];
increase([H|T]) when is_list(H) -> [increase(H) | increase(T)];
increase([H|T]) -> [H | increase(T)];
increase(X) -> X.