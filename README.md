LagerBunyanFormatter
====================

This is a [Bunyan](https://github.com/trentm/node-bunyan) style JSON formatter for the [Lager](https://github.com/basho/lager) file_backend.

Configuration
=============

This backend is configured as such::

	{lager_file_backend, [
		[{"log/console.log", info, 10485760, "$D0", 5}, {lager_bunyan_formatter, [{name, "my_app_name"}] }],
		[{"log/error.log", error, 10485760, "$D0", 5}, {lager_bunyan_formatter, [{name, "my_app_name"}] }]
	]}

Usage
=====

I would reccomend installing the [Bunyan](https://github.com/trentm/node-bunyan) command line tool to pretty format the log outputs.

Todo
====

 * Remove the ´ejson´ dependancy and build the json in-house.
 * Allow overriding of hostname in configuration.
 * See about custom fields.