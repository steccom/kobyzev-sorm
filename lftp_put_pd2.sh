#!/bin/bash

BASE_DIR='/usr/local/billing/bm-7/www/operators/cgi-bin/yarovaya'
#echo $FILE
DIR_PD="/abonents/services/"
DIR_PSTN="/abonents/services_pstn/"
OLD="old/"

cd "$BASE_DIR/pd2"
for FILE in `ls services_*`; do
    echo $FILE
    lftp -u isp,isp sorm -e "put -O /abonents/services/ $FILE;exit " && mv $FILE $OLD
done

