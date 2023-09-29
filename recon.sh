#!/bin/bash

source ./scan.lib

getopts "m:" OPTION
MODE=$OPTARG

create_dafault_directories() {
    DIRECTORY=${DOMAIN}_recon

    echo "Creating a directory $DIRECTORY."
    mkdir $DIRECTORY

    echo "Generating recon report from output files..."
    #TODAY=$(date)
    echo "This scan was created on 2023" > $DIRECTORY/report
}

create_reports() {

    if [ -f $DIRECTORY/nmap_result ]
    then
        echo "Report for Nmap:" >>  $DIRECTORY/report
	    grep -E "^s*\S+\s+\S+\s+\S+\s*$" $DIRECTORY/nmap_result >> $DIRECTORY/report

    elif [ -f $DIRECTORY/dirsearch_result ]
    then
        echo "Report for Dirsearch" >> $DIRECTORY/report
	    cat $DIRECTORY/dirsearch_result >> $DIRECTORY/report

    elif [ -f $DIRECTORY/crt_result ]
    then
        echo "Report for crt" >> $DIRECTORY/report
	    jq -r ".[] | .common_name" $DIRECTORY/crt_result >> $DIRECTORY/report
    fi
}


for i in "${@:$OPTIND:$#}"
do
    echo "Dominio -> $i"

    DOMAIN=$i

    create_dafault_directories

    case $MODE in
        nmap-only)
            nmap_scan
            ;;

        dirsearch-only)
            dirsearch_scan
            ;;

        crt-only)
            crt_scan
            ;;

        *)
            nmap_scan
            dirsearch_scan
            crt_scan
            ;;
    esac


    create_reports

done