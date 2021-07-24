%%% -------------------------------------------------------------------
%%% Author  : uabjle
%%% Description :  
%%% 
%%% Created : 10 dec 2012
%%% -------------------------------------------------------------------
-module(oam_test).   
   
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
%-include_lib("eunit/include/eunit.hrl").
%% --------------------------------------------------------------------



%% External exports
-export([start/0]). 


%% ====================================================================
%% External functions
%% ====================================================================


%% --------------------------------------------------------------------
%% Function:tes cases
%% Description: List of test cases 
%% Returns: non
%% --------------------------------------------------------------------
start()->
    io:format("~p~n",[{"Start setup",?MODULE,?FUNCTION_NAME,?LINE}]),
    ok=setup(),
    io:format("~p~n",[{"Stop setup",?MODULE,?FUNCTION_NAME,?LINE}]),

    io:format("~p~n",[{"Start iaas_cluster()",?MODULE,?FUNCTION_NAME,?LINE}]),
    ok=iaas_cluster(),
   io:format("~p~n",[{"Stop iaas_cluster()",?MODULE,?FUNCTION_NAME,?LINE}]),

    io:format("~p~n",[{"Start pass_0()",?MODULE,?FUNCTION_NAME,?LINE}]),
    ok=pass_0(),
   io:format("~p~n",[{"Stop pass_0()",?MODULE,?FUNCTION_NAME,?LINE}]),

 %   io:format("~p~n",[{"Start pass_1()",?MODULE,?FUNCTION_NAME,?LINE}]),
 %   ok=pass_1(),
 %   io:format("~p~n",[{"Stop pass_1()",?MODULE,?FUNCTION_NAME,?LINE}]),

 %   io:format("~p~n",[{"Start pass_2()",?MODULE,?FUNCTION_NAME,?LINE}]),
 %   ok=pass_2(),
 %   io:format("~p~n",[{"Stop pass_2()",?MODULE,?FUNCTION_NAME,?LINE}]),

%    io:format("~p~n",[{"Start pass_3()",?MODULE,?FUNCTION_NAME,?LINE}]),
%    ok=pass_3(),
%    io:format("~p~n",[{"Stop pass_3()",?MODULE,?FUNCTION_NAME,?LINE}]),

  %  io:format("~p~n",[{"Start pass_4()",?MODULE,?FUNCTION_NAME,?LINE}]),
  %  ok=pass_4(),
  %  io:format("~p~n",[{"Stop pass_4()",?MODULE,?FUNCTION_NAME,?LINE}]),

  %  io:format("~p~n",[{"Start pass_5()",?MODULE,?FUNCTION_NAME,?LINE}]),
  %  ok=pass_5(),
  %  io:format("~p~n",[{"Stop pass_5()",?MODULE,?FUNCTION_NAME,?LINE}]),
 
    
   
      %% End application tests
    io:format("~p~n",[{"Start cleanup",?MODULE,?FUNCTION_NAME,?LINE}]),
    ok=cleanup(),
    io:format("~p~n",[{"Stop cleaup",?MODULE,?FUNCTION_NAME,?LINE}]),
   
    io:format("------>"++atom_to_list(?MODULE)++" ENDED SUCCESSFUL ---------"),
    ok.


%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------

iaas_cluster()->
    io:format("~p~n ",[iaas:status_all_clusters()]),
    timer:sleep(5*1000),
    iaas_cluster().
    
%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
pass_0()->
    
%    io:format("cluster info= ~p~n",[db_cluster_info:read_all()]),
%    io:format("host info= ~p~n",[db_host_info:read_all()]),
%    io:format("pod info= ~p~n",[db_pod_spec:read_all()]),
    
    {{running,R1},{missing,M1}}=cluster:status_clusters(),
    io:format("1. status_clusters() = ~p~n",[  {{running,R1},{missing,M1}}]),    
    [cluster:create(ClusterId)||{ClusterId,_}<-M1],
 %   io:format("create(test_2) = ~p~n",[cluster:create("test_2")]),
    timer:sleep(1000),
    {{running,R2},{missing,M2}}=cluster:status_clusters(),
    io:format("2. status_clusters() = ~p~n",[  {{running,R2},{missing,M2}}]),    
%    io:format("2. status_clusters() = ~p~n",[cluster:status_clusters()]),    
    [cluster:delete(ClusterId)||{ClusterId,_}<-R2],
%    io:format("delete(test_2) = ~p~n",[cluster:delete("test_2")]),
    io:format("3. status_clusters() = ~p~n",[cluster:status_clusters()]),    
    ok.

%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
pass_1()->
  %  io:format("update_host_status= ~p~n",[iaas:update_host_status()]),
%    io:format("status_all_hosts= ~p~n",[iaas:status_all_hosts()]),
 %   io:format("running_hosts= ~p~n",[iaas:running_hosts()]),
 %   io:format("not_available_hosts()= ~p~n",[iaas:not_available_hosts()]),
    
    ok.

%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
pass_2()->
    
    io:format("production_kubelet_c0@c0 ~p~n",[rpc:call('production_kubelet_c0@c0',init,stop,[])]),
    timer:sleep(1000),
    io:format("production_kubelet_c1@c1 ~p~n",[rpc:call('production_kubelet_c1@c1',init,stop,[])]),
    timer:sleep(1000),
     io:format("test_1_kubelet_c0@c0 ~p~n",[rpc:call('test_1_kubelet_c0@c0',init,stop,[])]),
    {error,[{error,[eexists,glurk]}]}=iaas:create_cluster(glurk),
    
    %
    WantedClusterIds=iaas:wanted_clusters(),
    io:format("WantedClusterIds ~p~n",[WantedClusterIds]),
    RunningClusters=iaas:running_clusters(),
    ClusterToCreate=[ClusterId||ClusterId<-iaas:wanted_clusters(),
				false==lists:keymember(ClusterId,1,iaas:running_clusters())],
    io:format("ClusterToCreate ~p~n",[ClusterToCreate]),
 %   [Id1,Id2]=ClusterToCreate,
  %  ok=iaas:create_cluster(Id1),
  %  timer:sleep(1000),
  %   io:format("iaas:running_clusters() ~p~n",[iaas:running_clusters()]),
  %  [Id2]=[XClusterId||XClusterId<-iaas:wanted_clusters(),
%	    false==lists:keymember(XClusterId,1,iaas:running_clusters())],
 %   io:format("Id2 ~p~n",[Id2]),
  %  ok=iaas:create_cluster(Id2),
  %  []=[ClusterId||ClusterId<-iaas:wanted_clusters(),
%		   false==lists:keymember(ClusterId,1,iaas:running_clusters())],
  %  {{running_clusters,RunningClusters},
  %  {not_available_clusters,[]}}=iaas:status_all_clusters(),
    
  %  RunningClusters=iaas:running_clusters(),
     
    
  

    ok.

%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
pass_3()->
    
    check(3),
    ok.

check(0)->
    ok;
check(N) ->
    io:format("iaas:running_clusters() ~p~n",[iaas:running_clusters()]),
    timer:sleep(3000),
    check(N-1).
%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
pass_4()->
  
    ok.

%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
pass_5()->
  
    ok.




%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------

setup()->
  
    ok.


%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% -------------------------------------------------------------------    

cleanup()->
  
%    application:stop(oam),
    ok.
%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
