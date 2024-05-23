%%%-------------------------------------------------------------------
%%% @author urszula
%%% @copyright (C) 2024, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 24. Apr 2024 21:15
%%%-------------------------------------------------------------------
-module(var_supervisor).
-behavior(supervisor).
-author("urszula").

%% API
-export([]).

start_link(InitValue)->
  supervisor:start_link({local, ?MODULE},?MODULE, InitValue).

init(InitValue)->
  SupFlags=#{
    strategy=> one_for_one,
    intensity => 5,
    period => 6
  },

  ChildSpec=[#{
    id => 'var_server',
    start => {var_server,start_link,[InitValue]},
    restart => permanent,
    shutdown => 2000,
    type => worker,
    modules=> [var_server]
  }],
  {ok,SupFlags,ChildSpec}.
