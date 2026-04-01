TOP         := top
SNAPSHOT    := $(TOP)_sim

XVLOG       := xvlog
XELAB       := xelab
XSIM        := xsim

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

WAVE        ?= 0
WAVE_TCL    := wave.tcl
WAVE_FILE   := waves.wdb

ifeq ($(WAVE),1)
    XELAB_OPTS += --debug typical
    XSIM_OPTS  := -tclbatch $(WAVE_TCL)
endif

.PHONY: all rtl verif elab sim clean logs

all: rtl verif elab sim

logs:
	mkdir -p $(LOGDIR)

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

elab: logs
	@echo "==> Elaborating..."
	@$(XELAB) $(XELAB_OPTS) $(TOP) -s $(SNAPSHOT) > $(ELAB_LOG) 2>&1 || \
	( echo "[ELAB ERROR] See $(ELAB_LOG)"; cat $(ELAB_LOG); exit 1 )
	@echo "[OK] Elaboration done. Log: $(ELAB_LOG)"

sim: logs
	@echo "==> Running simulation..."
	@$(XSIM) $(SNAPSHOT) $(XSIM_OPTS) > $(SIM_LOG) 2>&1 || \
	( echo "[SIM ERROR] See $(SIM_LOG)"; cat $(SIM_LOG); exit 1 )
	@echo "[OK] Simulation done. Log: $(SIM_LOG)"

clean:
	rm -rf .Xil xsim.dir *.jou *.log *.pb *.wdb webtalk* *~ $(LOGDIR) *:Zone.Identifier