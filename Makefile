PROJECTS = template

# Turn on increased build verbosity by defining BUILD_VERBOSE in your main
# Makefile or in your environment. You can also use V=1 on the make command
# line.
ifeq ("$(origin V)", "command line")
BUILD_VERBOSE=$(V)
endif
ifndef BUILD_VERBOSE
$(info Use make V=1 or set BUILD_VERBOSE in your environment to increase build verbosity.)
BUILD_VERBOSE = 0
endif
ifeq ($(BUILD_VERBOSE),0)
Q = @
else
Q =
endif

KICAD_CLI ?= kicad-cli
PDFUNITE ?= pdfunite
PCB_HELPER ?= ./scripts/pcb_helper.py
BOM_HELPER ?= ./scripts/bom_helper.py
SED ?= sed
MKDIR ?= mkdir

PLOT_DIRS=$(addprefix exports/plots/, $(PROJECTS))
PLOTS_SCH=$(addsuffix -sch.pdf, $(PLOT_DIRS))
PLOTS_PCB=$(addsuffix -pcb.pdf, $(PLOT_DIRS))
PLOTS=$(PLOTS_SCH) $(PLOTS_PCB)

GERBER_DIRS=$(addprefix production/gbr/, $(PROJECTS))
GERBER_ZIPS=$(addsuffix .zip, $(GERBER_DIRS))

POS = $(addprefix production/pos/, $(addsuffix .csv, $(PROJECTS)))

BOMS = $(addprefix production/bom/, $(addsuffix .csv, $(PROJECTS)))

all: $(PLOTS) $(GERBER_ZIPS) $(POS) $(BOMS)
.PHONY: all

plots: $(PLOTS)
.PHONY: plots

gerbers: $(GERBER_ZIPS)
.PHONY: gerbers

pos: $(POS)
.PHONY: pos

bom: $(BOMS)
.PHONY: bom

exports/plots/%-sch.pdf: source/*/%.kicad_sch
	$(Q)$(KICAD_CLI) sch export pdf \
		"$<" \
		--output "$@"

exports/plots/%-pcb.pdf: source/*/%.kicad_pcb
	$(eval tempdir := $(shell mktemp -d))

	$(eval copper := $(shell $(PCB_HELPER) \
		--pcb "$<" \
		copper \
	))

	$(Q)n=0; \
	for layer in $(copper); \
	do \
		$(KICAD_CLI) pcb export pdf \
			--include-border-title \
			--layers "$$layer,Edge.Cuts" \
			"$<" \
			--output "$(tempdir)/$$(printf "%02d" $${n})-$*-$$layer.pdf"; \
		let "n+=1" ; \
	done

	$(Q)$(PDFUNITE) $(tempdir)/*-$*-*.pdf "$@" 2>/dev/null

	$(Q)rm -r $(tempdir)

production/gbr/%.zip: source/*/%.kicad_pcb
	$(eval stackup := Edge.Cuts $(shell $(PCB_HELPER) \
		--pcb "$<" \
		stackup \
	))

	$(Q)rm -rf production/gbr/$*
	$(Q)mkdir -p production/gbr/$*

	$(Q)for layer in $(stackup); \
	do \
		$(KICAD_CLI) pcb export gerber \
			--subtract-soldermask \
			--layers $$layer \
			"$<" \
			--output "production/gbr/$*/$*-$$layer.gbr"; \
	done
	$(Q)$(KICAD_CLI) pcb export drill \
		--excellon-separate-th \
		--units mm \
		"$<" \
		--output "production/gbr/$*/"

	$(Q)zip $@ production/gbr/$*/*

production/pos/%.csv: source/*/%.kicad_pcb
	$(Q)$(KICAD_CLI) pcb export pos \
		--format csv \
		--units mm \
		"$<" \
		--output "$@"
	$(Q)$(SED) \
		-e 's/Ref/Designator/' \
		-e 's/PosX/Mid X/' \
		-e 's/PosY/Mid Y/' \
		-e 's/Side/Layer/' \
		-e 's/Rot/Rotation/' \
		-i "$@"

production/bom/%.csv: source/*/%.kicad_sch
	$(Q)$(KICAD_CLI) sch export python-bom \
		"$<" \
		--output "production/bom/$*.xml"
	$(Q)$(BOM_HELPER) \
		--bom "production/bom/$*.xml" \
		--csv "$@"

source/*/%.net: source/*/%.kicad_sch
	$(Q)$(KICAD_CLI) sch export netlist \
		"$<" \
		--output "source/$*/$*.net"

clean:
	$(Q)rm -rf $(PLOTS)
	$(Q)rm -rf $(GERBER_DIRS)
	$(Q)rm -rf $(GERBER_ZIPS)
	$(Q)rm -rf $(POS)
	$(Q)rm -rf $(BOMS)
.PHONY: clean
