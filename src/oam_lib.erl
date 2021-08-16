%%% -------------------------------------------------------------------
%%% Author  : uabjle
%%% Description : dbase using dets 
%%% 
%%% Created : 10 dec 2012 
%%% -------------------------------------------------------------------
-module(oam_lib).  
   
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-include("kube_logger.hrl").
%%---------------------------------------------------------------------
%% Records for test
%%

%% --------------------------------------------------------------------
-compile(export_all).

%% ====================================================================
%% External functions
%% ====================================================================
connect(ClusterId)->
    Cookie=db_cluster_info:cookie(ClusterId),
    ControllerHost=db_cluster_info:controller(ClusterId),
    ControllerNode=list_to_atom(ControllerHost++"_"++ClusterId++"@"++ControllerHost),
    true=erlang:set_cookie(node(),list_to_atom(Cookie)),
    Reply=case net_adm:ping(ControllerNode) of
	      pong->
		  {ok,ControllerNode};
	      pang->
		  ?PrintLog(alert,"Failed to connect ",[ClusterId,ControllerNode,?FUNCTION_NAME,?MODULE,?LINE]),
		  {error,["Failed to connect ",ClusterId,ControllerNode,?FUNCTION_NAME,?MODULE,?LINE]}
	  end,
    Reply.

    

%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
delete(ClusterId)->
    ClusterDelete=cluster:delete(ClusterId),
    ?PrintLog(log,"ClusterDelete = ",[ClusterDelete,?FUNCTION_NAME,?MODULE,?LINE]),
    ClusterDelete.
%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
new(ClusterId)->
    ?PrintLog(log,"1/4 Start new cluster",[ClusterId,?FUNCTION_NAME,?MODULE,?LINE]),
    
    Cookie=db_cluster_info:cookie(ClusterId),
    [{_Alias,ControllerHost}]=db_cluster_info:controller(ClusterId),
    ControllerNode=list_to_atom(ControllerHost++"_"++ClusterId++"@"++ControllerHost),
    true=erlang:set_cookie(ControllerNode,list_to_atom(Cookie)),
    true=erlang:set_cookie(node(),list_to_atom(Cookie)),
    
    ssh:start(),
    
    ClusterDelete=cluster:delete(ClusterId),
    ?PrintLog(log,"2/4 ClusterDelete = ",[ClusterDelete,?FUNCTION_NAME,?MODULE,?LINE]),
    
    {ClusterId,StartResult}=cluster:create(ClusterId),
    ?PrintLog(log,"3/4 ClusterCreate = ",[ClusterId,StartResult,?FUNCTION_NAME,?MODULE,?LINE]),
    ClusterStatus=cluster:status_clusters(ClusterId),
    ?PrintLog(log,"3/4 ClusterStatus = ",[ClusterStatus,?FUNCTION_NAME,?MODULE,?LINE]),
    ?PrintLog(debug,"db_cluster:read_all() = ",[db_cluster:read_all(),?FUNCTION_NAME,?MODULE,?LINE]),
    
    Reply=case cluster:status_clusters(ClusterId) of
	      {{running,Running},{missing,[]}}->
		  
		 % ControllerHost=db_cluster_info:controller(ClusterId),
		%  {ok,Reference}=pod:create(ControllerHost,controller),
		  {ok,Reference}=pod:create(ControllerHost),
		  {ok,[_]}=pod:load_start("support",Reference),
		  {ok,[_]}=pod:load_start("etcd",Reference),
		  {ok,[_]}=pod:load_start("iaas",Reference),
		  {ok,[_]}=pod:load_start("controller",Reference),
		  ?PrintLog(log,"4/4 Created = ",["support","etcd","iaas","controller",?FUNCTION_NAME,?MODULE,?LINE]),
		  {ok,Reference};
	      Err->
		  ?PrintLog(alert,"Failed to created ",[ClusterId,?FUNCTION_NAME,?MODULE,?LINE]),
		  {error,["Failed to created",ClusterId,?FUNCTION_NAME,?MODULE,?LINE]}
	  end,
    Reply.

%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------

wait_for_cluster(_N,_Time,true)->
    true;
wait_for_cluster(0,_Time,R)->
    R;
wait_for_cluster(N,T,false) ->
    New=case iaas:status_all_clusters() of
	    {{running,[]},{missing,_}}->
		timer:sleep(T),
		false;
	    {{running,Running},{missing,_}}->
		true
	end,
    wait_for_cluster(N-1,T,New).
