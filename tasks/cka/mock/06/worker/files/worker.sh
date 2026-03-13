#!/bin/bash
echo " *** worker pc  cka mock-6  "

# Create artifact directories for tasks that require saved output
mkdir -p /var/work/tests/artifacts/{3,16,17,20}
mkdir -p /var/work/tests/result
chmod 777 -R /var/work/tests/artifacts
