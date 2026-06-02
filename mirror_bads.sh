unset ftp_proxy
cd $BM_ROOT/www/html/priv
wget -N -m ftp://isp_bad:isp_bad@sorm/payments/balance-fillup*_2023*
wget -N -m ftp://isp_bad:isp_bad@sorm/abonents/abonents*_2023*

echo $BM_ROOT/www/html/priv
