wget -q $KG_CARTHAGE_CACHE -O c_cache
chmod +x c_cache
./c_cache -platform iOS
rm -f c_cache
