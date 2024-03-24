%%%-------------------------------------------------------------------
%%% @author urszula
%%% @copyright (C) 2024, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 28. Feb 2024 21:24
%%%-------------------------------------------------------------------
-module(test).
-author("urszula").

%% API
-export([f1/0,power/2,power2/2,duplicateElements/1,contains/2,sumFloats/1,sumFloats/2,
  factorial/1,print_hello/0]).



f1()->123.

power(0,N) when is_number(N) and (N>0) ->0;
power(_,0)->1;
power(A,1)->A;
power(A,N)when is_number(N) and (N>0)->power(A,N-1)*A;
power(A,N)when is_number(N) and (N<0)->power(1/A,-N);
power(_,_)  ->1.

power2(A,N) when is_number(N)->
  case A of
    0 when is_number(N) and (N>0)->0;
    0 when not is_number(N) and not (N>0)->0;
    _->case N of
         0->1;
         1->A;
         _ when N>0->power2(A,N-1)*A;
          _ when N<0->power2(1/A,-N)
       end
  end;
power2(_,_) ->
  0.

contains([],_)->false;
contains([H|T],V)->
  if H==V->true;
    true->contains(T,V)
  end.

duplicateElements([])->[];
duplicateElements([H|T]) ->
  [H,H|duplicateElements(T)].

sumFloats([])->0;
sumFloats([H|T])when is_float(H) ->
  H+sumFloats(T);
sumFloats([_ | T]) ->
  sumFloats(T).

sumFloats([],Sol)->Sol;
sumFloats([H|T],Sol)when is_float(H) ->
  sumFloats(T,Sol+H);
sumFloats([_ | T],Sol) ->
  sumFloats(T,Sol).

factorial(N) when not is_number(N)->error;
factorial(0) ->1;
factorial(N) when N>0 -> factorial(N-1)*N;
factorial(_)->error.

print_hello()->
  io:format("Hello World~n").

