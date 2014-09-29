-module(event_manager).
-export([handle_event/2]).


handle_event(EventName, Data) ->
  case EventName of

    <<"login">> ->
        RequestId = proplists:get_value(<<"id">>, Data),
        UserId = proplists:get_value(<<"userId">>, Data),
        FirstName = proplists:get_value(<<"firstName">>, Data),
        LastName = proplists:get_value(<<"lastName">>, Data),
        %% Login
        user_manager:login(UserId, self(), FirstName, LastName),
        %% Broadcast to everyone else that you are online
        AllPids = user_manager:multicast(),

        [ X ! {multicast, mochijson2:encode([{<<"event">>, <<"login-broadcast">>},{<<"userId">>, UserId},{<<"firstName">>, FirstName}, {<<"lastName">>, LastName}])} || X <- AllPids],

        mochijson2:encode([{<<"id">>, RequestId}, {<<"status">>, <<"success">>}]);

     <<"logout">> ->
        RequestId = proplists:get_value(<<"id">>, Data),
        %% Login
        user_manager:logout(self()), mochijson2:encode([{<<"id">>, RequestId}, {<<"status">>, <<"success">>}]);

    <<"pm">> ->
        RequestId = proplists:get_value(<<"id">>, Data),
        From = proplists:get_value(<<"from">>, Data),
        To = proplists:get_value(<<"to">>, Data),
        Msg = proplists:get_value(<<"message">>, Data),        
        io:format("Message from ~p to ~p : ~p", [From, To, Msg]),
        case user_manager:broadcast(From, To, Msg) of
          norecord ->
            mochijson2:encode([{<<"id">>, RequestId}, {<<"status">>, <<"error">>}]);
          _ ->
            mochijson2:encode([{<<"id">>, RequestId}, {<<"status">>, <<"success">>}])
        end;
      <<"online">> ->
        RequestId = proplists:get_value(<<"id">>, Data),
        OnlineUsers = user_manager:online(),
        io:format("Original: ~p~n", [OnlineUsers]),
        IdAdded = lists:append([{<<"id">>, RequestId}, {<<"status">>,<<"success">>}], [{<<"users">>, {array,OnlineUsers}}]),
        io:format("Response ~p~n", [IdAdded]),
        mochijson2:encode(IdAdded);

      <<"create-room">> ->
        RequestId = proplists:get_value(<<"id">>, Data),
        RoomId = proplists:get_value(<<"roomId">>, Data),
        room_manager:login(RoomId, self()),
        AllPids = user_manager:multicast(),
        [ X ! {multicast, mochijson2:encode([{<<"event">>, <<"room-created">>},{<<"roomId">>, RoomId}])} || X <- AllPids],
        mochijson2:encode([{<<"id">>, RequestId}, {<<"status">>, <<"success">>}]);

      <<"join-room">> ->
        RequestId = proplists:get_value(<<"id">>, Data),
        RoomId = proplists:get_value(<<"roomId">>, Data),
        room_manager:login(RoomId, self()),
        mochijson2:encode([{<<"id">>, RequestId}, {<<"status">>, <<"success">>}]);

      <<"online-rooms">> ->
        RequestId = proplists:get_value(<<"id">>, Data),
        AllRooms = room_manager:online(),
        io:format("Original: ~p~n", [AllRooms]),
        IdAdded = lists:append([{<<"event">>, <<"online-rooms">> }], [{<<"rooms">>, {array,AllRooms}}]),
        io:format("Response ~p~n", [IdAdded]),
        mochijson2:encode(IdAdded);

      <<"room-broadcast">> ->
        RequestId = proplists:get_value(<<"id">>, Data),
        RoomId = proplists:get_value(<<"roomId">>, Data),
        From   = proplists:get_value(<<"from">>, Data),
        SenderId = proplists:get_value(<<"senderId">>, Data),
        AllPids = room_manager:broadcast(RoomId),
        Msg = proplists:get_value(<<"message">>, Data),
        [ X ! {multicast, mochijson2:encode([{<<"event">>, <<"room-message">>},{<<"roomId">>, RoomId}, {<<"message">>, Msg}, {<<"from">>, From}, {<<"senderId">>, SenderId}])} || X <- AllPids],
        mochijson2:encode([{<<"id">>, RequestId}, {<<"status">>, <<"success">>}])  
  end.