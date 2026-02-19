#!/bin/bash

if [[ -f config.txt ]]
then 
   configfile=config.txt
else 
   configfile=init.config.txt
fi



echo "================================"
echo "Pulling defaults from ${configfile}:"
cat $configfile
echo "--------------------------------"

source $configfile

echo "================================"
echo "Running docker:"
set -ev

# When we are on Github Actions
if [[ $CI ]] 
then
   DOCKEROPTS="--rm"
   DOCKERIMG=$(echo $GITHUB_REPOSITORY | tr [A-Z] [a-z])
   TAG=latest
else
   DOCKEROPTS="-it --rm -u $(id -u ${USER}):$(id -g ${USER}) "
   DOCKERIMG=$(echo $MYHUBID/$MYIMG | tr [A-Z] [a-z])
fi



# Prepare Wolfram Engine licensing directory if it doesn't exist
mkdir -p $HOME/.WolframEngine/Licensing
chmod a+rwX $HOME/.WolframEngine/Licensing

# run the docker and the Stata file
# note that the working directory will be set to '/code' by default
# Map both Stata license and Wolfram Engine licensing directory

time docker run $DOCKEROPTS \
  -v ${STATALIC}:/usr/local/stata/stata.lic \
  -v $HOME/.WolframEngine/Licensing:/home/wolframengine/.WolframEngine/Licensing \
  -v $(pwd):/project \
  $DOCKERIMG:$TAG "$@"

