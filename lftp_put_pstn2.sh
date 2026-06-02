#!/bin/bash

OLD="old/"
BASE_DIR='/usr/local/billing/bm-7/www/operators/cgi-bin/yarovaya'
#echo $FILE
cd "$BASE_DIR/pstn2"
for FILE in `ls services-pstn_*`; do
    echo $FILE
    lftp -u isp,isp sorm -e "put -O /abonents/services-pstn $FILE;exit " && mv $FILE $OLD
done

