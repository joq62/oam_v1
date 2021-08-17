%%% -------------------------------------------------------------------
%%% @author  : Joq Erlang
%%% @doc: : 
%%% Created : 
%%% -------------------------------------------------------------------
-module(oam).  
-behaviour(gen_server).

%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-include("kube_logger.hrl").
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% Key Data structures
%% 
%% --------------------------------------------------------------------
-record(state, {}).



%% --------------------------------------------------------------------
%% Definitions 
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------





% OaM related
% Admin
-export([
	 new/1,
	 delete/1,
	 connect/1,
	 cl/0,
	 hs/0
	]).

-export([start/0,
	 stop/0,
	 boot/0,
	 ping/0
	]).

%% gen_server callbacks
-export([init/1, handle_call/3,handle_cast/2, handle_info/2, terminate/2, code_change/3]).


%% ====================================================================
%% External functions
%% ====================================================================

%% Asynchrounus Signals

boot()->
    application:start(oam).
%% Gen server functions

start()-> gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).
stop()-> gen_server:call(?MODULE, {stop},infinity).


cl()->
    oam:status_all_clusters().
hs()->
    oam:status_all_hosts().

%%  Admin 

%%---------------------------------------------------------------



%%---------------------------------------------------------------
new(ClusterId)->
    gen_server:call(?MODULE, {new,ClusterId},infinity).
delete(ClusterId)->
    gen_server:call(?MODULE, {delete,ClusterId},infinity).
connect(ClusterId)->
    gen_server:call(?MODULE, {connect,ClusterId},infinity).


ping()-> 
    gen_server:call(?MODULE, {ping},infinity).

%%-----------------------------------------------------------------------

%%----------------------------------------------------------------------


%% ====================================================================
%% Server functions
%% ====================================================================

%% --------------------------------------------------------------------
%% Function: 
%% Description: Initiates the server
%% Returns: {ok, State}          |
%%          {ok, State, Timeout} |
%%          ignore               |
%%          {stop, Reason}
%
%% --------------------------------------------------------------------


init([]) ->
    %% Ensure that ssh are started
    ssh:start(),   
    %% Start logger
    application:set_env(kubelet,monitor_node,node()),
    file:make_dir("logs"),
    application:set_env(kubelet,cluster_id,logs),
    application:start(kubelet),
 %   {ok,_}=monitor:start(),
 %   {ok,_}=kube_logger:start(),
    ?PrintLog(log,"started logger",[?FUNCTION_NAME,?MODULE,?LINE]),
    ?PrintLog(log,"Starting",[?FUNCTION_NAME,?MODULE,?LINE]),
    application:start(etcd),
    ?PrintLog(log,"Successful started",[?FUNCTION_NAME,?MODULE,?LINE]),
    
    {ok, #state{}}.
   
%% --------------------------------------------------------------------
%% Function: handle_call/3
%% Description: Handling call messages
%% Returns: {reply, Reply, State}          |
%%          {reply, Reply, State, Timeout} |
%%          {noreply, State}               |
%%          {noreply, State, Timeout}      |
%%          {stop, Reason, Reply, State}   | (terminate/2 is called)
%%          {stop, Reason, State}            (aterminate/2 is called)
%% --------------------------------------------------------------------

handle_call({new,ClusterId},_From,State) ->
    Reply=rpc:call(node(),oam_lib,new,[ClusterId],10*10*1000),
    {reply, Reply, State};
handle_call({delete,ClusterId},_From,State) ->
    Reply=rpc:call(node(),oam_lib,delete,[ClusterId],10*1000),
    {reply, Reply, State};
handle_call({connect,ClusterId},_From,State) ->
    Reply=rpc:call(node(),oam_lib,connect,[ClusterId],10*1000),
    {reply, Reply, State};


handle_call({ping},_From,State) ->
    Reply={pong,node(),?MODULE},
    {reply, Reply, State};

handle_call({stop}, _From, State) ->
    {stop, normal, shutdown_ok, State};

handle_call(Request, From, State) ->
    Reply = {unmatched_signal,?MODULE,Request,From},
    {reply, Reply, State}.

%% --------------------------------------------------------------------
%% Function: handle_cast/2
%% Description: Handling cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)
%% -------------------------------------------------------------------
    
handle_cast(Msg, State) ->
    io:format("unmatched match cast ~p~n",[{?MODULE,?LINE,Msg}]),
    {noreply, State}.

%% --------------------------------------------------------------------
%% Function: handle_info/2
%% Description: Handling all non call/cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------

handle_info(Info, State) ->
    io:format("unmatched match info ~p~n",[{?MODULE,?LINE,Info}]),
    {noreply, State}.


%% --------------------------------------------------------------------
%% Function: terminate/2
%% Description: Shutdown the server
%% Returns: any (ignored by gen_server)
%% --------------------------------------------------------------------
terminate(_Reason, _State) ->
    ok.

%% --------------------------------------------------------------------
%% Func: code_change/3
%% Purpose: Convert process state when code is changed
%% Returns: {ok, NewState}
%% --------------------------------------------------------------------
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%% --------------------------------------------------------------------
%%% Internal functions
%% --------------------------------------------------------------------
%% --------------------------------------------------------------------
%% Function: 
%% Description:
%% Returns: non
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% Internal functions
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% Function: 
%% Description:
%% Returns: non
%% --------------------------------------------------------------------
