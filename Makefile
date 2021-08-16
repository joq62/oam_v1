all:
#	service
	rm -rf  ebin/* logs;
	cp src/*.app ebin;
	erlc -I ../interfaces -o ebin src/*.erl;
	rm -rf src/*.beam *.beam  test_src/*.beam test_ebin;
	rm -rf  *~ */*~  erl_cra*;
	rm -rf *_specs *_config *.log;
	rm -rf logs test_10_ebin test_1_ebin monitor_ebin;
	rm -rf support etcd pod_specs controller cluster_config host_config;
	echo Done
del_logs:
	rm -rf logs
cli_test_10:
	erl -pa ebin -sname cli -setcookie test_10_cookie
test_10_unit_test:
	rm -rf test_10_ebin;
	rm -rf src/*.beam *.beam test_src/*.beam test_ebin;
	rm -rf  *~ */*~  erl_cra*;
	rm -rf *_specs *_config logs;
	mkdir test_10_ebin;
#	interface
	erlc -I ../interfaces -o test_10_ebin ../interfaces/*.erl;
#	support
	rm -rf support;
	erlc -I ../interfaces -o test_10_ebin ../kube_support/src/*.erl;
#	iaas
	cp ../applications/iaas/src/*.app test_10_ebin;
	erlc -I ../interfaces -o test_10_ebin ../kube_iaas/src/*.erl;
	erlc -I ../interfaces -o test_10_ebin ../applications/iaas/src/*.erl;
#	node
	cp ../applications/kubelet/src/*.app test_10_ebin;
	erlc -I ../interfaces -o test_10_ebin ../node/src/*.erl;
	erlc -I ../interfaces -o test_10_ebin ../applications/kubelet/src/*.erl;
#	etcd
	cp ../applications/etcd/src/*.app test_10_ebin;
	erlc -I ../interfaces -o test_10_ebin ../kube_dbase/src/*.erl;
	erlc -I ../interfaces -o test_10_ebin ../applications/etcd/src/*.erl;
#	controller
	rm -rf controller;
	erlc -I ../interfaces -o test_10_ebin ../kube_controller/src/*.erl;
#	oam
	cp src/oam.app test_10_ebin;
	erlc -I ../interfaces -o test_10_ebin src/*.erl;
#	test application
	mkdir test_ebin;
	cp test_src/*.app test_ebin;
	erlc -I ../interfaces -o test_ebin test_src/*.erl;
	erl -pa test_10_ebin -pa test_ebin\
	    -setcookie test_10_cookie\
	    -sname oam_test_10\
	    -oam monitor_node oam_test_10\
	    -oam cluster_id test_10\
	    -oam start_host_id c1_varmdo\
	    -run unit_test start_test test_src/test.config
test_1_unit_test:
	rm -rf test_1_ebin;
	rm -rf test_1_ebin/* src/*.beam *.beam test_src/*.beam test_ebin;
	rm -rf  *~ */*~  erl_cra*;
	rm -rf *_specs *_config logs;
	mkdir test_1_ebin;
#	interface
	erlc -I ../interfaces -o test_1_ebin ../interfaces/*.erl;
#	support
	rm -rf support;
	erlc -I ../interfaces -o test_1_ebin ../kube_support/src/*.erl;
#	iaas
	cp ../applications/iaas/src/*.app test_1_ebin;
	erlc -I ../interfaces -o test_1_ebin ../kube_iaas/src/*.erl;
	erlc -I ../interfaces -o test_1_ebin ../applications/iaas/src/*.erl;
#	node
	cp ../applications/kubelet/src/*.app test_1_ebin;
	erlc -I ../interfaces -o test_1_ebin ../node/src/*.erl;
	erlc -I ../interfaces -o test_1_ebin ../applications/kubelet/src/*.erl;
#	etcd
	cp ../applications/etcd/src/*.app test_1_ebin;
	erlc -I ../interfaces -o test_1_ebin ../kube_dbase/src/*.erl;	
	erlc -I ../interfaces -o test_1_ebin ../applications/etcd/src/*.erl;
#	controller
	erlc -I ../interfaces -o test_1_ebin ../kube_controller/src/*.erl;
#	oam
	cp src/oam.app test_1_ebin;
	erlc -I ../interfaces -o test_1_ebin src/*.erl;
#	test application
	mkdir test_ebin;
	cp test_src/*.app test_ebin;
	erlc -I ../interfaces -o test_ebin test_src/*.erl;
	erl -pa test_1_ebin -pa test_ebin\
	    -setcookie test_1_cookie\
	    -sname oam_test_1\
	    -oam monitor_node oam_test_1\
	    -oam cluster_id test_1\
	    -oam start_host_id c1_varmdo\
	    -run unit_test start_test test_src/test.config
unit_test:
	rm -rf test_ebin;
	rm -rf test_ebin/* src/*.beam *.beam test_src/*.beam;
	rm -rf  *~ */*~  erl_cra*;
	rm -rf *_specs *_config logs;
	mkdir test_ebin;
#	interface
	erlc -I ../interfaces -o ebin ../interfaces/*.erl;
#	support
	erlc -I ../interfaces -o ebin ../kube_support/src/*.erl;
#	kubelet
	cp ../applications/kubelet/src/*.app ebin;
	erlc -I ../interfaces -o ebin ../node/src/*.erl;
	erlc -I ../interfaces -o ebin ../applications/kubelet/src/*.erl;
#	etcd
	cp ../applications/etcd/src/*.app ebin;
	erlc -I ../interfaces -o ebin ../kube_dbase/src/*.erl;	
	erlc -I ../interfaces -o ebin ../applications/etcd/src/*.erl;
#	iaas
	erlc -I ../interfaces -o ebin ../kube_iaas/src/*.erl;
#	oam
	erlc -I ../interfaces -o ebin ../oam/src/*.erl;
#	test application
	cp test_src/*.app test_ebin;
	erlc -I ../interfaces -o test_ebin test_src/*.erl;
	erl -pa ebin -pa test_ebin\
	    -setcookie oam_cookie\
	    -sname oam_test\
	    -oam monitor_node oam_test\
	    -run unit_test start_test test_src/test.config
