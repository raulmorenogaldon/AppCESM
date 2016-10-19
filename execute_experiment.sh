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

# Check if it is continue run
CONTINUE_DATE=$(ls -x1 archive/rest/ | tail -1)
if [ -n "$CONTINUE_DATE" ]; then
	echo "--------------------------------"
	echo "Setting continue run..."
	xmlchange CONTINUE_RUN "TRUE"
	cp archive/rest/$CONTINUE_DATE/* run/
fi

echo "--------------------------------"
echo "Executing case..."
./[[[#EXPERIMENT_NAME]]].run

# Disable error checking
set +e

echo "--------------------------------"
echo "Compressing output data..."
tar -czvf output.tar.gz run/ archive/
mv output.tar.gz [[[#OUTPUTPATH]]]/
cp -r archive [[[#OUTPUTPATH]]]/
cp -r run [[[#OUTPUTPATH]]]/

echo "--------------------------------"
echo "================================"

exit 0
