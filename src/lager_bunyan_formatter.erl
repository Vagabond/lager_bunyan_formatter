-module(lager_bunyan_formatter).
-author('Jon Gretar Borgthorsson <jongretar@oz.com>').
-include_lib("lager/include/lager.hrl").

-export([format/2, format/3]).

format(Msg, Config, _Colors) -> format(Msg, Config).
format(Msg, []) ->
	format(Msg, [{name,"name_missing"}]);
format(Msg, Config) ->
	{Date, Time} = lager_msg:datetime(Msg),
	{ok, Hostname} = inet:gethostname(),
	Metadata = lager_msg:metadata(Msg),
	Md = serialize_metadata(Metadata, []),
	Body = [
		{v, 0},
		{name, get_metadata(name, Config)},
		{hostname, list_to_binary(Hostname)},
		{pid, list_to_integer(os:getpid())},
		{time, list_to_binary(lists:append([Date,"T",Time,"Z"]))},
		{level, parse_level(lager_msg:severity_as_int(Msg))},
		{msg, list_to_binary(lager_msg:message(Msg))},
		{metadata, Md}],
	case get_metadata(module, Metadata) of
		<<"undefined">> ->
			Result = jsx:encode(Body);
		Module ->
			SrcAttribute = {src, [
				{file, <<Module/binary, <<".erl">>/binary>>},
				{line, get_metadata(line, Metadata)},
				{func, get_metadata(function, Metadata)}
			]},
			Result = jsx:encode([SrcAttribute|Body])
	end,
	[Result,<<"\n">>].


parse_level(?LOG_NONE) -> 10;
parse_level(?DEBUG) -> 20;
parse_level(?INFO) -> 30;
parse_level(?NOTICE) -> 30;
parse_level(?WARNING) -> 40;
parse_level(?ERROR) -> 50;
parse_level(?CRITICAL) -> 50;
parse_level(?ALERT) -> 60;
parse_level(?EMERGENCY) -> 60.

get_metadata(Key, Metadata) ->
    get_metadata(Key, Metadata, <<"undefined">>).

get_metadata(Key, Metadata, Default) ->
    case lists:keyfind(Key, 1, Metadata) of
        false ->
            Default;
        {Key, Value} when is_atom(Value) ->
            list_to_binary(atom_to_list(Value));
        {Key, Value} when is_list(Value) ->
            list_to_binary(Value);
        {Key, Value} when is_integer(Value) ->
            Value;
        {Key, Value}  ->
            list_to_binary(io_lib:format("~p", [Value]))
    end.

serialize_metadata([], Acc) ->
    Acc;
serialize_metadata([{module, _}|T], Acc) ->
    serialize_metadata(T, Acc);
serialize_metadata([{function, _}|T], Acc) ->
    serialize_metadata(T, Acc);
serialize_metadata([{line, _}|T], Acc) ->
    serialize_metadata(T, Acc);
serialize_metadata([{Key, Value}|T], Acc) ->
    serialize_metadata(T, [{Key, get_metadata(Key, [{Key, Value}])}|Acc]).
