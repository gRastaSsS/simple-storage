-module(storage).
-author("voismager").

%% API
-export([run/1]).

run([FileName, IKey, Key]) ->
  crypto:start(),
  IVec = <<0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0>>,
  Text = read(FileName, list_to_binary(IKey), IVec),
  io:format([find(Key, fun line_to_key_value/1, Text)]);

run([FileName, IKey, Key, Value]) ->
  crypto:start(),
  IVec = <<0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0>>,
  Text = read(FileName, list_to_binary(IKey), IVec),
  ModifiedText = put(Key, Value, Text, fun line_to_key_value/1, fun key_value_to_line/2),
  write(FileName, ModifiedText, list_to_binary(IKey), IVec).

line_to_key_value(Line) -> string:split(Line, ":", leading).

key_value_to_line(Key, Value) -> Key ++ ":" ++ Value.


read(FileName, IKey, IVec) ->
  {ok, Binary} = file:read_file(FileName),
  Text = binary_to_list(crypto:block_decrypt(aes_cbc256, IKey, IVec, Binary)),
  lists:filter(fun(Elem) -> Elem =/= 0 end, Text).


write(FileName, Text, IKey, IVec) ->
  Encrypted = crypto:block_encrypt(aes_cbc256, IKey, IVec, pad_to16(list_to_binary(Text))),
  {ok, Device} = file:open(FileName, [write]),
  file:write(Device, Encrypted).


find(_Key, _LineToKeyValue, []) -> not_found;

find(Key, LineToKeyValue, Lines) ->
  [Line, OtherLines] = string:split(Lines, "\n", leading),
  [DecryptedKey, DecryptedValue] = LineToKeyValue(Line),
  case DecryptedKey == Key of
    true -> DecryptedValue;
    false -> find(Key, LineToKeyValue, OtherLines)
  end.


put(Key, Value, Text, LineToKeyValue, KeyValueToLine) ->
  case find(Key, LineToKeyValue, Text) of
    not_found -> Text ++ KeyValueToLine(Key, Value) ++ "\n";
    _Found -> Text
  end.


pad_to16(Bin) ->
  case (size(Bin) rem 16) of
    0 -> Bin;
    Pad -> <<Bin/binary, 0:((16-Pad)*8)>>
  end.