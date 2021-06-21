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

    io:format("~p~n",[{"Start pass_0()",?MODULE,?FUNCTION_NAME,?LINE}]),
    ok=pass_0(),
   io:format("~p~n",[{"Stop pass_0()",?MODULE,?FUNCTION_NAME,?LINE}]),

    io:format("~p~n",[{"Start pass_1()",?MODULE,?FUNCTION_NAME,?LINE}]),
    ok=pass_1(),
    io:format("~p~n",[{"Stop pass_1()",?MODULE,?FUNCTION_NAME,?LINE}]),

 %   io:format("~p~n",[{"Start pass_2()",?MODULE,?FUNCTION_NAME,?LINE}]),
 %   ok=pass_2(),
 %   io:format("~p~n",[{"Stop pass_2()",?MODULE,?FUNCTION_NAME,?LINE}]),

    io:format("~p~n",[{"Start pass_3()",?MODULE,?FUNCTION_NAME,?LINE}]),
    ok=pass_3(),
    io:format("~p~n",[{"Stop pass_3()",?MODULE,?FUNCTION_NAME,?LINE}]),

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
pass_0()->
    [{"test_1",["c0"],2,[],"test_1_cookie",[]},
     {"production",["c1"],2,["c0","c1"],"production_cookie",[]}]=db_cluster_info:read_all(),

    [{"c2","192.168.0.202",22,"joq62","festum01"},
     {"c2","192.168.1.202",22,"joq62","festum01"},
     {"c1","192.168.0.201",22,"joq62","festum01"},
     {"c1","192.168.1.201",22,"joq62","festum01"},
     {"c0","192.168.0.200",22,"joq62","festum01"},
     {"c0","192.168.1.200",22,"joq62","festum01"}]=db_host_info:read_all(),

    [{"c2","192.168.0.202",22,"joq62","festum01"}, 
     {"c2","192.168.1.202",22,"joq62","festum01"}]=db_host_info:read("c2"),
    

    [{"orginal","1.0.0","orginal","1.0.0",
      "https://github.com/joq62/orginal.git",[],
      []}]=db_pod_spec:read_all(),
    ok.

%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
pass_1()->
    {[{running,_,_,_},
      {running,_,_,_}],
     [{not_available,_,_,_},
      {not_available,_,_,_},
      {not_available,_,_,_},
      {not_available,_,_,_}]}=iaas:status_all_hosts(),
  
    [{running,_,_,22},
     {running,_,_,22}]=iaas:running_hosts(),
    [{not_available,_,_,_},
     {not_available,_,_,_},
     {not_available,_,_,_},
     {not_available,_,_,_}]=iaas:not_available_hosts(),
    
    [{not_available,"c2",_,22},
     {not_available,"c2",_,22}]=iaas:status_host("c2"),
    [{_,"c1",_,22},
     {_,"c1",_,22}]=iaas:status_host("c1"),
    
    
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
    [Id1,Id2]=ClusterToCreate,
    ok=iaas:create_cluster(Id1),
    timer:sleep(1000),
     io:format("iaas:running_clusters() ~p~n",[iaas:running_clusters()]),
    [Id2]=[XClusterId||XClusterId<-iaas:wanted_clusters(),
	    false==lists:keymember(XClusterId,1,iaas:running_clusters())],
    io:format("Id2 ~p~n",[Id2]),
    ok=iaas:create_cluster(Id2),
    []=[ClusterId||ClusterId<-iaas:wanted_clusters(),
		   false==lists:keymember(ClusterId,1,iaas:running_clusters())],
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
