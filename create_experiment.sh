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

echo "--------------------------------"
echo "Configuring variables..."

# Fill namelist
echo -e "[[[user_nl_cam]]]" >> user_nl_cam
echo -e "[[[user_nl_cice]]]" >> user_nl_cice
echo -e "[[[user_nl_clm]]]" >> user_nl_clm
echo -e "[[[user_nl_cpl]]]" >> user_nl_cpl
echo -e "[[[user_nl_pop2]]]" >> user_nl_pop2
echo -e "[[[user_nl_rtm]]]" >> user_nl_rtm

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

# Run
xmlchange RUN_STARTDATE [[[RUN_STARTDATE]]]
xmlchange START_TOD [[[START_TOD]]]
xmlchange RUN_REFCASE [[[RUN_REFCASE]]]
xmlchange RUN_REFDATE [[[RUN_REFDATE]]]
xmlchange RUN_REFTOD [[[RUN_REFTOD]]]
xmlchange BRNCH_RETAIN_CASENAME [[[BRNCH_RETAIN_CASENAME]]]
xmlchange STOP_OPTION [[[STOP_OPTION]]]
xmlchange STOP_N [[[STOP_N]]]
xmlchange STOP_DATE [[[STOP_DATE]]]

# Restart
xmlchange GET_REFCASE [[[GET_REFCASE]]]
xmlchange CONTINUE_RUN [[[CONTINUE_RUN]]]

# NCPL
xmlchange NCPL_BASE_PERIOD [[[NCPL_BASE_PERIOD]]]
xmlchange ATM_NCPL [[[ATM_NCPL]]]
xmlchange LND_NCPL [[[LND_NCPL]]]
xmlchange ICE_NCPL [[[ICE_NCPL]]]
xmlchange OCN_NCPL [[[OCN_NCPL]]]
xmlchange GLC_NCPL [[[GLC_NCPL]]]
xmlchange ROF_NCPL [[[ROF_NCPL]]]
xmlchange WAV_NCPL [[[WAV_NCPL]]]
xmlchange OCN_TIGHT_COUPLING [[[OCN_TIGHT_COUPLING]]]

# Others
xmlchange BUDGETS [[[BUDGETS]]]
xmlchange COMP_RUN_BARRIERS [[[COMP_RUN_BARRIERS]]]
xmlchange INFO_DBUG [[[INFO_DBUG]]]
xmlchange TIMER_LEVEL [[[TIMER_LEVEL]]]
xmlchange CHECK_TIMING [[[CHECK_TIMING]]]
xmlchange SAVE_TIMING [[[SAVE_TIMING]]]

# Restart files every 1 time unit (STOP_OPTION == REST_OPTION)
xmlchange REST_N "1"
xmlchange REST_OPTION [[[REST_OPTION]]]
xmlchange REST_N [[[REST_N]]]

# Download conflictive files
echo "--------------------------------"
echo "Downloading conflictive input data files..."
mkdir -p [[[#INPUTPATH]]]/ice/cice
wget -c --no-check-certificate --quiet --user=guestuser --password=friendly -N https://svn-ccsm-inputdata.cgd.ucar.edu/trunk/inputdata/ice/cice/iced.0001-01-01.gx1v3_20080212 -O [[[#INPUTPATH]]]/ice/cice/iced.0001-01-01.gx1v3_20080212
wget -c --no-check-certificate --quiet --user=guestuser --password=friendly -N https://svn-ccsm-inputdata.cgd.ucar.edu/trunk/inputdata/ice/cice/iced.0001-01-01.gx1v4_20080212 -O [[[#INPUTPATH]]]/ice/cice/iced.0001-01-01.gx1v4_20080212
wget -c --no-check-certificate --quiet --user=guestuser --password=friendly -N https://svn-ccsm-inputdata.cgd.ucar.edu/trunk/inputdata/ice/cice/iced.0001-01-01.gx1v5_20080212 -O [[[#INPUTPATH]]]/ice/cice/iced.0001-01-01.gx1v5_20080212
wget -c --no-check-certificate --quiet --user=guestuser --password=friendly -N https://svn-ccsm-inputdata.cgd.ucar.edu/trunk/inputdata/ice/cice/iced.0001-01-01.gx1v6_20080212 -O [[[#INPUTPATH]]]/ice/cice/iced.0001-01-01.gx1v6_20080212
wget -c --no-check-certificate --quiet --user=guestuser --password=friendly -N https://svn-ccsm-inputdata.cgd.ucar.edu/trunk/inputdata/ice/cice/iced.0001-01-01.gx3v5_20080212 -O [[[#INPUTPATH]]]/ice/cice/iced.0001-01-01.gx3v5_20080212
wget -c --no-check-certificate --quiet --user=guestuser --password=friendly -N https://svn-ccsm-inputdata.cgd.ucar.edu/trunk/inputdata/ice/cice/iced.0001-01-01.gx3v7_20080212 -O [[[#INPUTPATH]]]/ice/cice/iced.0001-01-01.gx3v7_20080212

# Hybrid run
echo "--------------------------------"
echo "Copying restart data..."
cp -rfv [[[#INPUTPATH]]]/run run || : # Avoid error code in command

echo "--------------------------------"
echo "Copying archive data..."
cp -rfv [[[#INPUTPATH]]]/archive archive || : # Avoid error code in command

echo "--------------------------------"
echo "Linking archive and run to output ..."
ln -s $(pwd)/run [[[#OUTPUTPATH]]]/run || : # Avoid error code in command
ln -s $(pwd)/archive [[[#OUTPUTPATH]]]/archive || : # Avoid error code in command

# Check if there is a previous restart file
CONTINUE_DATE=$(ls -x1 archive/rest/ | tail -1)
if [ -n "$CONTINUE_DATE" ]; then
	echo "--------------------------------"
	echo "Copying restart run from archive..."
	cp archive/rest/$CONTINUE_DATE/* run/
fi

# Call cesm_setup
echo "--------------------------------"
echo "Setup case..."
./cesm_setup

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
