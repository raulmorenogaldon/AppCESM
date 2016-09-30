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
echo "Executing case..."
./[[[#EXPERIMENT_NAME]]].run

echo "--------------------------------"
echo "Compressing output data..."
tar -czvf ../output.tar.gz ./run/

echo "--------------------------------"
echo "================================"

exit 0
