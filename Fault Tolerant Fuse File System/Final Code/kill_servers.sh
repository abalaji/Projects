#! /bin/bash

for i in `ps ax | grep "[p]ython simpleht.py" | cut -d " " -f 1,2` ; do kill $i ;done
kill -3 $(ps aux | grep '[p]ython refresh_v1.py' | awk '{print $2}')
fusermount -u fusemount
