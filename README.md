emq_sn
======

MQTT-SN Gateway for The EMQ Broker

Configure Plugin
----------------

File: etc/emq_sn.conf

```erlang
mqtt.sn.port = 1884
```

## Usage

### simple 

examples/simple_example.erl

```erlang
%% create udp socket
{ok, Socket} = gen_udp:open(0, [binary]),

%% connect to broker
Packet = gen_connect_package(ClientId),
ok = gen_udp:send(Socket, ?HOST, ?PORT, Packet),

%% register topic_id
RegisterPacket = gen_register_package(<<"TopicA">>, 1),
ok = gen_udp:send(Socket, ?HOST, ?PORT, RegisterPacket),

%% subscribe
SubscribePacket = gen_subscribe_package(1),
ok = gen_udp:send(Socket, ?HOST, ?PORT, SubscribePacket),

%% publish
PublishPacket = gen_publish_package(1, <<"Payload...">>),
ok = gen_udp:send(Socket, ?HOST, ?PORT, PublishPacket),

%% receive message
receive
    {udp, Socket, _, _, Bin} ->
        case Bin of
            <<_Len:8, ?SN_PUBLISH, _:1, _Flag:8, TopicId:16, MsgId:16, Data/binary>> ->
                io:format("recv publish Qos: ~p, TopicId: ~p, MsgId: ~p, Data: ~p~n", [Qos, TopicId, MsgId, Data]);
            _ ->
                ok
        end
after
    1000 ->
        io:format("Error: receive timeout!~n")
end,

%% disconnect from broker
DisConnectPacket = gen_disconnect_package(),
ok = gen_udp:send(Socket, ?HOST, ?PORT, DisConnectPacket).

```

Load Plugin
-----------

```
./bin/emqttd_ctl plugins load emq_sn
```

License
-------

Apache License Version 2.0

Author
------

Feng Lee <feng@emqtt.io>

testbc  local change

remote change. 123
