# !/bin/bash
SOURCEIPA="$1"
DEVELOPER="$2"
MOBILEPROV="$3"
TARGET="$4"
BUNDLE="$5"
CFBV="$6"
CFBSV="$7"
CFBN="$8"
CFBDN="$9"
PUBSIGN="$10"
Black='\033[0;30m'
Red='\033[0;31m'
Green='\033[0;32m'
Yellow='\033[0;33m'
Blue='\033[0;34m'
Purple='\033[0;35m'
Cyan='\033[0;36m'
White='\033[0;37m'
NC='\033[0m'

unzip -qo "$SOURCEIPA" -d extracted
APPLICATION=$(ls extracted/Payload/)
#codesign --verify -vvvv "extracted/Payload/$APPLICATION"
security cms -D -i "extracted/Payload/$APPLICATION/embedded.mobileprovision" > oldmaxentitlements1.txt
/usr/libexec/PlistBuddy -c 'Print :Entitlements' oldmaxentitlements1.txt > oldmaxentitlements.txt

cp "$MOBILEPROV" "extracted/Payload/$APPLICATION/embedded.mobileprovision"
security cms -D -i "extracted/Payload/$APPLICATION/embedded.mobileprovision" > newmaxentitlements1.txt
/usr/libexec/PlistBuddy -c 'Print :Entitlements' newmaxentitlements1.txt > newmaxentitlements.txt
for i in "extracted/Payload/$APPLICATION/Frameworks/libswift*.dylib"; do 
    lipo ${i} -remove arm64e -output ${i} > /dev/null 2>&1
done
printf "${Green}Updating below ${Yellow}Info.plist Values ${Green}as per user input${NC}\n"
#Not signing swift support folder, if needed remove /Payload
find -d extracted/Payload  \( -name "*.app" -o -name "*.appex" -o -name "*.framework" -o -name "*.dylib" \) > directories.txt
if [[ "$BUNDLE" != 'null.null' ]]; then
   OLDBUNDLEID=$(/usr/libexec/PlistBuddy -c "Print :CFBundleIdentifier" "extracted/Payload/$APPLICATION/Info.plist")
   printf "${Green}Updating CFBundleIdentifier from $OLDBUNDLEID to : ${Yellow}$BUNDLE${NC}\n"
   /usr/libexec/PlistBuddy -c "Set:CFBundleIdentifier $BUNDLE" "extracted/Payload/$APPLICATION/Info.plist"
fi
if [[ "$CFBV" != 'null.null' ]]; then
   OLDBUNDLEVER=$(/usr/libexec/PlistBuddy -c "Print :CFBundleVersion" "extracted/Payload/$APPLICATION/Info.plist")
   printf "${Green}Updating CFBundleVersion from $OLDBUNDLEVER to : ${Yellow}$CFBV${NC}\n"
   /usr/libexec/PlistBuddy -c "Set:CFBundleVersion $CFBV" "extracted/Payload/$APPLICATION/Info.plist" 
   echo $CFBV > bundleversion.txt
else 
   CFBV=$(/usr/libexec/PlistBuddy -c "Print :CFBundleVersion" "extracted/Payload/$APPLICATION/Info.plist")
   printf "${Green}Using Previous Value for CFBundleVersion: ${Yellow}$CFBV${NC}\n"
   echo $CFBV > bundleversion.txt
fi
if [[ "$CFBSV" != 'null.null' ]]; then
   OLDBUNDLESVER=$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "extracted/Payload/$APPLICATION/Info.plist")
   printf "${Green}Updating CFBundleShortVersionString from $OLDBUNDLESVER to : ${Yellow}$CFBSV${NC}\n"
   /usr/libexec/PlistBuddy -c "Set:CFBundleShortVersionString $CFBSV" "extracted/Payload/$APPLICATION/Info.plist"
else 
   CFBSV=$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "extracted/Payload/$APPLICATION/Info.plist")
   printf "${Green}Using Previous Value for CFBundleShortVersionString: ${Yellow}$CFBSV${NC}\n"
