#!/bin/bash

source ./scan.lib

scan_domain() {
    DOMAIN=$1
    DIRECTORY=${DOMAIN}_recon
    echo "Creating a directory $DIRECTORY"
    mkdir $DIRECTORY

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
}


report_domain() {
    DOMAIN=$1
    DIRECTORY=${DOMAIN}_recon
    echo "Generating recon report for $DOMAIN..."
    echo "This scan was created on 2023" > $DIRECTORY/report

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


while getopts "m:i:h" OPTION; do
    case $OPTION in
        m)
            MODE=$OPTARG
            ;;
        i)
            INTERACTIVE=true
            ;;
        h)
            echo "crear help"
            ;;
    esac
done

echo "MODE -> $MODE"
echo "INTERACTIVE -> $INTERACTIVE"


if [ $INTERACTIVE ];then
    INPUT="BLANK"
    while [ $INPUT != "quit" ];do
        echo "Please enter a domain!"
        read INPUT
        if [ $INPUT != "quit" ];then
            scan_domain $INPUT
            report_domain $INPUT
        fi
    done
else
    for i in "${@:$OPTIND:$#}";do
        scan_domain $i
        report_domain $i
    done
fi 
