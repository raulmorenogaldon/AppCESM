#!/bin/bash

function xmlchange {
	OPT=$1
	LABEL=${@:2}
	if [ -n "$LABEL" ]; then
		echo "$OPT => '$LABEL'"
		./xmlchange $OPT="$LABEL"
	fi
}

echo "================================"
echo "--------------------------------"
icc -v >& /dev/null
if [ $? -eq 0 ]; then
	echo "Compiler is Intel"
	COMPILER=intel
else
	echo "Compiler is GNU"
	COMPILER=gnu
fi

# Error checking
set -e

MACHINES=scripts/ccsm_utils/Machines

# Setup environment
export EXPERIMENTPATH="$(pwd)/[[[#EXPERIMENT_NAME]]]"
export INPUTPATH="[[[#INPUTPATH]]]"

# Copy configuration files
echo "--------------------------------"
echo "Copying configuration files..."
cp ./config_pes.xml $MACHINES/
cp ./config_machines.xml $MACHINES/
cp ./config_compilers.xml $MACHINES/
cp ./env_mach_specific.instance $MACHINES/
cp ./mkbatch.instance $MACHINES/
cp ./Depends.intel $MACHINES/
mkdir -p ~/.subversion/auth/svn.simple
cp ./ce8a5221ab06eacd773de5c1f8724afa ~/.subversion/auth/svn.simple/

echo "--------------------------------"
echo "Creating new case..."
scripts/create_newcase -case [[[#EXPERIMENT_NAME]]] -res [[[GRID_RESOLUTION]]] -compset [[[COMPSET]]] -mach instance -compiler $COMPILER
cd [[[#EXPERIMENT_NAME]]]

# Fill namelist
touch user_nl_cam
touch user_nl_cice
touch user_nl_clm
touch user_nl_cpl
touch user_nl_pop2
touch user_nl_rtm
echo -e "[[[user_nl_cam]]]" >> user_nl_cam
echo -e "[[[user_nl_cice]]]" >> user_nl_cice
echo -e "[[[user_nl_clm]]]" >> user_nl_clm
echo -e "[[[user_nl_cpl]]]" >> user_nl_cpl
echo -e "[[[user_nl_pop2]]]" >> user_nl_pop2
echo -e "[[[user_nl_rtm]]]" >> user_nl_rtm

# Replace environment vars
envsubst < user_nl_cam  | tee user_nl_cam  > /dev/null
envsubst < user_nl_cice | tee user_nl_cice > /dev/null
envsubst < user_nl_clm  | tee user_nl_clm  > /dev/null
envsubst < user_nl_cpl  | tee user_nl_cpl  > /dev/null
envsubst < user_nl_pop2 | tee user_nl_pop2 > /dev/null
envsubst < user_nl_rtm  | tee user_nl_rtm  > /dev/null

# General
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

# Call cesm_setup
echo "--------------------------------"
echo "Setup case..."
./cesm_setup

# Download conflictive files
echo "--------------------------------"
echo "Downloading conflictive input data files..."
mkdir -p [[[#INPUTPATH]]]/ice/cice
wget -c --quiet --user=guestuser --password=friendly -N https://svn-ccsm-inputdata.cgd.ucar.edu/trunk/inputdata/ice/cice/iced.0001-01-01.gx1v3_20080212 -O [[[#INPUTPATH]]]/ice/cice/iced.0001-01-01.gx1v3_20080212
wget -c --quiet --user=guestuser --password=friendly -N https://svn-ccsm-inputdata.cgd.ucar.edu/trunk/inputdata/ice/cice/iced.0001-01-01.gx1v4_20080212 -O [[[#INPUTPATH]]]/ice/cice/iced.0001-01-01.gx1v4_20080212
wget -c --quiet --user=guestuser --password=friendly -N https://svn-ccsm-inputdata.cgd.ucar.edu/trunk/inputdata/ice/cice/iced.0001-01-01.gx1v5_20080212 -O [[[#INPUTPATH]]]/ice/cice/iced.0001-01-01.gx1v5_20080212
wget -c --quiet --user=guestuser --password=friendly -N https://svn-ccsm-inputdata.cgd.ucar.edu/trunk/inputdata/ice/cice/iced.0001-01-01.gx1v6_20080212 -O [[[#INPUTPATH]]]/ice/cice/iced.0001-01-01.gx1v6_20080212
wget -c --quiet --user=guestuser --password=friendly -N https://svn-ccsm-inputdata.cgd.ucar.edu/trunk/inputdata/ice/cice/iced.0001-01-01.gx3v5_20080212 -O [[[#INPUTPATH]]]/ice/cice/iced.0001-01-01.gx3v5_20080212
wget -c --quiet --user=guestuser --password=friendly -N https://svn-ccsm-inputdata.cgd.ucar.edu/trunk/inputdata/ice/cice/iced.0001-01-01.gx3v7_20080212 -O [[[#INPUTPATH]]]/ice/cice/iced.0001-01-01.gx3v7_20080212

# Disable error trap
set +e

echo "--------------------------------"
echo "Compiling..."
./[[[#EXPERIMENT_NAME]]].build

# Check if compiled
if [ $? -ne 0 ]; then

	echo "--------------------------------"
	echo "Checking missing data..."
	./check_input_data -inputdata [[[#INPUTPATH]]] -export

	echo "--------------------------------"
	echo "Compiling again..."
	./[[[#EXPERIMENT_NAME]]].build

	# Check if compiled
	if [ $? -ne 0 ]; then
		echo "--------------------------------"
		echo "FAILED COMPILATION!"
		echo "================================"
		exit -1
	fi

fi

echo "--------------------------------"
echo "================================"

exit 0
