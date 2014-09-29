-module(bpws_app).  
-behaviour(application).  
-export([start/2, stop/1]).  
  
start(_StartType, _Port) ->  
  Dispatch = cowboy_router:compile([  
      {'_', [  
        {"/", cowboy_static, {priv_file, bpws, "index.html"}},  
        {"/websocket", bpws_handler, []}  
      ]}  
    ]),
    io:format("Initializing room and user manager~n"),
    user_manager:init(),
    room_manager:init(),
    {ok, _} = cowboy:start_http(http, 200, [{port, 8080}, {max_connections, infinity}],  
        [{env, [{dispatch, Dispatch}]}]),  
      bpws_sup:start_link().  
  
stop(_State) ->  
    ok.