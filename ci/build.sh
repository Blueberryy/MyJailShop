#!/bin/bash
set -ev

BID=$6
FILE=MyJS-$2-$BID.zip
HOST=$3
USER=$4
PASS=$5


echo "Download und extract sourcemod"
wget -q "http://www.sourcemod.net/latest.php?version=$1&os=linux" -O sourcemod.tar.gz
# wget "http://www.sourcemod.net/latest.php?version=$1&os=linux" -O sourcemod.tar.gz
tar -xzf sourcemod.tar.gz

echo "Give compiler rights for compile"
chmod +x addons/sourcemod/scripting/spcomp

echo "Set plugins version"
for file in addons/sourcemod/scripting/myjailshop.sp
do
  sed -i "s/<COMMIT>/$BID/g" $file > output.txt
  rm output.txt
done


echo "Compile MyJailShop plugins"
addons/sourcemod/scripting/spcomp -E -v0 addons/sourcemod/scripting/myjailshop.sp
addons/sourcemod/scripting/spcomp -E -v0 addons/sourcemod/scripting/myjailshop_door.sp
addons/sourcemod/scripting/spcomp -E -v0 addons/sourcemod/scripting/myjailshop_freeday.sp
addons/sourcemod/scripting/spcomp -E -v0 addons/sourcemod/scripting/myjailshop_hud.sp
addons/sourcemod/scripting/spcomp -E -v0 addons/sourcemod/scripting/myjailshop_blackout.sp
addons/sourcemod/scripting/spcomp -E -v0 addons/sourcemod/scripting/myjailshop_jetpack.sp
addons/sourcemod/scripting/spcomp -E -v0 addons/sourcemod/scripting/myjailshop_jihad.sp
addons/sourcemod/scripting/spcomp -E -v0 addons/sourcemod/scripting/myjailshop-sm-store.sp
addons/sourcemod/scripting/spcomp -E -v0 addons/sourcemod/scripting/myjailshop_tacticalshield.sp
addons/sourcemod/scripting/spcomp -E -v0 addons/sourcemod/scripting/myjailshop_icegrenade.sp
addons/sourcemod/scripting/spcomp -E -v0 addons/sourcemod/scripting/myjailshop_parachute.sp



echo "Remove plugins folder if exists"
if [ -d "addons/sourcemod/plugins" ]; then
  rm -r addons/sourcemod/plugins
fi

echo "Create clean plugins folder"
mkdir addons/sourcemod/plugins
mkdir addons/sourcemod/plugins/disabled

echo "Move all binary files to plugins folder"
for file in *.smx
do
  mv $file addons/sourcemod/plugins
done

echo "Move all optional binary files to plugins disabled folder"
  mv addons/sourcemod/plugins/myjailshop-frozdark-shop.smx addons/sourcemod/plugins/disabled
  mv addons/sourcemod/plugins/myjailshop-sm-store.smx addons/sourcemod/plugins/disabled
  mv addons/sourcemod/plugins/myjailshop-zephyrus-store.smx addons/sourcemod/plugins/disabled
  mv addons/sourcemod/plugins/myjailshop_tacticalshield.smx addons/sourcemod/plugins/disabled

echo "Remove build folder if exists"
if [ -d "build" ]; then
  rm -r build
fi

echo "Create clean build & sub folder"
mkdir build

echo "Move addons, cfg sound & fastdl folder"
mv addons cfg sound fastDL build

echo "Move license to build"
mv install.txt license.txt CHANGELOG.md build/

echo "Remove sourcemod folders"
rm -r build/addons/metamod
rm -r build/addons/sourcemod/bin
rm -r build/addons/sourcemod/configs
rm -r build/addons/sourcemod/data
rm -r build/addons/sourcemod/extensions
rm -r build/addons/sourcemod/gamedata
rm -r build/addons/sourcemod/scripting
rm -r build/addons/sourcemod/translations
rm -r build/cfg/sourcemod
rm build/addons/sourcemod/*.txt

echo "Remove placeholder files"
rm -r build/addons/sourcemod/logs/MyJailShop/.gitkeep
rm -r build/cfg/MyJailShop/.gitkeep

echo "Download source and move to folder"
git clone --depth=50 --branch=$2 https://github.com/shanapu/MyJailShop.git source/MyJailShop
mv source/MyJailShop/addons/sourcemod/scripting build/addons/sourcemod

echo "Create clean translation folder"
mkdir build/addons/sourcemod/translations

echo "Download und unzip translations files"
wget -q -O translations.zip http://translator.mitchdempsey.com/sourcemod_plugins/268/download/MyJailShop.translations.zip
unzip -qo translations.zip -d build/

echo "Clean root folder"
rm sourcemod.tar.gz
rm translations.zip

echo "Go to build folder"
cd build

echo "Compress directories and files"
zip -9rq $FILE addons fastDL cfg sound install.txt license.txt downloads.txt CHANGELOG.md

echo "Upload file"
lftp -c "set ftp:ssl-allow no; set ssl:verify-certificate no; open -u $USER,$PASS $HOST; put -O MyJailShop/downloads/SM$1/$2/ $FILE"

echo "Build done"
