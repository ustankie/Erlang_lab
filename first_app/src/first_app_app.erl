%%%-------------------------------------------------------------------
%% @doc first_app public API
%% @end
%%%-------------------------------------------------------------------

-module(first_app_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    first_app_sup:start_link().

stop(_State) ->
    ok.

%% internal functions
