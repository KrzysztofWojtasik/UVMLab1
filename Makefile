TOP      := top
SNAPSHOT := $(TOP)_sim

XVLOG    := xvlog
XELAB    := xelab
XSIM     := xsim

RTL_FLIST   := rtl.f
VERIF_FLIST := verif.f

XVLOG_OPTS := -sv
XELAB_OPTS := 
XSIM_OPTS  := -runall

.PHONY: all rtl verif elab sim clean

all: rtl verif elab sim clean

rtl:
	$(XVLOG) $(XVLOG_OPTS) -f $(RTL_FLIST)

verif:
	$(XVLOG) $(XVLOG_OPTS) -f $(VERIF_FLIST)

elab:
	$(XELAB) $(XELAB_OPTS) $(TOP) -s $(SNAPSHOT)

sim:
	$(XSIM) $(SNAPSHOT) $(XSIM_OPTS)

clean:
	rm -rf .Xil xsim.dir *.jou *.log *.pb *.wdb webtalk* *~
