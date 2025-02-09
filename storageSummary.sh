 #!/bin/bash

#Shows disk models and their sizes

lsblk | awk '{$2=""; $3=""; $5=""; $6=""; $7=""; print $0}'


