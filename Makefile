SUBDIRS = nagioschk

.PHONY: subdirs $(SUBDIRS)
subdirs: $(SUBDIRS)
$(SUBDIRS):
	$(MAKE) -C $@

.PHONY: check
check: nagioschk
	docker run -ti --privileged -v $(PWD)/nagios:/etc/nagios nagioschk
