#!/bin/bash
# Script to activate Wolfram Engine license on first run
# This should be run once to activate the Wolfram Engine with your credentials

if [[ -f config.txt ]]
then 
   configfile=config.txt
else 
   configfile=init.config.txt
fi

echo "================================"
echo "Wolfram Engine Activation Script"
echo "================================"
echo "This script will help you activate Wolfram Engine"
echo "You will need your Wolfram ID and password"
echo ""

source $configfile

# When we are on Github Actions
if [[ $CI ]] 
then
   DOCKERIMG=$(echo $GITHUB_REPOSITORY | tr [A-Z] [a-z])
   TAG=latest
else
   DOCKERIMG=$(echo $MYHUBID/$MYIMG | tr [A-Z] [a-z])
fi

# Prepare Wolfram Engine licensing directory if it doesn't exist
mkdir -p $HOME/.WolframEngine/Licensing
chmod a+rwX $HOME/.WolframEngine/Licensing


echo "Starting Docker container for Wolfram Engine activation..."
echo "You will be prompted to enter your Wolfram ID and password."
echo ""

# Run docker interactively for activation
docker run -it --rm \
  -v ${STATALIC}:/usr/local/stata/stata.lic \
  -v $HOME/.WolframEngine/Licensing:/home/wolframengine/.WolframEngine/Licensing \
  $DOCKERIMG:$TAG wolframscript

echo ""
echo "================================"
echo "Activation complete!"
echo "The license file has been saved to: $HOME/.WolframEngine/Licensing"
echo "You can now use run.sh to run your Stata/Wolfram scripts"
echo "================================"
