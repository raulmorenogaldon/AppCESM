#!/bin/bash

MACHINES=scripts/ccsm_utils/Machines

# Error checking
set -e

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
scripts/create_newcase -case [[[EXPERIMENT_NAME]]] -res [[[GRID_RESOLUTION]]] -compset [[[COMPSET]]] -mach instance -compiler intel
cd [[[EXPERIMENT_NAME]]]
./cesm_setup

echo "--------------------------------"
echo "Compiling case..."
./xmlchange PIO_CONFIG_OPTS=" --enable-mpiio --enable-pnetcdf "
./[[[EXPERIMENT_NAME]]].build

echo "--------------------------------"
echo "================================"

exit 0
