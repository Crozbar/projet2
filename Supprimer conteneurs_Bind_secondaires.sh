#!/bin/bash
# Générer tous nos conteneurs secondaires.

for i in $(seq $1)
do
  docker container rm "bind9_sec_DMZ_$i"  --force 2>/dev/null 1>&2 && echo -e "\nLe conteneur bind9_sec_DMZ_$i n'est plus" || echo " "
done
