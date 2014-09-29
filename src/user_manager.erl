-module(user_manager).
-export([init/0, login/4, lookup_user/1, broadcast/3, logout/1, online/0, multicast/0]).

-record(user, {
  id,
  pid,
  firstName,
  lastName
  }).

-define(USER_TABLE, user_tab).

init() ->

  ets:new(?USER_TABLE, [set, public, named_table, {keypos, 3}]).



%% Insert user with Pid into a room `Room`. If `Room` does not exist, create it.
login(Id, Pid, FirstName, LastName) ->
  case lookup_user(Pid) of
    [] ->
      ets:insert(?USER_TABLE, #user{ id = Id, pid = Pid, firstName = FirstName, lastName = LastName}),
        true;
    [_User] when is_pid(Pid) ->
        true
  end.


%% Lookup and return room
lookup_user(Pid) ->
  ets:lookup(?USER_TABLE, Pid).

lookup_user_mapping(Id) ->
  case ets:match(?USER_TABLE, {user,Id, '$1','_','_'}) of
    [X] -> X;
    [] -> []
  end.


logout(Pid) ->
  case lookup_user(Pid) of
    [] -> 
      ok;
    [User] ->
      UserId = User#user.id,
      FirstName = User#user.firstName,
      LastName = User#user.lastName,
      AllPids = multicast(),
      [X ! {multicast, mochijson2:encode([{<<"event">>, <<"logout-broadcast">>},{<<"userId">>, UserId},{<<"firstName">>, FirstName}, {<<"lastName">>, LastName}])} || X <- AllPids],
      ets:delete(?USER_TABLE, Pid)
  end.

broadcast(FromId, ToId, Message) ->
  %% Lookup From and To Id`s.
  case lookup_user_mapping(ToId) of
    [] ->
       norecord;
    [ToPid] ->
      ToPid ! {multicast, mochijson2:encode([{<<"event">>, <<"private-message">>},{<<"from">>, FromId},{<<"message">>, Message}])}
  end.

process_record_list(X) ->
  [Y] = X, {struct, [{<<"userId">>, Y#user.id}, {<<"firstName">>, Y#user.firstName},{<<"lastName">>, Y#user.lastName}]}.

online() ->
  Us = ets:match(?USER_TABLE, '$1'),
  NewUs = [ process_record_list(X) || X <- Us],
  NewUs.

process_multicast_list(X) ->
  [Y] = X, Y#user.pid.

multicast() ->
  Users =  ets:match(?USER_TABLE, '$1'),
  [ process_multicast_list(X) || X <- Users ].