%%%-------------------------------------------------------------------
%%% @author Wojciech Turek
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 14. mar 2019 12:50
%%%-------------------------------------------------------------------
-module(pollution_server_test).
-author("Wojciech Turek").

-include_lib("/usr/lib/erlang/lib/eunit-2.9/include/eunit.hrl").

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-define(assertNotEqual, macro_body).
-define(assertMatch, macro_body).
-define(assertNotMatch, macro_body).
-define(assertEqual, macro_body).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
add_station_test() ->
  pollution_server:start(),
  A=pollution_server:add_station("Stacja 1", {1,1}),
  ?assertNotMatch({error, _}, A),
  ?assertMatch({error, _}, pollution_server:add_station("Stacja 1", {1,1})),
  ?assertMatch({error, _}, pollution_server:add_station("Stacja 1", {2,2})),
  ?assertMatch({error, _}, pollution_server:add_station("Stacja 2", {1,1})),
  pollution_server:stop().

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
add_value_test() ->
  pollution_server:start(),
  pollution_server:add_station("Stacja 1", {1,1}),
  Time = calendar:local_time(),
  ?assertNotMatch({error, _}, pollution_server:add_value("Stacja 1", Time, "PM10", 46.3)),
  ?assertNotMatch({error, _}, pollution_server:add_value("Stacja 1", Time, "PM1", 46.3)),
  ?assertNotMatch({error, _}, pollution_server:add_value("Stacja 1", {{2023,3,27},{11,16,9}}, "PM10", 46.3)),
  pollution_server:stop(),
  timer:sleep(500),
  pollution_server:start(),
  pollution_server:add_station("Stacja 1", {1,1}),
  timer:sleep(1100),
  Time2 = calendar:local_time(),
  ?assertNotMatch({error, _}, pollution_server:add_value( {1,1}, Time2, "PM10", 46.3)),
  ?assertNotMatch({error, _}, pollution_server:add_value( {1,1}, Time2, "PM1", 46.3)),
  ?assertNotMatch({error, _}, pollution_server:add_value( {1,1}, {{2023,3,27},{11,16,10}}, "PM10", 46.3)),

  pollution_server:stop().


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
add_value_fail_test() ->
  pollution_server:start(),
  pollution_server:add_station("Stacja 1", {1,1}),
  Time = calendar:local_time(),
  M1=pollution_server:add_value("Stacja 1", Time, "PM10", 46.3),
  ?assertNotMatch({error, _}, M1),
  ?assertMatch({error, _}, pollution_server:add_value("Stacja 1", Time, "PM10", 46.3)),
  pollution_server:stop(),
  timer:sleep(300),

  pollution_server:start(),
  pollution_server:add_station("Stacja 1", {1,1}),
  pollution_server:add_value("Stacja 1", Time, "PM10", 46.3),
  ?assertMatch({error, _}, pollution_server:add_value("Stacja 1", Time, "PM10", 36.3)),
    pollution_server:stop(),
    timer:sleep(300),

    pollution_server:start(),
    pollution_server:add_station("Stacja 1", {1,1}),
    pollution_server:add_value("Stacja 1", Time, "PM10", 46.3),
  ?assertMatch({error, _}, pollution_server:add_value({1,1}, Time, "PM10", 46.3)),
    pollution_server:stop(),
    timer:sleep(300),

    pollution_server:start(),
    pollution_server:add_station("Stacja 1", {1,1}),
    pollution_server:add_value("Stacja 1", Time, "PM10", 46.3),
  ?assertMatch({error, _}, pollution_server:add_value({1,1}, Time, "PM10", 36.3)),
    pollution_server:stop().


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
add_value_non_existing_station_test() ->
  pollution_server:start(),
  pollution_server:add_station("Stacja 1", {1,1}),
  ?assertMatch({error, _}, pollution_server:add_value("Stacja 2", calendar:local_time(), "PM10", 46.3)),
  ?assertMatch({error, _}, pollution_server:add_value({1,2}, calendar:local_time(), "PM10", 46.3)),
  pollution_server:stop().


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
remove_value_test() ->
  pollution_server:start(),
  pollution_server:add_station("Stacja 1", {1,1}),
  Time = calendar:local_time(),
  pollution_server:add_value("Stacja 1", Time, "PM10", 46.3),
  pollution_server:add_value("Stacja 1", Time, "PM1", 46.3),
  pollution_server:add_value("Stacja 1", {{2023,3,27},{11,16,9}}, "PM10", 46.3),
  M3=pollution_server:get_monitor(),

  M4 = pollution_server:remove_value("Stacja 1", Time, "PM10"),
  M41=pollution_server:get_monitor(),
  ?assertNotMatch({error, _}, M4),
  ?assertNotEqual(M41, M3),
  M5 = pollution_server:remove_value("Stacja 1", {{2023,3,27},{11,16,9}}, "PM10"),
  M51=pollution_server:get_monitor(),
  ?assertNotMatch({error, _}, M5),
  ?assertNotEqual(M51, M41),
  pollution_server:stop().


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
remove_value_and_add_back_test() ->
  pollution_server:start(),
  pollution_server:add_station("Stacja 1", {1,1}),
  Time = calendar:local_time(),
  pollution_server:add_value("Stacja 1", Time, "PM10", 46.3),
  pollution_server:add_value("Stacja 1", Time, "PM1", 46.3),
  pollution_server:add_value("Stacja 1", {{2023,3,27},{11,16,9}}, "PM10", 46.3),
  M3=pollution_server:get_monitor(),
  pollution_server:remove_value("Stacja 1", {{2023,3,27},{11,16,9}}, "PM10"),
  M4 = pollution_server:get_monitor(),
  ?assertNotEqual(M4, M3),

  pollution_server:add_value({1,1}, {{2023,3,27},{11,16,9}}, "PM10", 46.3),
  M5=pollution_server:get_monitor(),
  ?assertEqual(M5, M3),
  pollution_server:stop().


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
remove_value_fail_test() ->
  pollution_server:start(),
  pollution_server:add_station("Stacja 1", {1,1}),
  Time = calendar:local_time(),
  pollution_server:add_value("Stacja 1", Time, "PM10", 46.3),
  pollution_server:add_value("Stacja 1", Time, "PM1", 46.3),
  pollution_server:add_value("Stacja 1", {{2023,3,27},{11,16,9}}, "PM10", 46.3),

  ?assertMatch({error, _}, pollution_server:remove_value("Stacja 1", Time, "PM25")),
  ?assertMatch({error, _}, pollution_server:remove_value("Stacja 1", {{2023,3,27},{11,16,10}}, "PM10")),
  ?assertMatch({error, _}, pollution_server:remove_value({1,2}, Time, "PM10")),
  ?assertMatch({error, _}, pollution_server:remove_value("Stacja 2", Time, "PM10")),
  pollution_server:stop().


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
get_one_value_test() ->
  pollution_server:start(),
  pollution_server:add_station("Stacja 1", {1,1}),
  Time = calendar:local_time(),
  pollution_server:add_value("Stacja 1", Time, "PM10", 46.3),
  pollution_server:add_value("Stacja 1", Time, "PM1", 36.3),
  pollution_server:add_value("Stacja 1", {{2023,3,27},{11,16,9}}, "PM10", 26.3),

  ?assertMatch(46.3, pollution_server:get_one_value("Stacja 1", Time, "PM10")),
  ?assertMatch(36.3, pollution_server:get_one_value("Stacja 1", Time, "PM1")),
  ?assertMatch(46.3, pollution_server:get_one_value({1,1}, Time, "PM10")),
  ?assertMatch(26.3, pollution_server:get_one_value("Stacja 1", {{2023,3,27},{11,16,9}}, "PM10")),
  pollution_server:stop().


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
get_one_value_fail_test() ->
  pollution_server:start(),
  pollution_server:add_station("Stacja 1", {1,1}),
  Time = calendar:local_time(),
  pollution_server:add_value("Stacja 1", Time, "PM10", 46.3),
  pollution_server:add_value("Stacja 1", Time, "PM1", 36.3),
  pollution_server:add_value("Stacja 1", {{2023,3,27},{11,16,9}}, "PM10", 26.3),

  ?assertMatch({error, _}, pollution_server:get_one_value("Stacja 1", Time, "PM25")),
  ?assertMatch({error, _}, pollution_server:get_one_value({1,1}, Time, "PM25")),
  ?assertMatch({error, _}, pollution_server:get_one_value("Stacja 1", {{2023,3,27},{11,16,10}}, "PM10")),
  ?assertMatch({error, _}, pollution_server:get_one_value("Stacja 2", Time, "PM1")),
  ?assertMatch({error, _}, pollution_server:get_one_value({1,2}, Time, "PM10")),
  pollution_server:stop().


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
get_station_mean_test() ->
  pollution_server:start(),
  pollution_server:add_station("Stacja 1", {1,1}),
  pollution_server:add_value("Stacja 1", {{2023,3,27},{11,16,10}}, "PM10", 10),
  pollution_server:add_value("Stacja 1", {{2023,3,27},{11,16,11}}, "PM10", 20),
  M2=pollution_server:get_monitor(),
  pollution_server:add_value("Stacja 1", {{2023,3,27},{11,16,12}}, "PM10", 10),
  M3=pollution_server:get_monitor(),
  pollution_server:add_value("Stacja 1", {{2023,3,27},{11,16,13}}, "PM10", 20),
  M4=pollution_server:get_monitor(),

  ?assertMatch(15.0, pollution:get_station_mean("Stacja 1", "PM10", M2)),
  ?assertMatch(15.0, pollution:get_station_mean({1,1}, "PM10", M4)),
  ?assertMatch(40/3, pollution:get_station_mean("Stacja 1", "PM10", M3)),
  pollution_server:stop().

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
get_station_mean_fail_test() ->
  pollution_server:start(),
  pollution_server:add_station("Stacja 1", {1,1}),
  ?assertMatch({error, _}, pollution_server:get_station_mean("Stacja 1", "PM10")),
  pollution_server:add_value("Stacja 1", {{2023,3,27},{11,16,10}}, "PM10", 10),
  ?assertMatch({error, _}, pollution_server:get_station_mean("Stacja 1", "PM25")),
  ?assertMatch({error, _}, pollution_server:get_station_mean("Stacja 2", "PM25")),
  pollution_server:stop().


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
get_daily_mean_test() ->
  pollution_server:start(),
  pollution_server:add_station("Stacja 2", {2,2}),
  pollution_server:add_station("Stacja 1", {1,1}),
  pollution_server:add_station("Stacja 3", {3,3}),
  pollution_server:add_value("Stacja 1", {{2023,3,27},{11,16,10}}, "PM10", 10),
  pollution_server:add_value("Stacja 2", {{2023,3,27},{11,16,11}}, "PM10", 20),
    M2=pollution_server:get_monitor(),
  pollution_server:add_value("Stacja 1", {{2023,3,27},{11,16,12}}, "PM10", 10),
  pollution_server:add_value("Stacja 2", {{2023,3,27},{11,16,13}}, "PM10", 20),

  pollution_server:add_value("Stacja 1", {{2023,3,27},{11,16,14}}, "PM25", 100),
  pollution_server:add_value("Stacja 2", {{2023,3,27},{11,16,15}}, "PM25", 220),
    M6=pollution_server:get_monitor(),



  pollution_server:add_value("Stacja 3", {{2023,3,27},{11,16,18}}, "PM10", 1234),
    M9=pollution_server:get_monitor(),

  ?assertMatch(15.0, pollution:get_daily_mean("PM10",{2023,3,27}, M2)),
  ?assertMatch(15.0, pollution:get_daily_mean("PM10",{2023,3,27}, M6)),
