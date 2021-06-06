all:
#	service
	rm ebin/*;
	cp src/*.app ebin;
	erlc -o ebin src/*.erl;
	rm -rf src/*.beam *.beam  test_src/*.beam test_ebin;
	rm -rf  *~ */*~  erl_cra*;
	rm -rf *_specs *_config *.log catalog;
	echo Done
doc_gen:
	echo glurk not implemented
unit_test:
	rm -rf ebin/* src/*.beam *.beam test_src/*.beam test_ebin;
	rm -rf  *~ */*~  erl_cra*;
	rm -rf *_specs *_config *.log;
#	support
	cp ../support/src/support.app ebin;
	erlc -o ebin ../support/src/*.erl;
#	controller
	cp ../controller/src/controller.app ebin;
	erlc -o ebin ../controller/src/*.erl;
#	etcd
	cp ../etcd/src/etcd.app ebin;
	erlc -o ebin ../etcd/src/*.erl;
#	oam
	cp src/oam.app ebin;
	erlc -o ebin src/*.erl;
#	test application
	mkdir test_ebin;
	cp test_src/*.app test_ebin;
	erlc -o test_ebin test_src/*.erl;
	erl -pa ebin -pa test_ebin\
	    -setcookie abc\
	    -sname test_oam\
	    -run unit_test start_test test_src/test.config
