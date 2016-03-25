LagerBunyanFormatter
====================

This is a [Bunyan](https://github.com/trentm/node-bunyan) style JSON formatter for the [Lager](https://github.com/basho/lager) file_backend.

Configuration
=============

This backend is configured as such::

  {lager_file_backend, [{file, "log/bunyan.log"}, {level, info}, {formatter, lager_bunyan_formatter}, {formatter_config, [{name, "my_app_name"}]}]}

Usage
=====

I would reccomend installing the [Bunyan](https://github.com/trentm/node-bunyan) command line tool to pretty format the log outputs.

Todo
====

 * Allow overriding of hostname in configuration.
