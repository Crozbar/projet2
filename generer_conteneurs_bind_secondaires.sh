#!/bin/bash
# Générer tous nos conteneurs secondaires.

for i in $(seq $1)
do
  docker container rm "bind9_sec_DMZ_$i"  --force 2>/dev/null 1>&2 && echo -e "\nLe conteneur bind9_sec_DMZ_$i est prêt à être remplacé" || echo " "
  docker run -d -it --name "bind9_sec_DMZ_$i" --network macnet64 -v /dns-secondaire1/zones:/var/lib/bind -v /dns-secondaire1/named.d:/etc/bind ubuntu/bind9 /bin/bash && echo "Création du conteneur bind9_sec_DMZ_$i"
  docker exec -it "bind9_sec_DMZ_$i" chown bind:bind /var/lib/bind
  docker exec -it "bind9_sec_DMZ_$i" service named start
done
