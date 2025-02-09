#!/bin/bash

#Shows OS name and version 
echo -n ; grep -E '^VERSION|NAME' /etc/os-release

#Shows CPU model name and model
echo -n ; lscpu | grep -E '^Model name|^Model'

#
echo -n ; sudo cat /proc/meminfo | grep -E '^MemTotal'
