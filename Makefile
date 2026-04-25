TOP         := top
SNAPSHOT    := $(TOP)_sim

XVLOG       := xvlog
XELAB       := xelab
XSIM        := xsim
XCRG        := xcrg

RTL_FLIST   := rtl.f
VERIF_FLIST := verif.f

XVLOG_OPTS  := -sv
XELAB_OPTS  :=
XSIM_OPTS   := -runall

LOGDIR      := logs
RTL_LOG     := $(LOGDIR)/rtl.log
VERIF_LOG   := $(LOGDIR)/verif.log
ELAB_LOG    := $(LOGDIR)/elab.log
SIM_LOG     := $(LOGDIR)/sim.log
COV_LOG     := $(LOGDIR)/cov.log

WAVE        ?= 0
WAVE_TCL    := wave.tcl
WAVE_FILE   := waves.wdb

COV         ?= 0
COVDIR      := cov
COV_DB      := $(SNAPSHOT)
COV_REPORT  := $(COVDIR)/report
COV_TYPE    := sbct

ifeq ($(WAVE),1)
    XELAB_OPTS += --debug typical
    XSIM_OPTS  := -tclbatch $(WAVE_TCL)
endif

ifeq ($(COV),1)
    XELAB_OPTS += -cc_type $(COV_TYPE) -cc_db $(COV_DB) -cc_dir $(COVDIR)
endif

.PHONY: all rtl verif elab sim cov_report clean logs cov_dirs

all: rtl verif elab sim

logs:
	mkdir -p $(LOGDIR)

cov_dirs:
	mkdir -p $(COVDIR) $(COV_REPORT)

rtl: logs
	@echo "==> Compiling RTL..."
	@$(XVLOG) $(XVLOG_OPTS) -f $(RTL_FLIST) > $(RTL_LOG) 2>&1 || \
	( echo "[RTL ERROR] See $(RTL_LOG)"; cat $(RTL_LOG); exit 1 )
	@echo "[OK] RTL done. Log: $(RTL_LOG)"

verif: logs
	@echo "==> Compiling verification..."
	@$(XVLOG) $(XVLOG_OPTS) -f $(VERIF_FLIST) > $(VERIF_LOG) 2>&1 || \
	( echo "[VERIF ERROR] See $(VERIF_LOG)"; cat $(VERIF_LOG); exit 1 )
	@echo "[OK] Verification done. Log: $(VERIF_LOG)"

elab: logs $(if $(filter 1,$(COV)),cov_dirs)
	@echo "==> Elaborating..."
	@$(XELAB) $(XELAB_OPTS) $(TOP) -s $(SNAPSHOT) > $(ELAB_LOG) 2>&1 || \
	( echo "[ELAB ERROR] See $(ELAB_LOG)"; cat $(ELAB_LOG); exit 1 )
	@echo "[OK] Elaboration done. Log: $(ELAB_LOG)"

sim: logs
	@echo "==> Running simulation..."
	@$(XSIM) $(SNAPSHOT) $(XSIM_OPTS) > $(SIM_LOG) 2>&1 || \
	( echo "[SIM ERROR] See $(SIM_LOG)"; cat $(SIM_LOG); exit 1 )
	@echo "[OK] Simulation done. Log: $(SIM_LOG)"
ifeq ($(COV),1)
	@$(MAKE) cov_report
endif

cov_report: logs cov_dirs
	@echo "==> Generating code coverage report..."
	@$(XCRG) -cc_db $(COV_DB) -cc_dir $(COVDIR) -cc_report $(COV_REPORT) > $(COV_LOG) 2>&1 || \
	( echo "[COV ERROR] See $(COV_LOG)"; cat $(COV_LOG); exit 1 )
	@echo "[OK] Coverage report done: $(COV_REPORT)/dashboard.html"

clean:
	rm -rf .Xil xsim.dir *.jou *.log *.pb *.wdb webtalk* *~ $(LOGDIR) $(COVDIR) *:Zone.Identifier