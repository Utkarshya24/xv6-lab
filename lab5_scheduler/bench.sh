#!/bin/bash

echo "================================"
echo "CPU Scheduling Hardware Benchmark"
echo "================================"

echo
echo "CPU count:"
nproc

echo
echo "CPU topology:"
lscpu | grep -E "CPU\(s\)|Thread|Core|Socket|NUMA"

echo
echo "NUMA topology:"
numactl --hardware 2>&1

echo
echo "Normal execution:"
/usr/bin/time -f "Elapsed: %e sec" ./bench

echo
echo "Pinned to CPU 0:"
/usr/bin/time -f "Elapsed: %e sec" taskset -c 0 ./bench

if [ "$(nproc)" -ge 2 ]; then

    echo
    echo "Pinned to CPU 1:"
    /usr/bin/time -f "Elapsed: %e sec" taskset -c 1 ./bench

    echo
    echo "Pinned to CPUs 0-1:"
    /usr/bin/time -f "Elapsed: %e sec" taskset -c 0-1 ./bench

fi

echo
echo "Benchmark complete."