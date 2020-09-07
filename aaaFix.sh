find /hab/pkgs/core/corretto/11.0.8.10.1/20200907133205/bin -type f -executable -print
exit 1
find . -type f -executable -print0 | while read -d $'\0'
do
	echo $file
done




    #-exec sh -c 'file -i "$1" | grep -q "x-executable; charset=binary"' _ {} \; \
    #-exec patchelf --set-rpath "${LD_RUN_PATH}" {} \
