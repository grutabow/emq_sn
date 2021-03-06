%%--------------------------------------------------------------------
%% Copyright (c) 2016-2017 Feng Lee <feng@emqtt.io>. All Rights Reserved.
%%
%% Licensed under the Apache License, Version 2.0 (the "License");
%% you may not use this file except in compliance with the License.
%% You may obtain a copy of the License at
%%
%%     http://www.apache.org/licenses/LICENSE-2.0
%%
%% Unless required by applicable law or agreed to in writing, software
%% distributed under the License is distributed on an "AS IS" BASIS,
%% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%% See the License for the specific language governing permissions and
%% limitations under the License.
%%--------------------------------------------------------------------

-module(emq_sn_registry_SUITE).

-author("Feng Lee <feng@emqtt.io>").

-include_lib("eunit/include/eunit.hrl").
-include("emq_sn.hrl").

-import(emq_sn_registry, [start_link/0, register_topic/2, unregister_topic/1, stop/0, lookup_topic/2, lookup_topic_id/2]).

-compile(export_all).

all() -> [register_topic_test, register_topic_test2, register_topic_test3, register_topic_test4, register_topic_test4].


init_per_suite(Config) ->
    application:start(lager),
    Config.

end_per_suite(_Config) ->
    application:stop(lager).



register_topic_test(_Config) ->
    start_link(),
    ?assertEqual(1, register_topic(<<"ClientId">>, <<"Topic1">>)),
    ?assertEqual(2, register_topic(<<"ClientId">>, <<"Topic2">>)),
    ?assertEqual(<<"Topic1">>, lookup_topic(<<"ClientId">>, 1)),
    ?assertEqual(<<"Topic2">>, lookup_topic(<<"ClientId">>, 2)),
    ?assertEqual(1, lookup_topic_id(<<"ClientId">>, <<"Topic1">>)),
    ?assertEqual(2, lookup_topic_id(<<"ClientId">>, <<"Topic2">>)),
    unregister_topic(<<"ClientId">>),
    ?assertEqual(undefined, lookup_topic(<<"ClientId">>, 1)),
    ?assertEqual(undefined, lookup_topic(<<"ClientId">>, 2)),
    ?assertEqual(undefined, lookup_topic_id(<<"ClientId">>, <<"Topic1">>)),
    ?assertEqual(undefined, lookup_topic_id(<<"ClientId">>, <<"Topic2">>)),
    stop().


register_topic_test2(_Config) ->
    start_link(),
    ?assertEqual(1, register_topic(<<"ClientId">>, <<"Topic1">>)),
    ?assertEqual(2, register_topic(<<"ClientId">>, <<"Topic2">>)),
    ?assertEqual(1, register_topic(<<"ClientId">>, <<"Topic1">>)),
    ?assertEqual(<<"Topic1">>, lookup_topic(<<"ClientId">>, 1)),
    ?assertEqual(<<"Topic2">>, lookup_topic(<<"ClientId">>, 2)),
    ?assertEqual(1, lookup_topic_id(<<"ClientId">>, <<"Topic1">>)),
    ?assertEqual(2, lookup_topic_id(<<"ClientId">>, <<"Topic2">>)),
    ?assertEqual(undefined, lookup_topic_id(<<"ClientId">>, <<"Topic3">>)),
    unregister_topic(<<"ClientId">>),
    ?assertEqual(undefined, lookup_topic(<<"ClientId">>, 1)),
    ?assertEqual(undefined, lookup_topic(<<"ClientId">>, 2)),
    ?assertEqual(undefined, lookup_topic_id(<<"ClientId">>, <<"Topic1">>)),
    ?assertEqual(undefined, lookup_topic_id(<<"ClientId">>, <<"Topic2">>)),
    stop().


register_topic_test3(_Config) ->
    io:format("register_topic_test3 will take long long time ...~n"),
    start_link(),
    register_a_lot(1, 16#fffe),
    io:format("start overflow~n"),
    ?assertEqual(undefined, register_topic(<<"ClientId">>, <<"TopicABC">>)),
    timer:sleep(500),
    ?assertEqual(1, lookup_topic_id(<<"ClientId">>, <<"Topic1">>)),
    ?assertEqual(2, lookup_topic_id(<<"ClientId">>, <<"Topic2">>)),
    unregister_topic(<<"ClientId">>),
    ?assertEqual(undefined, lookup_topic(<<"ClientId">>, 1)),
    ?assertEqual(undefined, lookup_topic(<<"ClientId">>, 2)),
    ?assertEqual(undefined, lookup_topic_id(<<"ClientId">>, <<"Topic1">>)),
    ?assertEqual(undefined, lookup_topic_id(<<"ClientId">>, <<"Topic2">>)),
    stop().


register_topic_test4(_Config) ->
    start_link(),
    ?assertEqual(1, register_topic(<<"ClientId">>, <<"TopicA">>)),
    ?assertEqual(2, register_topic(<<"ClientId">>, <<"TopicB">>)),
    ?assertEqual(3, register_topic(<<"ClientId">>, <<"TopicC">>)),
    unregister_topic(<<"ClientId">>),
    ?assertEqual(1, register_topic(<<"ClientId">>, <<"TopicD">>)),
    stop().


register_topic_test5(_Config) ->
    start_link(),
    ?assertEqual(wildcard_topic, register_topic(<<"ClientId">>, <<"/TopicA/#">>)),
    ?assertEqual(wildcard_topic, register_topic(<<"ClientId">>, <<"/+/TopicB">>)),
    stop().


register_a_lot(Max, Max) ->
    TopicString = io_lib:format("Topic~p", [Max]),
    ?assertEqual(Max, register_topic(<<"ClientId">>, list_to_binary(TopicString))),
    ok;
register_a_lot(N, Max) ->
    case (N rem 1024) of
        0 -> io:format("register_a_lot N=~p~n", [N]);
        _ -> ok
    end,
    TopicString = io_lib:format("Topic~p", [N]),
    ?assertEqual(N, register_topic(<<"ClientId">>, list_to_binary(TopicString))),
    register_a_lot(N+1, Max).


