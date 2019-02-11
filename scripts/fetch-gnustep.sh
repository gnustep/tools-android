#!/bin/bash

# fetch gnustep and libobjc2
cd "${ANDROID_GNUSTEP_INSTALL_ROOT}"

echo "FETCH GNUSTEP AND LIBOBJC2"
if
    test -d gnustep
then
    echo "ALREADY EXISTS"
else
    echo "CREATE GNUSTEP DIR"
    mkdir gnustep
fi

echo "GOING INTO GNUSTEP DIR"
pushd gnustep

PREFIX="git@github.com:gnustep/"
FILES="libobjc2 libs-base tools-make"

for file in ${FILES}
do
    GITURL=${PREFIX}${file}
    if
	test -d ${file}
    then
        cd $file
        git pull ${GITURL} master
	cd ..
    else
	git clone ${GITURL}
    fi
done

echo "DONE"
popd


