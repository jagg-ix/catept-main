#!/bin/bash
# Run black hole ringdown simulation

# Clean previous outputs
rm -f bh_ringdown.* RESTART EXIT

# Start i-PI server in background
i-pi input.xml &
IPID=$!

# Wait for socket
sleep 2

# Start black hole driver
python ../../../drivers/py/entropic_drivers.py \
    --mode blackhole \
    --mass 1.0 \
    --spin 0.0 \
    --unix bh_driver

# Wait for i-PI to finish
wait $IPID

echo "Simulation complete. Analyzing results..."

# Validation analysis
python analyze_bh.py