%%  ?assertMatch(15.0, pollution:get_daily_mean("PM10",{2023,3,27}, M9)).
  ?assertMatch(258.8, pollution:get_daily_mean("PM10",{2023,3,27}, M9)),
  pollution_server:stop().



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
get_daily_mean_fail_test() ->
  pollution_server:start(),
  pollution_server:add_station("Stacja 2", {2,2}),
  pollution_server:add_station("Stacja 1", {1,1}),
  pollution_server:add_station("Stacja 3", {3,3}),
  ?assertMatch({error, _}, pollution_server:get_daily_mean("PM10",{2023,3,27})),
  pollution_server:add_value("Stacja 1", {{2023,3,27},{11,16,10}}, "PM10", 10),
  M2=pollution_server:get_monitor(),
  pollution_server:add_value("Stacja 2", {{2023,3,27},{11,16,11}}, "PM10", 20),

  ?assertMatch({error, _}, pollution_server:get_daily_mean("PM25",{2023,3,27})),
  ?assertMatch({error, _}, pollution:get_daily_mean("PM10",{2023,3,29}, M2)),
  pollution_server:stop().

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
get_area_mean_test() ->
  pollution_server:start(),
  pollution_server:add_station("Stacja 2", {0,2}),
  pollution_server:add_station("Stacja 1", {1,1}),
  pollution_server:add_station("Stacja 3", {3,3}),
  pollution_server:add_value("Stacja 1", {{2023,3,27},{11,16,10}}, "PM10", 10),
  pollution_server:add_value("Stacja 2", {{2023,3,27},{11,16,11}}, "PM10", 20),
  ?assertMatch(15.0, pollution_server:get_area_mean("PM10",{0,1},2)),

  pollution_server:add_value("Stacja 1", {{2024,3,27},{11,16,12}}, "PM10", 30),
  ?assertMatch(20.0, pollution_server:get_area_mean("PM10",{0,1},1)),
  pollution_server:add_value("Stacja 2", {{2023,4,27},{11,16,13}}, "PM10", 20),
  ?assertMatch(20.0, pollution_server:get_area_mean("PM10",{0,1},2)),


  pollution_server:add_value("Stacja 1", {{2023,3,27},{11,16,14}}, "PM25", 100),
  pollution_server:add_value("Stacja 2", {{2023,3,22},{11,16,15}}, "PM25", 220),

  pollution_server:add_value("Stacja 3", {{2023,3,27},{11,16,18}}, "PM10", 1234),
  ?assertMatch(1234.0, pollution_server:get_area_mean("PM10",{2,3},1)),
  ?assertMatch(20.0, pollution_server:get_area_mean("PM10",{0,1},3)),
  pollution_server:add_value("Stacja 3", {{2023,3,29},{11,16,18}}, "PM25", 10),

  ?assertMatch(160.0, pollution_server:get_area_mean("PM25",{0,1},2)),
  ?assertMatch(262.8, pollution_server:get_area_mean("PM10",{0,2},5)),
  ?assertMatch(110.0, pollution_server:get_area_mean("PM25",{0,2},5)),
  pollution_server:stop().

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
get_area_mean_fail_test() ->
  pollution_server:start(),
  pollution_server:add_station("Stacja 2", {2,2}),
  pollution_server:add_station("Stacja 1", {1,1}),
  pollution_server:add_station("Stacja 3", {3,3}),
  ?assertMatch({error, _}, pollution_server:get_area_mean("PM10",{0,0},200)),
  pollution_server:add_value("Stacja 1", {{2023,3,27},{11,16,10}}, "PM10", 10),
  pollution_server:add_value("Stacja 2", {{2023,3,27},{11,16,11}}, "PM10", 20),
  M2=pollution_server:get_monitor(),

  ?assertMatch({error, _}, pollution:get_area_mean("PM3gdfh2",{0,1},2, M2)),
  ?assertMatch({error, _}, pollution:get_area_mean("PM25",{0,0},5, M2)),
  ?assertMatch({error, _}, pollution:get_area_mean("PM10",{5,2},1, M2)),
  pollution_server:stop().