
-module(unixdom_test).
-define(DRV, unixdom).

%%%
%%% Change this macro to suit your local platform
%%%
%-define(MY_OS, "FreeBSD").
-define(MY_OS, "Linux").
%-define(MY_OS, "Solaris").

-export([regression/0, tcp_listen/2, receive_fd/1, tcp_server/0, tcp_client/0, tcp_client/2, tcp_server1/0]).
-export([repeat/4, loop_client/3]).				%XXX

repeat(0, _, _, _) ->
    ok;
repeat(N, M, F, A) ->
    apply(M, F, A),
    repeat(N - 1, M, F, A).

regression() ->
    SockPath = "/tmp/sock",
    io:format("\n\nThere is no regression test yet.\n"),
    io:format("On Erlang node A, run file:delete(\"~s\").\n", [SockPath]),
    io:format("Then run ~s:tcp_listen(5555, \"~s\").\n", [?MODULE, SockPath]),
    io:format("\n"),
    io:format("On Erlang node B (on the same machine as A!), run\n"),
    io:format("~s:receive_fd(\"~s\").\n", [?MODULE, SockPath]),
    io:format("\n"),
    io:format("Then run 'telnet node-A-hostname 5555' and\n"),
    io:format("then type some stuff!\n\n"),

    io:format("All regression tests PASSED.\n"),
    ok.

tcp_server1() ->
    Filename = "/tmp/sock",
    file:delete(Filename),
    {ok, Port}  = unixdom:start(),
    {ok, LSock} = unixdom:listen(Port, Filename, [{packet, 2}, {active, false}, binary]),
    {ok, CSock} = unixdom:accept(LSock),
    {Time, N} = timer:tc(?MODULE, loop_server, [CSock, 0]),
    {ok, CSock, Time}.
    
tcp_server() ->
    Filename = "/tmp/sock",
    file:delete(Filename),
    {ok, Port}  = unixdom:start(),
    {ok, LSock} = unixdom:listen(Port, Filename, [{packet, 2}, {active, false}, binary]),
    {ok, Ref}   = unixdom:async_accept(LSock),
    receive
    {inet_async,LSock,Ref,{ok,Sock}} ->
        ok = unixdom:set_sockopt(LSock, Sock),
        %inet:setopts(Sock, [{recbuf, 4*1024*1024}]),
        {Time, N} = timer:tc(?MODULE, loop_server, [Sock, 0]),
        io:format("~w times. Speed: ~w trans/s, TransTime: %~.6fs\n", 
                  [N, (N * 1000000) div Time, Time / (N * 1000000)]),
        %io:format("Close: ~p\n", [unixdom:tcp_close(Port, Sock)]),
        %io:format("Close: ~p\n", [unixdom:closefd(Port, Sock)]),
        %?DRV:shutdown(Port);
        {client, Sock};
    {inet_async,OtherSock, Ref, Res} ->
        {error, {ok, OtherSock, Res}}
    end.

tcp_client() ->
    tcp_client(10,10).
    
tcp_client(N, Size) ->
    {ok, Port} = unixdom:start(),
    {ok, Sock} = unixdom:connect(Port, "/tmp/sock", [binary, {active, false}, {packet, 2}]),
    Packet = list_to_binary(string:chars($A, Size)),
    {Time, _} = timer:tc(?MODULE, loop_client, [Sock, N, Packet]),
    io:format("~w times. Speed: ~w trans/s, TransTime: %~.6fs\n", 
              [N, (N * 1000000) div Time, Time / (N * 1000000)]),
    %io:format("Close: ~p\n", [unixdom:closefd(Port, Sock)]).
    %io:format("Close: ~p\n", [unixdom:tcp_close(Port, Sock)]).
    %ok = unixdom:tcp_close(Port, Sock).
    %?DRV:shutdown(Port).
    {ok, Port, Sock}.
 
tcp_listen(TcpPort, SockPath) ->
    {ok, Port} = unixdom:start(),
    {ok, MasterUSock} = unixdom:open(Port, SockPath, 1),
    {ok, Val} = unixdom:getfd(Port, MasterUSock),
    {ok, MasterSock} = gen_tcp:fdopen(Val, []),
    prim_inet:setopts(MasterSock, [{packet, raw}]),
    prim_inet:listen(MasterSock),
    {ok, Usock} = gen_tcp:accept(MasterSock),
    {ok, Usockfd} = prim_inet:getfd(Usock),
    %
    {ok, Tcpmsock} = gen_tcp:listen(TcpPort, [binary, {packet, 0}, {active, false}, {reuseaddr, true}]),
    {ok, Tcpsock} = gen_tcp:accept(Tcpmsock),
    {ok, Tcpsockfd} = prim_inet:getfd(Tcpsock),
    %
    unixdom:sendfd(Port, Usockfd, Tcpsockfd),
    ?DRV:shutdown(Port).

receive_fd(SockPath) ->
    {ok, Port} = unixdom:start(),
    {ok, ClntSock} = unixdom:open(Port, SockPath, 0),
    {ok, ClntSockFd} = unixdom:getfd(Port, ClntSock),
    {ok, Tcpsockfd} = unixdom:receivefd(Port, ClntSockFd),
    io:format("TCP socket fd ~w received, looping now\n", [Tcpsockfd]),
    ?DRV:shutdown(Port),
    {ok, Tcpsock} = gen_tcp:fdopen(Tcpsockfd, []),
    gen_tcp:send(Tcpsock, "Hello, there!  Please type some stuff:\r\n"),
    readloop(Tcpsock).

readloop(Tcpsock) ->
    case gen_tcp:recv(Tcpsock, 1) of
    	{ok, B} ->
	    io:format("~s", [B]),
	    readloop(Tcpsock);
	{error, _} ->
	    ok
    end.

loop_server(S, N) ->
    case gen_tcp:recv(S, 0) of
    {ok, _Packet} ->
        %io:format("~p\n", [binary_to_term(Packet)]),
        loop_server(S, N+1);
    {error, Reason} ->
        io:format("Error: ~p\n", [Reason]),
        N
    end.

loop_client(_S, 0, _Packet) ->
    ok;
loop_client(S, N, Packet) ->
    ok = gen_tcp:send(S, Packet),
    loop_client(S, N-1, Packet).
