#!/bin/bash
############################################################
# Help                                                     #
############################################################
Help()
{
   # Display Help
  echo "We do cool shit here."
  echo
  echo "Syntax: scriptTemplate [-g|h|v|V]"
  echo "options:"
  echo "g     Print the GPL license notification."
  echo "h     Print this Help."
  echo "v     Verbose mode."
  echo "V     Print software version and exit."
  echo
}

############################################################
############################################################
# Main program                                             #
############################################################
############################################################
############################################################
# Process the input options. Add options as needed.        #
############################################################
# Get the options
while getopts ":h" option; do
    case $option in
      help) # display Help
        Help
        echo "Hello world!"
        exit;;
    esac
done




# while getopts n:c:v:b: flag
# do
#     case "${flag}" in
#         n) namespace=${OPTARG};;
#         c) chartname=${OPTARG};;
#         v) valuesfile=${OPTARG};;
#         b) createnamespace=${OPTARG};;
#     esac
# done
# echo "NameSpace: $namespace";
# echo "Chart Name: $chartname";
# echo "Values File: $valuesfile";
# echo "Create Namespace?: $createnamespace";
