all:
#	service
	rm ebin/*;
	cp src/*.app ebin;
	erlc -o ebin src/*.erl;
	rm -rf src/*.beam *.beam  test_src/*.beam test_ebin;
	rm -rf  *~ */*~  erl_cra*;
	rm -rf *_specs *_config *.log;
	rm -rf support etcd pod_specs controller cluster_config host_config;
	echo Done
doc_gen:
	echo glurk not implemented

exec_test:
	rm -rf ebin/* src/*.beam *.beam test_src/*.beam test_ebin;
	rm -rf  *~ */*~  erl_cra*;
	rm -rf *_specs *_config *.log;
#	interface
	erlc -I ../interfaces -o ebin ../interfaces/*.erl;
#	support
	rm -rf support;
	erlc -I ../interfaces -o ebin ../support/src/*.erl;
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
unit_test:
	rm -rf ebin/* src/*.beam *.beam test_src/*.beam test_ebin;
	rm -rf  *~ */*~  erl_cra*;
	rm -rf *_specs *_config *.log;
#	interface
	erlc -I ../interfaces -o ebin ../interfaces/*.erl;
#	support
	rm -rf support;
	erlc -I ../interfaces -o ebin ../support/src/*.erl;
#	iaas
	erlc -I ../interfaces -o ebin ../iaas/src/*.erl;
#	node
	cp ../applications/kubelet/src/*.app ebin;
	erlc -I ../interfaces -o ebin ../node/src/*.erl;
	erlc -I ../interfaces -o ebin ../applications/kubelet/src/*.erl;
#	controller
	rm -rf controller;
	erlc -I ../interfaces -o ebin ../controller/src/*.erl;
#	oam
	cp src/oam.app ebin;
	erlc -I ../interfaces -o ebin src/*.erl;
#	test application
	mkdir test_ebin;
	cp test_src/*.app test_ebin;
	erlc -I ../interfaces -o test_ebin test_src/*.erl;
	erl -pa ebin -pa test_ebin\
	    -setcookie abc\
	    -sname test_oam\
	    -run unit_test start_test test_src/test.config
