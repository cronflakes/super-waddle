#!/bin/bash

ARG1=$1
ARG2=$2

if [ $# -lt 2 ]; then
        echo "Usage: ./byobu-patch.sh <hosts file> <sadf|hspatch>"
        exit 0
fi

IFS=,$'\n' read -d '' -r -a machineArr < $ARG1

read -p "How many servers in wave?: " machinesInWave
if [ "$machinesInWave" -gt 8 ]; then
        echo "Byobu can only have a maximum of 8 panes open per window."
        exit 0
fi

byobu kill-server
byobu new-session -d -s $USER "bash -l"
byobu send-keys "sudo su - $ARG2" C-m

for ((i = 1; i < $machinesInWave; i++)) do
        case $i in
                1|2|3)
                        byobu split-window -v
                        byobu send-keys "sudo su - $ARG2" C-m
                        ;;
                4)
                        byobu select-pane -t 1
                        byobu split-window -v
                        byobu send-keys "sudo su - $ARG2" C-m
                        ;;
                5|7)
                        byobu select-pane -t 0
                        byobu split-window -v
                        byobu send-keys "sudo su - $ARG2" C-m
                        ;;
                6)
                        byobu split-window -v
                        byobu send-keys "sudo su - $ARG2" C-m
                        ;;
        esac
done



for ((i = 0; i < $machinesInWave; i++)) do
        byobu select-pane -t $i
        byobu send-keys "ssh jp0017" C-m
        byobu send-keys "ssh ${machineArr[i]}" C-m
done

byobu select-pane -t 0
byobu attach-session -t $USER
