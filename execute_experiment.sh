#!/bin/bash

MACHINES=scripts/ccsm_utils/Machines

# Error checking
set -e

# Change to experiment folder
cd [[[EXPERIMENT_NAME]]]

echo "================================"
echo "--------------------------------"
echo "Setup run dates..."
./xmlchange STOP_N=[[[STOP_N]]],STOP_OPTION="ndays"

echo "--------------------------------"
echo "Executing case..."
./[[[EXPERIMENT_NAME]]].run

echo "--------------------------------"
echo "================================"
