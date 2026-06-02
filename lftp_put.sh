#!/bin/bash

BASE_DIR='/usr/local/billing/bm-7/www/operators/cgi-bin/yarovaya'
#echo $FILE
DIR_PD="/abonents/abonents"
DIR_PSTN="/abonents/abonents_pstn"
DIR_ATS="/cdr/atc/"
DIR_PAYMENT="/payments"
OLD="old/"

cd "$BASE_DIR/atccdr"
for FILE in `ls atc_*`; do
    echo $FILE
    lftp -u isp,isp sorm -e "put -O cdr/atc/ $FILE;exit " && mv $FILE $OLD
done

