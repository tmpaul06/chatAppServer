-module(bpws_handler).
-behaviour(cowboy_websocket_handler).

-export([init/3, websocket_init/3, websocket_handle/3, websocket_info/3, websocket_terminate/3]).

init({tcp, http}, _Req, _Opts) ->
  {upgrade, protocol, cowboy_websocket}.

websocket_init(_TransportName, Req, _Opts) ->
  io:format("Initializing websocket connection ~n"),
  {ok, Req, undefined_state}.

websocket_handle({text, Msg}, Req, State) ->
  io:format("Received Msg :~p~n", [Msg]),
  {struct, Decoded} = mochijson2:decode(Msg),
  io:format("Decoded message ~p~n", [Decoded]),
  Event = proplists:get_value(<<"event">>, Decoded),
  case Event of

     undefined -> {reply, {text, <<"ok">>}, Req, State, hibernate};
     _ ->
            ReplyText = event_manager:handle_event(Event, Decoded),
            {reply, {text, ReplyText}, Req, State, hibernate}

     %%[{<<"event">>, <<"broadcast">>}, { Room, ReceivedPeg}, {<<"message">>, Message}] ->
     %%   Users = room_manager:broadcast(binary_to_integer(Room)),
     %%   UserLength1 = erlang:length(Users) + 1,
     %%   Peg = binary_to_integer(ReceivedPeg),
     %%   if
     %%     Peg == UserLength1 ->
     %%       FormattedMessage = mochijson2:encode({struct, [{data, integer_to_binary(1)}, %%{message, Message}]}),
     %%       [ X ! {multicast, FormattedMessage} || X <- Users], 
     %%       {ok, Req, State, hibernate};
     %%     true ->
     %%       FormattedMessage = mochijson2:encode({struct, [{data, ReceivedPeg}, {message, %%Message}]}),
     %%       [ X ! {multicast, FormattedMessage} || X <- Users], 
     %%      {ok, Req, State, hibernate}
     %%   end;

     %% Private Message
     

  end;

websocket_handle(_Any, Req, State) ->
  {ok, Req, State}.

websocket_info({timeout, _Ref, Msg}, Req, State) ->
  {reply, {text, Msg}, Req, State};

websocket_info({multicast, Message}, Req, State) ->
  {reply, {text, Message}, Req, State, hibernate};

websocket_info(_Info, Req, State) ->
  {ok, Req, State, hibernate}.

websocket_terminate(_Reason, _Req, _State) ->
  io:format("Terminated ~p~n", [self()]),
  user_manager:logout(self()),
  room_manager:logout(self()),
  ok.