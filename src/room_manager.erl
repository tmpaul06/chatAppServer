-module(room_manager).
-export([init/0, login/2, lookup_room/1, online/0, logout/1, broadcast/1]).

-record(room, {
  id,
  users = []
  }).

-define(ROOM_TABLE, room_tab).
-define(REVERSE_ROOM_TABLE, reverse_room_tab).



init() ->
  %% Store the created N rooms in an ets table.
  ets:new(?ROOM_TABLE, [set, public, named_table, {keypos, 2}]),
  %% Reverse lookup for Pid -> RoomId.
  ets:new(?REVERSE_ROOM_TABLE, [set, public, named_table, {keypos, 1}]).


%% Insert user with Pid into a room `Room`. If `Room` does not exist, create it.
login(RoomId, Pid) ->
  case lookup_room(RoomId) of
    [] ->
      ets:insert(?ROOM_TABLE, #room{ id = RoomId, users = [Pid]}),
      ets:insert(?REVERSE_ROOM_TABLE, {Pid, RoomId}),
      true;
    [Room] ->
      Users = Room#room.users,
      %% Make sure that Pid is not already present in Users.
      case lists:member(Pid, Users) of
        true ->
          true;
        false ->
          Room2 = Room#room{users = [Pid | Users]},
          ets:insert(?ROOM_TABLE, Room2),
          ets:insert(?REVERSE_ROOM_TABLE, {Pid, RoomId}),
          true
      end
  end.

process_list(X) ->
  [Y] = X, {struct, [{<<"roomId">>, Y#room.id}]}.

online() ->
  Rooms = ets:match(?ROOM_TABLE, '$1'),
      [ process_list(X) || X <- Rooms].


%% Lookup and return room
lookup_room(RoomId) ->
  ets:lookup(?ROOM_TABLE, RoomId).
  

logout(Pid) ->
  case ets:lookup(?REVERSE_ROOM_TABLE, Pid) of
    [] ->
      norecord;
    [RoomId] ->
      case lookup_room(RoomId) of
        [Room] ->
        Users = Room#room.users,
        %% Make sure that Pid is present in Users
        case lists:member(Pid, Users) of
          true ->
            Users1 = lists:delete(Pid, Users),
            ets:insert(?ROOM_TABLE, Room#room{ users = Users1}),
            ets:delete(?REVERSE_ROOM_TABLE, Pid);
          false ->
          norecord
        end;
        [] ->
          norecord
      end
  end.

broadcast(RoomId) ->
  case lookup_room(RoomId) of
    [] ->
      norecord;
    [Room] ->
      io:format("Room: ~p~n", [Room]),
      Room#room.users
  end.