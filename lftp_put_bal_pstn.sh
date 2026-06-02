#!/bin/bash

BASE_DIR='/usr/local/billing/bm-7/www/operators/cgi-bin/yarovaya'
#echo $FILE
DIR_PD="/abonents/abonents"
DIR_PSTN="/abonents/abonents_pstn"
DIR_ATS="/cdr/atc/"
DIR_PAYMENT="/payments"
OLD="old/"

cd "$BASE_DIR/balance"
for FILE in `ls balance-*`; do
    echo $FILE
#    lftp -u isp,isp sorm -e "put -O payments/balance-fillup-pstn/ $FILE;exit " && mv $FILE $OLD
    lftp -u isp,isp sorm -e "put -O payments/bank-transaction/ $FILE;exit " && mv $FILE $OLD
done

