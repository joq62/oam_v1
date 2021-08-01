all:
#	service
	rm -rf  ebin/*;
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
exec_test:
	rm -rf ebin/* src/*.beam *.beam test_src/*.beam test_ebin;
	rm -rf  *~ */*~  erl_cra*;
	rm -rf *_specs *_config *.log;
#	interface
	erlc -I ../interfaces -o ebin ../interfaces/*.erl;
#	support
	rm -rf support;
	erlc -I ../interfaces -o ebin ../support/src/*.erl;
#	kube_logger
	erlc -I ../interfaces -o ebin ../kube_logger/src/*.erl;
#	iaas
	erlc -I ../interfaces -o ebin ../iaas/src/*.erl;
#	node
	cp ../applications/kubelet/src/*.app ebin;
	erlc -I ../interfaces -o ebin ../node/src/*.erl;
	erlc -I ../interfaces -o ebin ../applications/kubelet/src/*.erl;
#	node
#	git clone https://github.com/joq62/controller.git;
#	etcd
	rm -rf etcd;
#	git clone https://github.com/joq62/etcd.git;
#	oam
	cp src/oam.app ebin;
	erlc -I ../interfaces -o ebin src/*.erl;
#	test application
	mkdir test_ebin;
	erl -pa ebin\
	    -setcookie abc\
	    -sname test_exec_oam\
	    -run oam boot
test_10_unit_test:
	rm -rf test_10_ebin;
	rm -rf src/*.beam *.beam test_src/*.beam test_ebin;
	rm -rf  *~ */*~  erl_cra*;
	rm -rf *_specs *_config *.log;
	mkdir test_10_ebin;
#	interface
	erlc -I ../interfaces -o test_10_ebin ../interfaces/*.erl;
#	support
	rm -rf support;
	erlc -I ../interfaces -o test_10_ebin ../support/src/*.erl;
#	iaas
	erlc -I ../interfaces -o test_10_ebin ../iaas/src/*.erl;
#	node
	cp ../applications/kubelet/src/*.app test_10_ebin;
	erlc -I ../interfaces -o test_10_ebin ../node/src/*.erl;
	erlc -I ../interfaces -o test_10_ebin ../applications/kubelet/src/*.erl;
#	controller
	rm -rf controller;
	erlc -I ../interfaces -o test_10_ebin ../controller/src/*.erl;
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
	    -run unit_test start_test test_src/test.config
test_1_unit_test:
	rm -rf test_1_ebin;
	rm -rf test_1_ebin/* src/*.beam *.beam test_src/*.beam test_ebin;
	rm -rf  *~ */*~  erl_cra*;
	rm -rf *_specs *_config *.log;
	mkdir test_1_ebin;
#	interface
	erlc -I ../interfaces -o test_1_ebin ../interfaces/*.erl;
#	support
	rm -rf support;
	erlc -I ../interfaces -o test_1_ebin ../support/src/*.erl;
#	iaas
	erlc -I ../interfaces -o test_1_ebin ../iaas/src/*.erl;
#	node
	cp ../applications/kubelet/src/*.app test_1_ebin;
	erlc -I ../interfaces -o test_1_ebin ../node/src/*.erl;
	erlc -I ../interfaces -o test_1_ebin ../applications/kubelet/src/*.erl;
#	controller
	rm -rf controller;
	erlc -I ../interfaces -o test_1_ebin ../controller/src/*.erl;
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
	    -run unit_test start_test test_src/test.config
