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
    [{_Alias,ControllerHost}]=db_cluster_info:controller(ClusterId),
    ControllerNode=list_to_atom(ControllerHost++"_"++ClusterId++"@"++ControllerHost),
    true=erlang:set_cookie(ControllerNode,list_to_atom(Cookie)),
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

    ?PrintLog(log,"1/X Check if needed hosts are available  ",[?FUNCTION_NAME,?MODULE,?LINE]),
    % Check if needed hosts are available 
    {ok,RunningHosts,_MissingHosts}=host:status_all_hosts(),
    RunningHostIds=[{Alias,HostId}||{running,Alias,HostId,_,_}<-RunningHosts],
    ControllerHostInfo=db_cluster_info:controller(ClusterId),
    WorkerHostsInfo=db_cluster_info:workers(ClusterId),
    NeededHosts=lists:append([ControllerHostInfo,WorkerHostsInfo]),
   
    NeededHostsCheck=[HostInfo||HostInfo<-NeededHosts,
			   lists:member(HostInfo,RunningHostIds)],
    if
	NeededHostsCheck==NeededHosts->
	    ?PrintLog(log,"1/X Needed hosts are available",[NeededHosts,?FUNCTION_NAME,?MODULE,?LINE]);
	true ->
	    ?PrintLog(ticket,"1/X Needed hosts are not available",[NeededHostsCheck,NeededHosts,?FUNCTION_NAME,?MODULE,?LINE]),
	    erlang:exit({ticket,"1/X Needed hosts are not available",[NeededHostsCheck,NeededHosts,?FUNCTION_NAME,?MODULE,?LINE]})
    end,
    
    ?PrintLog(log,"2/X Ensure that oam has the same cookie as cluster ",[?FUNCTION_NAME,?MODULE,?LINE]),	    
    Cookie=db_cluster_info:cookie(ClusterId),
    [{_Alias,ControllerHost}]=db_cluster_info:controller(ClusterId),
    ControllerNode=list_to_atom(ControllerHost++"_"++ClusterId++"@"++ControllerHost),
    true=erlang:set_cookie(ControllerNode,list_to_atom(Cookie)),
    true=erlang:set_cookie(node(),list_to_atom(Cookie)),
    
    ?PrintLog(log,"3/X Ensure that the cluster is not running ",[cluster:delete(ClusterId),?FUNCTION_NAME,?MODULE,?LINE]),	    
    
    ?PrintLog(log,"4/X Create cluster nodes ",[cluster:create(ClusterId),?FUNCTION_NAME,?MODULE,?LINE]),
        
    Reply=case cluster:status_clusters(ClusterId) of
	      {{running,RunningNodes},{missing,[]}}->

		  ?PrintLog(log,"5/X Success ClusterCreate = ",[RunningNodes,?FUNCTION_NAME,?MODULE,?LINE]),
		  {ok,Reference}=pod:create(ControllerHost),
		  {ok,[_]}=pod:load_start("support",Reference),
		  {ok,[_]}=pod:load_start("etcd",Reference),
		  % Init etcd
		  
		  erlang:exit({debug,Reference}),
		  {ok,[_]}=pod:load_start("iaas",Reference),
		  {ok,[_]}=pod:load_start("controller",Reference),
		  ?PrintLog(log,"6/X  = ",["support","etcd","iaas","controller",?FUNCTION_NAME,?MODULE,?LINE]),
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
