# Simple storage

Simple key-value storage written in Erlang. It does not overwrite value if key already exists. It uses AES-256 so be sure to generate your own encryption key.

Compile:

`erlc storage.erl`

Get value:

`erl -noshell -run storage run example.db jXn2r5u8x/A?D(G+KbPeShVmYq3s6v9y KEY1 -s init stop`

Save value:

`erl -noshell -run storage run example.db jXn2r5u8x/A?D(G+KbPeShVmYq3s6v9y KEY2 VALUE2 -s init stop`
