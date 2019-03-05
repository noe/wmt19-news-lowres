
dev_file_en=newsdev2019.tc.en
dev_file_kk=newsdev2019.tc.kk




head -n 1566 $dev_file_en > newsdev2019_1.tc.en
tail -n +1567 $dev_file_en > newstest2019.tc.en

mv newsdev2019_1.tc.en $dev_file_en


head -n 1566 $dev_file_kk > newsdev2019_1.tc.kk
tail -n +1567 $dev_file_kk > newstest2019.tc.kk

mv newsdev2019_1.tc.kk $dev_file_kk






