ifndef DYN_DOCS
 DYN_DOCS=$(HOME)/GitWorkingArea/XDynDocs/inst
endif

include $(DYN_DOCS)/Make/Makefile

%.Rdb: %
	$(R_HOME)/bin/Rscript makeSession.R $< $@

%.Rdb: %.Rsession
	$(R_HOME)/bin/Rscript $(HOME)/MakeRSession/makeSession.R $< $@

