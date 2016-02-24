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

# Change to experiment folder
cd [[[#EXPERIMENT_NAME]]]

echo "================================"
echo "--------------------------------"
echo "Setup run dates..."
xmlchange RUN_STARTDATE [[[RUN_STARTDATE]]]
xmlchange START_TOD [[[START_TOD]]]
xmlchange RUN_REFCASE [[[RUN_REFCASE]]]
xmlchange RUN_REFDATE [[[RUN_REFDATE]]]
xmlchange RUN_REFTOD [[[RUN_REFTOD]]]
xmlchange BRNCH_RETAIN_CASENAME [[[BRNCH_RETAIN_CASENAME]]]
xmlchange GET_REFCASE [[[GET_REFCASE]]]

xmlchange STOP_OPTION [[[STOP_OPTION]]]
xmlchange STOP_N [[[STOP_N]]]
xmlchange STOP_DATE [[[STOP_DATE]]]

xmlchange CONTINUE_RUN [[[CONTINUE_RUN]]]

xmlchange NCPL_BASE_PERIOD [[[NCPL_BASE_PERIOD]]]
xmlchange ATM_NCPL [[[ATM_NCPL]]]
xmlchange LND_NCPL [[[LND_NCPL]]]
xmlchange ICE_NCPL [[[ICE_NCPL]]]
xmlchange OCN_NCPL [[[OCN_NCPL]]]
xmlchange GLC_NCPL [[[GLC_NCPL]]]
xmlchange ROF_NCPL [[[ROF_NCPL]]]
xmlchange WAV_NCPL [[[WAV_NCPL]]]
xmlchange OCN_TIGHT_COUPLING [[[OCN_TIGHT_COUPLING]]]

xmlchange BUDGETS [[[BUDGETS]]]
xmlchange COMP_RUN_BARRIERS [[[COMP_RUN_BARRIERS]]]
xmlchange INFO_DBUG [[[INFO_DBUG]]]
xmlchange TIMER_LEVEL [[[TIMER_LEVEL]]]
xmlchange CHECK_TIMING [[[CHECK_TIMING]]]
xmlchange SAVE_TIMING [[[SAVE_TIMING]]]

echo "--------------------------------"
echo "Executing case..."
./[[[#EXPERIMENT_NAME]]].run

echo "--------------------------------"
echo "================================"

exit 0
