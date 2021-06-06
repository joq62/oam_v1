%%% -------------------------------------------------------------------
%%% @author  : Joq Erlang
%%% @doc: : 
%%% Manage Computers
%%% Install Cluster
%%% Install cluster
%%% Data-{HostId,Ip,SshPort,Uid,Pwd}
%%% available_hosts()-> [{HostId,Ip,SshPort,Uid,Pwd},..]
%%% install_leader_host({HostId,Ip,SshPort,Uid,Pwd})->ok|{error,Err}
%%% cluster_status()->[{running,WorkingNodes},{not_running,NotRunningNodes}]

%%% Created : 
%%% -------------------------------------------------------------------
-module(oam).  
-behaviour(gen_server).

%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
 
%% --------------------------------------------------------------------
-define(HostFile,"glurk").
-define(HostConfigDir,"g").
-define(GitHostConfigCmd,"g").
%% --------------------------------------------------------------------
%% Key Data structures
%% 
%% --------------------------------------------------------------------
-record(state, {cookie,cluster_name}).



%% --------------------------------------------------------------------
%% Definitions 
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------





% OaM related
-export([
	 load_config/0,
	 read_config/0,
	 status_hosts/0,
	 status_slaves/0,
	 start_masters/1,
	 start_slaves/3,
	 start_slaves/1,
	 running_hosts/0,
	 running_slaves/0,
	 missing_hosts/0,
	 missing_slaves/0
	]).

-export([
	 create/4,
	 install/0,
	 available_hosts/0

	]).


-export([boot/0,
	 start_app/5,
	 stop_app/4,
	 app_status/2
	]).

-export([start/0,
	 stop/0,
	 ping/0
	]).

%% gen_server callbacks
-export([init/1, handle_call/3,handle_cast/2, handle_info/2, terminate/2, code_change/3]).


%% ====================================================================
%% External functions
%% ====================================================================

%% Asynchrounus Signals

boot()->
    application:start(?MODULE).

%% Gen server functions

start()-> gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).
stop()-> gen_server:call(?MODULE, {stop},infinity).


%%---------------------------------------------------------------
create(NumMasters,Hosts,Name,Cookie)->
    gen_server:call(?MODULE, {create,NumMasters,Hosts,Name,Cookie},infinity).
delete(Name)->
    gen_server:call(?MODULE, {delete,Name},infinity).    

%%---------------------------------------------------------------
running_hosts()->
       gen_server:call(?MODULE, {running_hosts},infinity).
running_slaves()->
       gen_server:call(?MODULE, {running_slaves},infinity).
missing_hosts()->
       gen_server:call(?MODULE, {missing_hosts},infinity).
missing_slaves()->
       gen_server:call(?MODULE, {missing_slaves},infinity).

load_config()-> 
    gen_server:call(?MODULE, {load_config},infinity).
read_config()-> 
    gen_server:call(?MODULE, {read_config},infinity).
status_hosts()-> 
    gen_server:call(?MODULE, {status_hosts},infinity).
status_slaves()-> 
    gen_server:call(?MODULE, {status_slaves},infinity).

start_masters(HostIds)->
    gen_server:call(?MODULE, {start_masters,HostIds},infinity).
start_slaves(HostIds)->
    gen_server:call(?MODULE, {start_slaves,HostIds},infinity).

start_slaves(HostId,SlaveNames,ErlCmd)->
    gen_server:call(?MODULE, {start_slaves,HostId,SlaveNames,ErlCmd},infinity).
    
%% old
install()-> 
    gen_server:call(?MODULE, {install},infinity).
available_hosts()-> 
    gen_server:call(?MODULE, {available_hosts},infinity).

start_app(ApplicationStr,Application,CloneCmd,Dir,Vm)-> 
    gen_server:call(?MODULE, {start_app,ApplicationStr,Application,CloneCmd,Dir,Vm},infinity).

stop_app(ApplicationStr,Application,Dir,Vm)-> 
    gen_server:call(?MODULE, {stop_app,ApplicationStr,Application,Dir,Vm},infinity).

app_status(Vm,Application)-> 
    gen_server:call(?MODULE, {app_status,Vm,Application},infinity).
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






handle_call({start_slaves,HostId,SlaveNames,ErlCmd},_From,State) ->
    Master=list_to_atom("master"++"@"++HostId),
    Reply=rpc:call(node(),cluster_lib,start_slaves,[Master,HostId,SlaveNames,ErlCmd],2*5000),
    {reply, Reply, State};


handle_call({read_config},_From,State) ->
    Reply=rpc:call(node(),cluster_lib,read_config,[?HostFile],5000),
    {reply, Reply, State};

handle_call({load_config},_From,State) ->
    Reply=rpc:call(node(),cluster_lib,load_config,[?HostConfigDir,?HostFile,?GitHostConfigCmd],2*5000),
   
    {reply, Reply, State};


handle_call({install},_From,State) ->
    Reply=rpc:call(node(),cluster_lib,install,[],2*5000),
    {reply, Reply, State};


handle_call({start_app,ApplicationStr,Application,CloneCmd,Dir,Vm},_From,State) ->
    Reply=cluster_lib:start_app(ApplicationStr,Application,CloneCmd,Dir,Vm),
    {reply, Reply, State};
handle_call({stop_app,ApplicationStr,Application,Dir,Vm},_From,State) ->
    Reply=cluster_lib:stop_app(ApplicationStr,Application,Dir,Vm),
    {reply, Reply, State};
handle_call({app_status,Vm,Application},_From,State) ->
    Reply=cluster_lib:app_status(Vm,Application),
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
