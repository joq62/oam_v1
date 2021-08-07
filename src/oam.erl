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
	 start_app/2,
	 apps/0,
	 cl/0,
	 hs/0
	]).
-export([
	 install/1,
	 status_all_clusters/0
	]).


-export([
	 status_hosts/0,
	 cluster_info/0,
	 host_info/0,
	 catalog_info/0
	]).

% Operate
-export([
	 create_cluster/1,
	 create_cluster/4,
	 
	 status_cluster/1
	]).

-export([
       
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


start_app(AppId,CliusterId)->
    gen_server:call(?MODULE, {start_app,AppId,CliusterId},infinity).

cl()->
    oam:status_all_clusters().
hs()->
    oam:status_all_hosts().

apps()->
    gen_server:call(?MODULE, {apps},infinity).  
%%  Admin 
install(ClusterId)->
    gen_server:call(?MODULE, {install,ClusterId},infinity).    

status_hosts()->
    gen_server:call(?MODULE, {status_hosts},infinity).
cluster_info()->
    gen_server:call(?MODULE, {cluster_info},infinity).   
host_info()->
    gen_server:call(?MODULE, {host_info},infinity).  
catalog_info()->
    gen_server:call(?MODULE, {catalog_info},infinity).  

%%---------------------------------------------------------------

create_cluster(ClusterName,NumControllers,Hosts,Cookie)->
    gen_server:call(?MODULE, {create_cluster,ClusterName,Cookie,Hosts,NumControllers},infinity).
create_cluster(ClusterId)->
    gen_server:call(?MODULE, {create_cluster,ClusterId},infinity).
delete_cluster(ClusterId)->
    gen_server:call(?MODULE, {delete,ClusterId},infinity).
status_all_clusters()->    
    gen_server:call(?MODULE, {status_all_clusters},infinity).
status_cluster(ClusterId)->
    gen_server:call(?MODULE, {status_cluster,ClusterId},infinity).
    



%%---------------------------------------------------------------

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
    %% Start logger
    application:set_env(kubelet,monitor_node,node()),
    {ok,_}=monitor:start(),
    {ok,_}=kube_logger:start(),
    ?PrintLog(log,"started logger",[?FUNCTION_NAME,?MODULE,?LINE]),
    % 2. load mensia with pod specs 
    ?PrintLog(log,"1/10  Start etcd ",[?FUNCTION_NAME,?MODULE,?LINE]),
    ok=application:start(etcd),
   % ?PrintLog(log,"2/10 ",[?FUNCTION_NAME,?MODULE,?LINE]),
   
    % 3. Create start Node
    {ok,ClusterIdAtom}=application:get_env(cluster_id),
    ClusterId=atom_to_list(ClusterIdAtom),
    {ok,StartHostIdAtom}=application:get_env(start_host_id),
    StartHostId=atom_to_list(StartHostIdAtom),
    ?PrintLog(log,"3/10 Environment variables",["clusterId= "++ClusterId,
					       "start host = "++StartHostId,?FUNCTION_NAME,?MODULE,?LINE]),
    
    ?PrintLog(log,"4/10 Start/re-start cluster",[ClusterId,?FUNCTION_NAME,?MODULE,?LINE]),
    ssh:start(),
    ClusterDelete=cluster:delete(ClusterId),
    ?PrintLog(log,"5/10 ClusterDelete = ",[ClusterDelete,?FUNCTION_NAME,?MODULE,?LINE]),
    ClusterCreate=cluster:create(ClusterId),
    ?PrintLog(log,"6/10 ClusterCreate = ",[ClusterCreate,?FUNCTION_NAME,?MODULE,?LINE]),

    ?PrintLog(debug,"6.5 /10 sd:all() = ",[sd:all(),?FUNCTION_NAME,?MODULE,?LINE]),

    ClusterStatus=cluster:status_clusters(ClusterId),
    ?PrintLog(log,"7/10 ClusterStatus = ",[ClusterStatus,?FUNCTION_NAME,?MODULE,?LINE]),
    {{running,[{ClusterId,RunningNodes}]},_}=ClusterStatus,

    ?PrintLog(log,"8/10 Start app  = ",["etcd",?FUNCTION_NAME,?MODULE,?LINE]),
    StartPodEtcd=kubelet_lib:start_app("etcd",ClusterId,node(),"c1_varmdo"),
    ?PrintLog(log,"8/10 Result Start etcd  = ",[StartPodEtcd,?FUNCTION_NAME,?MODULE,?LINE]),


    ?PrintLog(log,"8.5/10 Start app  = ",["kubelet",?FUNCTION_NAME,?MODULE,?LINE]),
    StartPodKubelet=kubelet_lib:start_app("kubelet",ClusterId,node(),"c1_varmdo"),
    ?PrintLog(log,"8.5/10 Result Start kubelet  = ",[StartPodKubelet,?FUNCTION_NAME,?MODULE,?LINE]),

    ?PrintLog(log,"9/10 Start app  = ",["controller",?FUNCTION_NAME,?MODULE,?LINE]),
    StartPodController=kubelet_lib:start_app("controller",ClusterId,node(),"c1_varmdo"),
    ?PrintLog(log,"9/10 Result Start controller  = ",[StartPodController,?FUNCTION_NAME,?MODULE,?LINE]),
    ?PrintLog(log,"10/10 started",[?MODULE]),
    
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

handle_call({start_app,AppId,ClusterId},_From,State) ->
    Reply=kubelet_lib:start_app("controller",ClusterId),
    {reply, Reply, State};


handle_call({apps},_From,State) ->
    Nodes=[node()|nodes()],
    Reply=[{Node,rpc:call(Node,application,which_applications,[],5*1000)}||Node<-Nodes],
    {reply, Reply, State};

handle_call({install,ClusterId},_From,State) ->
    Reply=rpc:call(node(),oam_lib,install,[ClusterId],25*1000),
    {reply, Reply, State};

handle_call({cluster_info},_From,State) ->
    Reply=etcd:cluster_info(),
    {reply, Reply, State};

handle_call({host_info},_From,State) ->
    Reply=etcd:host_info(),
    {reply, Reply, State};

handle_call({catalog_info},_From,State) ->
    Reply=etcd:catalog_info(),
    {reply, Reply, State};


handle_call({status_hosts},_From,State) ->
    Reply=host_controller:status_hosts(),
    {reply, Reply, State};

handle_call({create_cluster,ClusterName},_From,State) ->
    Reply=rpc:call(node(),oam_cluster,create,[ClusterName]),
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
