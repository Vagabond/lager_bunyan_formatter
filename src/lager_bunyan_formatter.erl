-module(lager_bunyan_formatter).
-include_lib("lager/include/lager.hrl").

-export([format/2]).

format(Msg, []) ->
	format(Msg, [{name,"name_missing"}]);
format(Msg, Config) ->
	{Date, Time} = lager_msg:timestamp(Msg),
	{ok, Hostname} = inet:gethostname(),
	Metadata = lager_msg:metadata(Msg),
	Body = [
		{v, 0},
		{name, get_metadata(name, Config)},
		{hostname, list_to_binary(Hostname)},
		{pid, list_to_binary(os:getpid())},
		{time, list_to_binary(lists:append([Date,"T",Time,"Z"]))},
		{level, parse_level(lager_msg:severity_as_int(Msg))},
		{msg, list_to_binary(lager_msg:message(Msg))}
	],
	case get_metadata(module, Metadata) of
		<<"undefined">> ->
			Result = ejson:encode({Body});
		Module ->
			SrcAttribute = {src, {[
				{file, <<Module/binary, <<".erl">>/binary>>},
				{line, get_metadata(line, Metadata)},
				{func, get_metadata(function, Metadata)}
			]}},
			Result = ejson:encode({[SrcAttribute|Body]})
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
        {Key, _}  ->
            <<"unknow_value">>
    end.
