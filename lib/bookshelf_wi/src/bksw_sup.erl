%% @copyright 2012 Opscode, Inc. All Rights Reserved
%% @author Tim Dysinger <dysinger@opscode.com>
%%
%% Licensed to the Apache Software Foundation (ASF) under one or more
%% contributor license agreements.  See the NOTICE file distributed
%% with this work for additional information regarding copyright
%% ownership.  The ASF licenses this file to you under the Apache
%% License, Version 2.0 (the "License"); you may not use this file
%% except in compliance with the License.  You may obtain a copy of
%% the License at http://www.apache.org/licenses/LICENSE-2.0
%%
%% Unless required by applicable law or agreed to in writing, software
%% distributed under the License is distributed on an "AS IS" BASIS,
%% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
%% implied.  See the License for the specific language governing
%% permissions and limitations under the License.

-module(bksw_sup).

-behaviour(supervisor).

-export([start_link/0]).

-export([init/1]).

%%===================================================================
%% API functions
%%===================================================================

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

%%===================================================================
%% Supervisor callbacks
%%===================================================================

init(_Args) ->
    Env = bksw_env:initialize(),
    {pool, Pool} = lists:keyfind(pool, 1, Env),
    RestartStrategy = one_for_one,
    MaxRestarts = 1000,
    MaxSecondsBetweenRestarts = 3600,
    ListenerSup = cowboy:child_spec(bookshelf_http_listener,
                                    Pool, cowboy_tcp_transport, Env,
                                    cowboy_http_protocol, Env),
    {ok,
     {{RestartStrategy, MaxRestarts,
       MaxSecondsBetweenRestarts},
      [ListenerSup]}}.
