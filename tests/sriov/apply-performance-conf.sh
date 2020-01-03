#!/bin/bash

set -e
set -x

oc apply -f templates/performance.yaml

echo "Waiting for worker node to become 'NotReady,SchedulingDisabled' ..."
count=0
while [ "$(oc get nodes -o wide | grep "worker-0" | awk -F' ' '{print $2}')" != "NotReady,SchedulingDisabled" ]
do
	sleep 30
	count=$(($count+1))
	timepassed=$(($count*30))
	if (( $timepassed > 1200 )); then
		echo "Time out waiting for worker node to become 'NotReady,SchedulingDisabled'."
		exit 1
	fi
done

echo "Waiting for nodes to become Ready after applying performance config ..."
count=0
while [ "$(oc get nodes -o wide | grep "worker-0" | awk -F' ' '{print $2}')" != "Ready" ] || \
      [ "$(oc get nodes -o wide | grep "master-0" | awk -F' ' '{print $2}')" != "Ready" ] || \
      [ "$(oc get nodes -o wide | grep "master-1" | awk -F' ' '{print $2}')" != "Ready" ] || \
      [ "$(oc get nodes -o wide | grep "master-2" | awk -F' ' '{print $2}')" != "Ready" ];
do
	sleep 30
	count=$(($count+1))
	timepassed=$(($count*30))
	if (( $timepassed > 1200 )); then
		echo "Time out waiting for nodes to become Ready after applying performance config."
		exit 1
	fi
done