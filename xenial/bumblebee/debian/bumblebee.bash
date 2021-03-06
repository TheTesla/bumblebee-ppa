#!/bin/bash


if [ 0 -eq $# ]
then
  ConfFile="/etc/bumblebee/bumblebee.conf"
else
  ConfFile=$1
fi


ConfDriver=$( crudini --get $ConfFile bumblebeed driver )
ConfKernelDriver=$( crudini --get $ConfFile driver-nvidia kerneldriver )
ConfLibraryPath=$( crudini --get $ConfFile driver-nvidia librarypath )
ConfXorgModulePath=$( crudini --get $ConfFile driver-nvidia xorgmodulepath )

echo "Bumblebee config file: $ConfFile"
echo "  Raw config parameters: "
echo "    Driver = $ConfDriver"
echo "    KernelDriver = $ConfKernelDriver"
echo "    LibraryPath = $ConfLibraryPath"
echo "    XorgModulePath = $ConfXorgModulePath"

Driver=$ConfDriver

KernelDriver=$(find /lib/modules/$(uname -r) -name $ConfKernelDriver.ko)

LibraryPath=
for i in $(echo "$ConfLibraryPath" | sed "s/:/ /g")
do
  LibraryPath=$LibraryPath:$(ls -d $i)
done
LibraryPath=${LibraryPath:1}

XorgModulePath=
for i in $(echo "$ConfXorgModulePath" | sed "s/,/ /g")
do
  XorgModulePath=$XorgModulePath,$(ls -d $i)
done
XorgModulePath=${XorgModulePath:1}

echo "  After applying wildcard:"
echo "    Driver = $Driver"
echo "    KernelDriver = $KernelDriver"
echo "    LibraryPath = $LibraryPath"
echo "    XorgModulePath = $XorgModulePath"

bboptions="--driver $Driver --driver-module $KernelDriver --ldpath $LibraryPath --module-path $XorgModulePath"

bumblebeed -C $ConfFile -vvvv --use-syslog $bboptions

