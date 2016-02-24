#!/bin/bash

function xmlchange {
	OPT=$1
	LABEL=${@:2}
	if [ -n "$LABEL" ]; then
		echo "$OPT => '$LABEL'"
		./xmlchange $OPT="$LABEL"
	fi
}

# Error checking
set -e

MACHINES=scripts/ccsm_utils/Machines

# Copy configuration files

echo "================================"
echo "--------------------------------"
echo "Copying configuration files..."
cp ./config_pes.xml $MACHINES/
cp ./config_machines.xml $MACHINES/
cp ./config_compilers.xml $MACHINES/
cp ./env_mach_specific.instance $MACHINES/
cp ./mkbatch.instance $MACHINES/
cp ./Depends.intel $MACHINES/

echo "--------------------------------"
echo "Creating new case..."
scripts/create_newcase -case [[[#EXPERIMENT_NAME]]] -res [[[GRID_RESOLUTION]]] -compset [[[COMPSET]]] -mach instance -compiler intel
cd [[[#EXPERIMENT_NAME]]]
./cesm_setup

echo "--------------------------------"
echo "Compiling case..."
xmlchange PIO_CONFIG_OPTS " --enable-mpiio --enable-pnetcdf "
xmlchange CALENDAR [[[CALENDAR]]]
xmlchange COMP_INTERFACE [[[COMP_INTERFACE]]]
xmlchange USE_ESMF_LIB [[[USE_ESMF_LIB]]]
xmlchange DEBUG [[[DEBUG]]]

# CAM
xmlchange CAM_CONFIG_OPTS [[[CAM_CONFIG_OPTS]]]
xmlchange CAM_DYCORE [[[CAM_DYCORE]]]

# OCN
xmlchange OCN_SUBMODEL [[[OCN_SUBMODEL]]]
xmlchange OCN_TRACER_MODULES [[[OCN_TRACER_MODULES]]]
xmlchange OCN_TRACER_MODULES_OPT [[[OCN_TRACER_MODULES_OPT]]]

# POP
xmlchange POP_AUTO_DECOMP [[[POP_AUTO_DECOMP]]]
xmlchange POP_BLCKX [[[POP_BLCKX]]]
xmlchange POP_BLCKY [[[POP_BLCKY]]]
xmlchange POP_NX_BLOCKS [[[POP_NX_BLOCKS]]]
xmlchange POP_NY_BLOCKS [[[POP_NY_BLOCKS]]]
xmlchange POP_MXBLOCKS [[[POP_MXBLCKS]]]
xmlchange POP_DECOMPTYPE [[[POP_DECOMPTYPE]]]

# CICE
xmlchange CICE_MODE [[[CICE_MODE]]]
xmlchange CICE_CONFIG_OPTS [[[CICE_CONFIG_OPTS]]]
xmlchange CICE_AUTO_DECOMP [[[CICE_AUTO_DECOMP]]]
xmlchange CICE_BLCKX [[[CICE_BLCKX]]]
xmlchange CICE_BLCKY [[[CICE_BLCKY]]]
xmlchange CICE_MXBLCKS [[[CICE_MXBLCKS]]]
xmlchange CICE_DECOMPTYPE [[[CICE_DECOMPTYPE]]]
xmlchange CICE_DECOMPSETTING [[[CICE_DECOMPSETTING]]]

# RTM
xmlchange RTM_MODE [[[RTM_MODE]]]
xmlchange RTM_FLOOD_MODE [[[RTM_FLOOD_MODE]]]

# Build
./[[[#EXPERIMENT_NAME]]].build

echo "--------------------------------"
echo "================================"

exit 0