fi
# if [[ "$CFBN" != 'null.null' ]]; then
#    OLDBUNDLENAME=$(/usr/libexec/PlistBuddy -c "Print :CFBundleName" "extracted/Payload/$APPLICATION/Info.plist") > /dev/null 2>&1
#    /usr/libexec/PlistBuddy -c "Add:CFBundleName string" "extracted/Payload/$APPLICATION/Info.plist"  > /dev/null 2>&1
#    echo "Updating CFBundleName from $OLDBUNDLENAME to : $CFBN"
#    /usr/libexec/PlistBuddy -c "Set:CFBundleName $CFBN" "extracted/Payload/$APPLICATION/Info.plist"
# else 
#    CFBN=$(/usr/libexec/PlistBuddy -c "Print :CFBundleName" "extracted/Payload/$APPLICATION/Info.plist")
#    echo "Using Previous Value for CFBundleName: $CFBN"
# fi
if [[ "$CFBDN" != 'null.null' ]]; then
   OLDBUNDLEDNAME=$(/usr/libexec/PlistBuddy -c "Print :CFBundleDisplayName" "extracted/Payload/$APPLICATION/Info.plist") > /dev/null 2>&1
   /usr/libexec/PlistBuddy -c "Add:CFBundleDisplayName string" "extracted/Payload/$APPLICATION/Info.plist" > /dev/null 2>&1
   printf "${Green}Updating CFBundleDisplayName from $OLDBUNDLEDNAME to : ${Yellow}$CFBDN${NC}\n"
   CFBN=$CFBDN > /dev/null 2>&1
   /usr/libexec/PlistBuddy -c "Set:CFBundleDisplayName $CFBDN" "extracted/Payload/$APPLICATION/Info.plist"
else 
   OLDBUNDLENAME=$(/usr/libexec/PlistBuddy -c "Print :CFBundleName" "extracted/Payload/$APPLICATION/Info.plist") > /dev/null 2>&1
   /usr/libexec/PlistBuddy -c "Add:CFBundleDisplayName string" "extracted/Payload/$APPLICATION/Info.plist" > /dev/null 2>&1
   CFBDN=$OLDBUNDLENAME
   #CFBDN=$(/usr/libexec/PlistBuddy -c "Print :CFBundleDisplayName" "extracted/Payload/$APPLICATION/Info.plist")
   printf "${Green}Using Previous Value from CFBundleName for CFBundleDisplayName: ${Yellow}$CFBDN${NC}\n"
fi
echo    # (optional) move to a new line
printf "${Green}App Name on device will be seen as ${Yellow}$CFBDN${NC}\n"
UIDEVICE=$(/usr/libexec/PlistBuddy -c "Print :UIDeviceFamily" "extracted/Payload/$APPLICATION/Info.plist")
printf "${Green}UIDeviceFamily:${Yellow}$UIDEVICE${NC}\n"
echo    # (optional) move to a new line
security cms -D -i "extracted/Payload/$APPLICATION/embedded.mobileprovision" > t_entitlements_full.plist
/usr/libexec/PlistBuddy -x -c 'Print:Entitlements' t_entitlements_full.plist > t_entitlements.plist
#/usr/libexec/PlistBuddy -c 'Print:application-identifier' t_entitlements.plist > t_entitlements_application-identifier   #save developer application-identifier to file
#/usr/libexec/PlistBuddy -c 'Print:com.apple.developer.team-identifier' t_entitlements.plist > t_entitlements_com.apple.developer.team-identifier  #save com.apple.developer.team-identifier application-identifier to file
var=$((0))
while IFS='' read -r line || [[ -n "$line" ]]; do
    #/usr/bin/codesign -d --entitlements :-  "$line" > t_entitlements_original.plist    #save original entitlements from the app
    #/usr/libexec/PlistBuddy -x -c 'Import application-identifier t_entitlements_application-identifier' t_entitlements_original.plist #overwrite application-identifier
    #/usr/libexec/PlistBuddy -x -c 'Import com.apple.developer.team-identifier t_entitlements_com.apple.developer.team-identifier' t_entitlements_original.plist #overwrite com.apple.developer.team-identifier
	if [[ "$BUNDLE" != 'null.null' ]] && [[ "$line" == *".appex"* ]]; then
	   echo "Changing .appex BundleID with : $BUNDLE.extra$var"
	   /usr/libexec/PlistBuddy -c "Set:CFBundleIdentifier $BUNDLE.extra$var" "$line/Info.plist"
	   var=$((var+1))
	fi
   /usr/bin/codesign --continue -f --verbose -s "$DEVELOPER" --entitlements "t_entitlements.plist"  "$line"
done < directories.txt
/usr/bin/codesign -d --entitlements appentitlements.txt "extracted/Payload/$APPLICATION"

printf "${Green}Creating the Signed IPA ${NC}with all signed and extracted folders\n"
cd extracted
find . -name ".DS_Store" -exec rm -rf {} \;
zip --symlinks -qry ../extracted.ipa *
cd ..
mv extracted.ipa "$TARGET"
rm -rf "extracted"
rm directories.txt
rm t_entitlements.plist
rm t_entitlements_full.plist
rm oldmaxentitlements1.txt
rm newmaxentitlements1.txt
#rm t_entitlements_original.plist
#rm t_entitlements_application-identifier
#rm t_entitlements_com.apple.developer.team-identifier