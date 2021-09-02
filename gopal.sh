# !/bin/bash
mydir="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )" && cat > ${mydir}/LICENSE.md << EOF
   _____        ___.   .__.__              _____                    ________.__                            
  /     \   ____\_ |__ |__|  |   ____     /  _  \ ______ ______    /   _____|__| ____   ____   ___________  
 /  \ /  \ /  _ \| __ \|  |  | _/ __ \   /  /_\  \\____ \\____ \   \_____  \|  |/ ___\ /    \_/ __ \_  __ \ 
/    Y    (  <_> | \_\ |  |  |_\  ___/  /    |    |  |_> |  |_> >  /        |  / /_/  |   |  \  ___/|  | \/ 
\____|__  /\____/|_____|__|____/\____>  \____|__  |   __/|   __/  /_______  |__\___  /|___|  /\___  |__|    
        \/         By Prathik Gopal             \/|__|   |__|             \/  /_____/      \/     \/  

The MIT License (MIT)
Copyright (c) 2021 Prathik Gopal
Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
EOF
signscript="${mydir}/signer.sh"
ascii="${mydir}/.ascii"
echo $bundletool
bundletool="${mydir}/bundletool.jar" #https://github.com/google/bundletool/releases
aapt2="/usr/local/bin/aapt2" # Should be installed with android studio, install the command line tools in the android sdk manager
if [ -e "$bundletool" ]; then
    echo #"$bundletool already exists"
    bundletool="${mydir}/bundletool.jar"
else
    cd $mydir && curl -L -o "bundletool.jar" https://github.com/google/bundletool/releases/download/1.6.1/bundletool-all-1.6.1.jar
    bundletool="$mydir/bundletool.jar"
    echo "$bundletool Downloaded"
fi
# Mobile App Signer CREATED BY PRATHIK GOPAL, Script below is for both inhouse and public signing, also including android sign and aligning.\
AndroidKeystore="/Users/Shared/keystore.jks" #update full keystore path when changed
CRT=($(security find-identity -v | awk '/Distribution/{ print $2}')) # FInds the certs in the system with valid codesign ability and places into array
# count=0
# for i in "${CRT[@]}"
# do
#  echo "CRT["$count"]=$i"
#  count=$((count + 1))
# done

InhouseOLD="${CRT[0]}" #Old inhouse "iPhone Distribution"
InhouseNEW="${CRT[1]}" #Public "Apple Distribution"
PublicCertificate="${CRT[2]}" #New inhouse "iPhone Distribution"
p8="${mydir}/.p8" #Update Android JKS keystore pass inside
while IFS= read -r field
do
  echo "$field"
done < "$p8"
AndroidKeystorepwd=${field} #&& echo $field #update keystore password when changed

#echo colors below
red=`tput setaf 1`
green=`tput setaf 2`
yellow=`tput setaf 3`
reset=`tput sgr0`
bold=`tput bold`
#printf colors
Black='\033[0;30m'
Red='\033[0;31m'
Green='\033[0;32m'
Yellow='\033[0;33m'
Blue='\033[0;34m'
Purple='\033[0;35m'
Cyan='\033[0;36m'
WPresse='\ Key033[0;37m'
NC='\033[0m'

echo ${red}"If you running this for the very first time, please set the keystore path and update expiry dates for each certificate manually"${reset} && cat $ascii
echo    # (optional) move to a new line
echo ${red}"Select Signing Method:"${reset}
echo   # (optional) move to a new line

ipasign(){
    echo ${green}"Found Below Valid Identities on the system"${reset}
    CERTX=($(security find-identity -v -p codesigning > /tmp/certx.txt))
    grep -o '".*"' /tmp/certx.txt | sed 's/"//g' > /tmp/certxname.txt
    #cat /tmp/certxname.txt
    # grep -o ')#"' certx.txt | sed 's/"//g' > certxhash.txt
    while IFS= read -r line; do
        array[i]=$line
        let "i++"
        echo "$line Expiry:" && security find-certificate -c "$line" -p | openssl x509 -text | grep "Not After"
    done < /tmp/certxname.txt
    InhouseOLDname=${array[0]} #Old inhouse "iPhone Distribution"
    InhouseNEWname="${array[1]}" #Public "Apple Distribution"
    PublicCertificatename=${array[2]}  #New inhouse "iPhone Distribution"
    # count=0
    # for line in "${array[@]}"
    # do
    #     echo "CRT["$count"]=$line"
    #     count=$((count + 1))
    # done
    certs=("PublicNEW 2022/01/13" "InhouseOLD 2022/03/18" "InhouseNEW 2023/09/25" "Quit") 
    COLUMNS=12
    select dev in "${certs[@]}"; do
        case $dev in
            "PublicNEW 2022/01/13") # Manually Update the dates on the cert names
                echo ${green}"Selected $dev certificate is : $PublicCertificatename $PublicCertificate "${reset}
                developer1=$PublicCertificate
                developername=$PublicCertificatename
                # optionally calling a function, add more code to run if needed
                break
                ;;
            "InhouseOLD 2022/03/18") # Manually Update the dates on the cert names
                echo ${green}"Selected $dev certificate is: $InhouseOLDname $InhouseOLD"${reset}
                developer1=$InhouseOLD
                developername=$InhouseOLDname
                # optionally calling a function, add more code to run if needed
                break
                ;;
            "InhouseNEW 2023/09/25") # Manually Update the dates on the cert names
                echo "Selected $dev certificate is : $InhouseNEWname $InhouseNEW"
                developer1=$InhouseNEW
                developername=$InhouseNEWname
                # optionally calling a function, add more code to run if needed
                break
                ;;
      	"Quit")
      	    echo "User requested exit"
  	    exit
      	    ;;    
        *) echo "invalid option $REPLY";;
        esac
    done
    if security find-identity -v -p codesigning | grep $developer1 > /dev/null; then
        echo ${green}"Found valid certificate in Keychain: $developer1"${reset}
    else
        echo ${red}"This certificate is not found $developer1"${reset}
    fi
    while :
        do echo ${red}"Enter IPA Source folder path (no Spaces):"${reset}
        read -r ipapath
        if [ -z "$ipapath" ]
        then
            echo "Path cannot be empty; try again."
        else
            if [ -d $ipapath ]
            then
                cd $ipapath && ipafile=$(find -d . -maxdepth 1 -type f -name "*.ipa")
                if ls ${ipapath}/*.ipa &>/dev/null
                then
                    fT=${ipafile:2}  # removing first two characters'./'
                    ipafile=$fT
                    echo ${green}"Using $ipafile found in the source folder"${reset} 
                    cd $ipapath && ipampp=$(find -d . -maxdepth 1 -type f -name "*.mobileprovision")
                    if ls ${ipapath}/*.mobileprovision &>/dev/null; then
                        fT=${ipampp:2}  # removing first two characters'./'
                        mobileprovision=$fT
                        echo ${green}"Using $mobileprovision also found in the same path"${reset}
                        bundleid=$(security cms -D -i "$mobileprovision" | plutil -extract Entitlements.application-identifier xml1 -o - - | grep string | sed 's/^<string>[^\.]*\.\(.*\)<\/string>$/\1/g')
                        echo ${green}"Using BundleID from $mobileprovision : $bundleid"${reset}
                        break
                    else
                        echo ${red}"NO Mobile provisioning profile found in folder, ensure no spaces in filename"${reset}
                        exit
                    fi
                else 
                    echo ${red}"NO IPA file found in folder, ensure no spaces in filename and retry"${reset}
                    exit
                fi
            fi
        echo ${red}"Directory does not exists, please try again."${reset}
        echo #for space
        fi
    done
    ipasourcefolder=$ipapath
    mobileprovision1="$ipasourcefolder$mobileprovision"
    bundlever=null.null #use null.null if you want to use the default app bundle version
    echo    # (optional) move to a new line
    echo ${red}"Enter Bundle Version (Ex. 7.2.2), Press Enter Key for no change"${reset}
    #read -p "your answer [default=$bundlever] " answer
    read -p "your answer [default=Unchanged]" answer
    : ${answer:=$bundlever}
    printf "${Green}You answered: ${Yellow}"$answer"${NC}\n"
    bundlever="$answer"
    bundlesver=null.null #use null.null if you want to use the default app bundles short version also visible to the end user
    echo ${red}"Enter Bundle Short Version (Ex. 7.2), Press Enter Key for no change"${reset}
    read -p "your answer [default=Unchanged] " answer
    : ${answer:=$bundlesver}
    printf "${Green}You answered: ${Yellow}"$answer"${NC}\n"
    bundlesver="$answer"
    bundledisplayname=null.null #use null.null if you want to use the default app bundles short version also visible to the end user
    echo ${red}"Enter App Display Name (Ex. Parking App), Press Enter Key for no change"${reset}
    read -p "your answer [default=Unchanged] " answer
    : ${answer:=$bundledisplayname}
    #echo ${green}"You answered:" && echo ${yellow}$answer${reset}
    printf "${Green}You answered: ${Yellow}"%s" $answer${NC}\n"
    bundledisplayname="$answer"
    # Signed files will be in the signed folder - Signed Folder will be automatically created
    echo # (optional) move to a new line
    echo ${yellow}"Processing Provided Inputs and signing, please wait"${reset}
    echo # (optional) move to a new line
    # DO NOT CHANGE ANYTHING BELOW OR ON THE sign.sh FILE  ################################################################################
    ipadestfolder="${ipasourcefolder}/Signed/" 
    cd $ipasourcefolder
    rm -rf Signed/ appentitlements.txt newmaxentitlements.txt oldmaxentitlements.txt bundleversion.txt
    mkdir Signed
    find -d . -maxdepth 1 -type f -name "*.ipa"> files.txt
    while IFS='' read -r line || [[ -n "$line" ]]; do
        filename=$(basename "$line" .ipa)
        #echo ${green}"Ipa: $filename"${reset}
        #_dev1_______
        output=$ipadestfolder$filename
        output+="_signed_dev1.ipa"
        "$signscript" "$line" "$developer1" "$mobileprovision1" "$output" "$bundleid" "$bundlever" "$bundlesver" "$bundlename" "$bundledisplayname" "$publicsigning"
    done < files.txt
    rm files.txt
    cfbundleversions=$(grep "$CFBundleVersion" bundleversion.txt)
    for filename in "${ipadestfolder}"*;do
    hash="$(openssl dgst -sha1 "$filename" | cut '-d ' -f2)"
    echo ${green}"Appending sha1 Hash: $hash"${reset}
    ext="${filename##*.}"
    if [ ! -z "$extension" ] && [ ! "$extension" == "$filename" ]; then
            withHash=$withHash.$extension
    fi
    $withHash
    #codesign -v ${bundleid}_${cfbundleversions}_${hash}_signed.${ext} #verifying codesign
    mv -v "$filename" "${ipadestfolder}${bundleid}_${cfbundleversions}_${hash}_signed.${ext}"
    printf "${Green}>>>>>>>>>>>>>>>>>>> ${Yellow}You may delete the extracted txt files, ${Green}they are for your reference <<<<<<<<<<<<<<<<<<<<${NC}\n"
    printf "${Red}   Signed Files Destination:${Green} $ipadestfolder ${NC}\n"
    printf "${Red}   Filename :                ${Green} ${bundleid}_${cfbundleversions}_${hash}_signed.${ext} ${NC}\n"
    printf "${Green}>>>>>>>> ${Yellow} $developername $developer1 ${Green} IPA Signing Successful <<<<<<<<${NC}\n"
    echo ${reset} #just ending
    rm bundleversion.txt
    done
    if [ ! -z "$PublicCertificate" ] && [ ! "$developer1" == "$PublicCertificate" ]; then
        read -p ${red}"Do you want to validate app with transporter? (press y/n)"${reset} -n 1 -r
        echo    # (optional) move to a new line
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit
        else
        read -p "Enter Developer Mail ID" answer
        : ${answer:=$devuserid}
        #echo ${green}"You answered:" && echo ${yellow}$answer${reset}
        printf "${Green}You answered: ${Yellow}"%s" $answer${NC}\n"
        devuserid="$answer"
        echo "Enter App-Specific Password, Instruction here https://support.apple.com/en-in/HT204397"; read -s answer
        : ${answer:=$devuserpw}
        #echo ${green}"You answered:" && echo ${yellow}$answer${reset}
        #printf "${Green}You answered: ${Yellow}"%s" $answer${NC}\n"
        devuserpw="$answer"
            cd $ipadestfolder && ipasfile=$(find -d . -maxdepth 1 -type f -name "*.ipa")
            if [ ${#ipasfile[@]} -gt 0 ]; then 
                fT=${ipasfile:2}  # removing first two characters'./'
                ipasfiles=$fT
                echo ${green}"You will find the validate debug output on the xml file"${reset}
                xcrun altool --validate-app -f $ipasfiles -t ios -u "$devuserid" -p "$devuserpw" --output-format "xml" > validateresult.xml
                cat validateresult.xml
                read -p ${red}"Do you want to upload app to appstore? (press y/n)"${reset} -n 1 -r
                echo    # (optional) move to a new line
                if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                exit
                else
                xcrun altool --upload-app -f $ipasfiles -t ios -u "$devuserid" -p "$devuserpw" --output-format "xml" > uploadresult.xml
                cat uploadresult.xml
                echo ${green}"You will find the upload debug output on the xml file"${reset} 
                exit
                fi
            else 
                echo ${red}"NO IPA file found in folder, ensure no spaces in filename"${reset}
                exit
            fi
        fi
    else
        exit
    fi
}

xcarchivesign(){
    echo ${green}"Found Below Valid Identities on the system"${reset}
    CERTX=($(security find-identity -v -p codesigning > /tmp/certx.txt))
    grep -o '".*"' /tmp/certx.txt | sed 's/"//g' > /tmp/certxname.txt
    # grep -o ')#"' certx.txt | sed 's/"//g' > certxhash.txt
    while IFS= read -r line; do
        array[i]=$line
        let "i++"
        echo "$line Expiry:" && security find-certificate -c "$line" -p | openssl x509 -text | grep "Not After"
    done < /tmp/certxname.txt
    InhouseOLDname=${array[0]} #Old inhouse "iPhone Distribution"
    PublicCertificatename="${array[1]}" #Public "Apple Distribution"
    InhouseNEWname=${array[2]}  #New inhouse "iPhone Distribution:"    
    certs=("PublicNEW 2022/01/13" "InhouseOLD 2022/03/18" "InhouseNEW 2023/09/25" "Quit") 
    COLUMNS=12
    select dev in "${certs[@]}"; do
        case $dev in
            "PublicNEW 2022/01/13") # Manually Update the dates on the cert names
                echo ${green}"Selected $dev certificate is : $PublicCertificatename $PublicCertificate "${reset}
                developer1=$PublicCertificate
                developername=$PublicCertificatename
                # optionally calling a function, add more code to run if needed
                break
                ;;
            "InhouseOLD 2022/03/18") # Manually Update the dates on the cert names
                echo ${green}"Selected $dev certificate is: $InhouseOLDname $InhouseOLD"${reset}
                developer1=$InhouseOLD
                developername=$InhouseOLDname
                # optionally calling a function, add more code to run if needed
                break
                ;;
            "InhouseNEW 2023/09/25") # Manually Update the dates on the cert names
                echo "Selected $dev certificate is : $InhouseNEWname $InhouseNEW"
                developer1=$InhouseNEW
                developername=$InhouseNEWname
                # optionally calling a function, add more code to run if needed
                break
                ;;
      	"Quit")
      	    echo "User requested exit"
  	    exit
      	    ;;    
        *) echo "invalid option $REPLY";;
        esac
    done
    if security find-identity -v -p codesigning | grep $developer1 > /dev/null; then
        echo ${green}"Found valid certificate in Keychain $developer1"${reset}
    else
        echo ${red}"This certificate is not found $developer1"${reset}
    fi
    while :
        do echo ${red}"Enter Xcarchive.Zip or xcarchive folder path (no Spaces):"${reset}
        read -r xcarchpath
        if [ -z "$xcarchpath" ]
        then
            echo "Path cannot be empty; try again."
        else
            if [ -d $xcarchpath ]
            then
                cd $xcarchpath && xcarchivezip=$(find -d . -maxdepth 1 -type f -name "*xcarchive.zip")
                if ls ${xcarchpath}/*.xcarchive.zip &>/dev/null; then
                    fT=${xcarchivezip:2}  # removing first two characters'./'
                    xcarchivezipfile=$fT
                    #echo $aabbundle
                    echo ${green}"Using $xcarchivezipfile found in the source folder"${reset} # look for xarchive.zip
                    unzip -qo "$xcarchivezipfile"
                    cd $xcarchpath && xarchfile=$(find . -type d -maxdepth 1 -name '*.xcarchive')
                    if ls ${xcarchpath}/*.xcarchive &>/dev/null; then
                        fT=${xarchfile:2}  # removing first two characters'./'
                        xcarchfiles=$fT
                        #echo $xcarchfiles
                        echo ${green}"Using $xcarchfiles found after extraction"${reset} # look for xarchive after unzipping
                        cd $xcarchpath && ipampp=$(find -d . -maxdepth 1 -type f -name "*.mobileprovision")
                        if ls ${xcarchpath}/*.mobileprovision &>/dev/null; then
                            fT=${ipampp:2}  # removing first two characters'./'
                            mobileprovision=$fT
                            echo ${green}"Using $mobileprovision also found in the same path"${reset} 
                            bundleid=$(security cms -D -i "$mobileprovision" | plutil -extract Entitlements.application-identifier xml1 -o - - | grep string | sed 's/^<string>[^\.]*\.\(.*\)<\/string>$/\1/g')
                            echo ${green}"Using BundleID from $mobileprovision : $bundleid"${reset}
                            break
                        else
                            echo ${red}"NO Mobile provisioning profile found in folder, ensure no spaces in filename"${reset}
                            exit
                        fi
                    else
                        echo ${red}"NO xcarchive directory after extraction, probably unzipping the xcarchive.zip failed"${reset}
                        exit
                    fi
                else
                    cd $xcarchpath && xarchfile=$(find . -type d -maxdepth 1 -name '*.xcarchive')
                    if ls ${xcarchpath}/*.xcarchive &>/dev/null; then
                        fT=${xarchfile:2}  # removing first two characters'./'
                        xcarchfiles=$fT
                        #echo $xcarchfiles
                        echo ${green}"Using $xcarchfiles found in folder"${reset} # look for xarchive
                        cd $xcarchpath && ipampp=$(find -d . -maxdepth 1 -type f -name "*.mobileprovision")
                        if ls ${xcarchpath}/*.mobileprovision &>/dev/null; then
                            fT=${ipampp:2}  # removing first two characters'./'
                            mobileprovision=$fT
                            echo ${green}"Using $mobileprovision also found in the same path"${reset} # output is appname.mobileprovision
                            bundleid=$(security cms -D -i "$mobileprovision" | plutil -extract Entitlements.application-identifier xml1 -o - - | grep string | sed 's/^<string>[^\.]*\.\(.*\)<\/string>$/\1/g')
                            echo ${green}"Using BundleID from $mobileprovision : $bundleid"${reset}
                            break
                        else
                            echo ${red}"NO Mobile provisioning profile found in folder, ensure no spaces in filename"${reset}
                            exit
                        fi
                    else 
                        echo ${red}"NO xcarchive.zip or xcarchive files found"${reset}
                        exit
                    fi
                fi
            fi
        echo ${red}"Directory does not exists, please try again."${reset}
        echo #for space
        fi
    done
    cd $xcarchpath && rm -rf Signed/ && mkdir Signed
    xcarchivefolder=$xcarchpath
    mobileprovision1="$xcarchpath$mobileprovision"
    ######processing#############
    xarchfullfilepath=$xcarchivefolder$xcarchfiles
    xcarchive="$xarchfullfilepath"
    output_ipa="$xcarchivefolder$bundleid"
    output_ipa+="_Unsigned.ipa"
    build_dir=$(mktemp -d '/tmp/package-ipa.XXXXXX') 2> /dev/null
    echo "build_dir: $build_dir"
    echo ${yellow}"Packaging ${xcarchive} into ${output_ipa}"${reset}

    if [ -f "${output_ipa}" ]; then
        rm "${output_ipa}"
    fi

    if [ -d "${build_dir}" ]; then
    	rm -rf "${build_dir}"
    fi

    echo "Preparing folder tree for IPA"
    mkdir -p "${build_dir}/Payload"

    # Copy .app into Payload dir
    pushd "${xcarchive}/Products/Applications" > /dev/null
    ls -l
    cp -Rp ./*.app "${build_dir}/Payload"
    popd > /dev/null

    # Check for and copy swift libraries
    if [ -d "${xcarchfiles}/SwiftSupport" ]; then
        echo "Adding Swift support dylibs"
        cp -Rp "${xcarchfiles}/SwiftSupport" "${build_dir}/"
    fi

    # Check for and copy WatchKit file
    if [ -d "${xcarchfiles}/WatchKitSupport" ]; then
        echo "Adding WatchKit support file"
        cp -Rp "${xcarchfiles}/WatchKitSupport" "${build_dir}/"
    fi

    echo ${green}"Zipping into an unsigned IPA"
    pushd "${build_dir}" > /dev/null
    zip --symlinks --verbose --recurse-paths "${output_ipa}" .
    popd > /dev/null

    echo ${green}"Created ${output_ipa}"${reset}
    rm -rf "${build_dir}" "__MACOSX" "zipindex" "$xcarchfiles"
    sleep 1
    ##signing###################################################################################################################
    ipasourcefolder=$xcarchivefolder
    cd $ipasourcefolder && ipafile=$(find -d . -maxdepth 1 -type f -name "*.ipa")
    if [ ${#ipafile[@]} -gt 0 ]; then 
        fT=${ipafile:2}  # removing first two characters'./'
        ipafiles=$fT
        echo ${green}"Using $ipafiles found in the same path"${reset} # output is app_Library.mobileprovision
    else 
        echo ${red}"NO IPA file found in folder, ensure no spaces in filename"${reset}
        exit
    fi
    mobileprovision1="$ipasourcefolder$mobileprovision"
    bundleid=$(security cms -D -i "$mobileprovision1" | plutil -extract Entitlements.application-identifier xml1 -o - - | grep string | sed 's/^<string>[^\.]*\.\(.*\)<\/string>$/\1/g')
    echo ${green}"Using BundleID from $mobileprovision : $bundleid"${reset}
    bundlever=null.null #use null.null if you want to use the default app bundle version
    echo    # (optional) move to a new line
    echo ${red}"Enter Bundle Version (Ex. 7.2.2), Press Enter Key for no change"${reset}
    #read -p "your answer [default=$bundlever] " answer
    read -p "your answer [default=Unchanged]" answer
    : ${answer:=$bundlever}
    printf "${Green}You answered: ${Yellow}"$answer"${NC}\n"
    bundlever="$answer"
    bundlesver=null.null #use null.null if you want to use the default app bundles short version also visible to the end user
    echo ${red}"Enter Bundle Short Version (Ex. 7.2), Press Enter Key for no change"${reset}
    read -p "your answer [default=Unchanged] " answer
    : ${answer:=$bundlesver}
    printf "${Green}You answered: ${Yellow}"$answer"${NC}\n"
    bundlesver="$answer"
    bundledisplayname=null.null #use null.null if you want to use the default app bundles short version also visible to the end user
    echo ${red}"Enter App Display Name (Ex. Parking App), Press Enter Key for no change"${reset}
    read -p "your answer [default=Unchanged] " answer
    : ${answer:=$bundledisplayname}
    printf "${Green}You answered: ${Yellow}"$answer"${NC}\n"
    bundledisplayname="$answer"
    # Signed files will be in the signed folder - Signed Folder will be automatically created
    echo # (optional) move to a new line
    echo ${yellow}"Processing Provided Inputs and signing, please wait"${reset}
    echo # (optional) move to a new line
    # DO NOT CHANGE ANYTHING BELOW OR ON THE sign.sh FILE  ################################################################################
    ipadestfolder="${ipasourcefolder}Signed/" 
    cd $ipasourcefolder
    rm -rf Signed/ appentitlements.txt newmaxentitlements.txt oldmaxentitlements.txt bundleversion.txt
    mkdir Signed
    find -d . -maxdepth 1 -type f -name "*.ipa"> files.txt
    while IFS='' read -r line || [[ -n "$line" ]]; do
        filename=$(basename "$line" .ipa)
        #echo ${green}"Ipa: $filename"${reset}
        #_dev1_______
        output=$ipadestfolder$filename
        output+="_signed_dev1.ipa"
        "$signscript" "$line" "$developer1" "$mobileprovision1" "$output" "$bundleid" "$bundlever" "$bundlesver" "$bundlename" "$bundledisplayname" "$publicsigning"
    done < files.txt
    rm files.txt
    cfbundleversions=$(grep "$CFBundleVersion" bundleversion.txt)
    for filename in "${ipadestfolder}"*;do
    hash="$(openssl dgst -sha1 "$filename" | cut '-d ' -f2)"
    echo ${green}"Appending sha1 Hash: $hash"${reset}
    ext="${filename##*.}"
    if [ ! -z "$extension" ] && [ ! "$extension" == "$filename" ]; then
            withHash=$withHash.$extension
    fi
    $withHash
    mv -v "$filename" "${ipadestfolder}${bundleid}_${cfbundleversions}_${hash}_signed.${ext}"
    printf "${Green}>>>>>>>>>>>>>>>>>>> ${Yellow}You may delete the extracted txt files, ${Green}they are for your reference <<<<<<<<<<<<<<<<<<<<${NC}\n"
    printf "${Red}   Signed Files Destination:${Green} $ipadestfolder ${NC}\n"
    printf "${Red}   Filename :                ${Green} ${bundleid}_${cfbundleversions}_${hash}_signed.${ext} ${NC}\n"
    printf "${Green}>>>>>>>>>>>>>>>>> ${Yellow} $developername $developer1 ${Green}Xcarchive Signing Successful <<<<<<<<<<<<<<<${NC}\n"
    echo ${reset} #just ending
    rm bundleversion.txt
    done
}

aabsign(){
    AndroidKeystore=$1
    if [ -e "$AndroidKeystore" ]; then
        echo ${green}"Selected option $dev, Using Default Keystore: $AndroidKeystore"${reset}
    else
        while :
            do echo ${red}"Default keystore not found, enter full path to JKS file without quotes. Ex.:/Users/Shared/AndroidAppsToResign/Keystorecerts/testkeystore.jks "${reset}
            read -ep $"Path:" jkspath
            if [ -z "$jkspath" ]
            then
                echo "Path cannot be empty; try again."
            else
                if [ ".$(echo "$jkspath"| cut -d. -f2)" == ".jks" ]
                then
                    if [ -e "$jkspath" ]; then
                        : ${jkspath:=$AndroidKeystore}
                        printf "${Green}Selected option $dev, and keystore: ${Yellow}"$jkspath"${NC}\n"
                        AndroidKeystore=$jkspath
                        break
                    else
                        echo "Provided JKS file not found, check for valid path"
                        exit
                    fi
                else
                    echo "Only JKS keystore files are accepted Ex.:/Users/Shared/keystore.jks"
                    exit
                fi
            fi
        done
    fi
    while :
        do echo ${red}"Enter AAB Source folder path (no Spaces):"${reset}
        read -r aabsourcefolder
        if [ -z "$aabsourcefolder" ]
        then
            echo "Path cannot be empty; try again."
        else
            if [ -d $aabsourcefolder ]
            then
                cd $aabsourcefolder && aabfile=$(find -d . -maxdepth 1 -type f -name "*.aab") #find aab bundle in the path
                if ls ${aabsourcefolder}/*.aab &>/dev/null
                then
                    fT=${aabfile:2}  # removing first two characters'./'
                    aabbundle=$fT
                    #echo $aabbundle
                    echo ${green}"Using $aabbundle found in the source folder"${reset}
                    break
                else 
                    echo ${red}"NO aab file found in folder, ensure no spaces in filename and retry"${reset}
                    exit
                fi
            fi
        echo ${red}"Directory does not exists, please try again."${reset}
        echo #for space
        fi
    done
    aabfullpath=$aabsourcefolder$aabbundle
    #echo $aabfullpath
    rm -rf androidmanifest.txt #androidtmp && mkdir androidtmp
    #unzip -qo "$aabfullpath" -d androidtmp
    java -jar $bundletool dump manifest --bundle $aabfullpath > $aabsourcefolder/androidmanifest.txt
    manifest=$(ls $aabsourcefolder/androidmanifest.txt)
    VERSIONCODE=`grep versionCode ${manifest} | sed 's/.*versionCode="//;s/".*//'`
    VERSIONNAME=`grep versionName ${manifest} | sed 's/.*versionName\s*=\s*\"\([^\"]*\)\".*/\1/g'`
    TARGETSDKVERSION=`grep targetSdkVersion ${manifest} | sed 's/.*targetSdkVersion="//;s/".*//'`
    AABPACKAGE=`grep package ${manifest} | sed 's/.*package="//;s/".*//'`
    rm -rf Signed/ androidmanifest.txt && mkdir Signed
    aabdestinationfolder="${aabsourcefolder}Signed/"
    # optionally call a function or run some code here
    echo ${green}"Making a backup: $aabbundle.original"
    aaboriginal=$(cp $aabbundle $aabbundle.original)
    jarsigner -verify -verbose -certs $aabbundle.original
    echo ${yellow}"Current Package=$AABPACKAGE" && echo "Current Versioncode=$VERSIONCODE" && echo "Current Versionname=$VERSIONNAME" && echo "Current TargetSDKversion=$TARGETSDKVERSION"${reset}
    read -p ${red}"Confirm the Jarsigner output above shows ${yellow}jar is unsigned ${red}? (press y/n)"${reset} -n 1 -r
    echo    # (optional) move to a new line
    if [[ ! $REPLY =~ ^[Yy]$ ]]
    then
        echo ${red}"jarsigner failed, ask Developer for unsigned build"${reset}
        rm -rf Signed/ "$aabbundle.original"
        exit 1
    else
        #rm $aabbundle.original
        read -p ${red}"Is this a new app ? (press y/n)"${reset} -n 1 -r
        echo    # (optional) move to a new line
        if [[ ! $REPLY =~ ^[Yy]$ ]]
        then
            echo ${green}"Continue to slect the alias"${reset}
            echo    # (optional) move to a new line
        else
            echo ${red}"Create a new Alias name (With no spaces, Eg. cimziaselect)"${reset}
            read newaliasname
            keytool -genkey -v -keystore $AndroidKeystore -storepass $AndroidKeystorepwd -alias $newaliasname -keyalg RSA -keysize 2048 -validity 10000 -dname "C=Countrycode, ST=Country, L=Country, O=IT, OU=Company Name, CN=$newaliasname"
            keytool -list -v -keystore $AndroidKeystore -storepass $AndroidKeystorepwd | grep "Alias name\|Creation date"
            echo ${red}"Enter Alias name to use from Above list (Exact alias name as shown): "${reset}
            read AndroidKeyalias
            aabalias=$AndroidKeyalias
            echo    # (optional) move to a new line
            echo ${green}"Processing with Alias: $aabalias. Signing and aligning file, please wait"${reset}
            jarsigner -verbose -sigalg SHA1withRSA -digestalg SHA1 -keystore $AndroidKeystore -storepass $AndroidKeystorepwd $aabbundle $aabalias
            zipalign -p -f -v 4 "${aabfullpath}" "${aabdestinationfolder}${aabalias}_Signed_aligned.aab" # > /dev/null #alignment in bytes, e.g. '4' provides 32-bit alignment
            echo " Zip Align Complete!"
        fi
        echo # (optional) move to a new line
        keytool -list -v -keystore $AndroidKeystore -storepass $AndroidKeystorepwd | grep "Alias name\|Creation date"
        echo ${red}"Enter Alias name to use from Above list (Exact alias name as shown): "${reset}
        read AndroidKeyalias
        aabalias=$AndroidKeyalias
        echo    # (optional) move to a new line
        echo ${green}"Processing with Alias: $aabalias. Signing and aligning file, please wait"${reset}
        jarsigner -verbose -sigalg SHA1withRSA -digestalg SHA1 -keystore $AndroidKeystore -storepass $AndroidKeystorepwd $aabbundle $aabalias
        zipalign -p -f -v 4 "${aabfullpath}" "${aabdestinationfolder}${aabalias}_Signed_aligned.aab" > /dev/null #alignment in bytes, e.g. '4' provides 32-bit alignment
        echo ${green}"AAB Zip Align Complete!"${reset}
    fi
    for filename in "${aabdestinationfolder}"*;do
    hash="$(openssl dgst -sha1 "$filename" | cut '-d ' -f2)"
    echo ${green}"Appending sha1 Hash: $hash"${reset}
    ext="${filename##*.}"
    if [ ! -z "$extension" ] && [ ! "$extension" == "$filename" ]; then
        withHash=$withHash.$extension
    fi
    $withHash
    done
    #echo $filename
    cd $aabdestinationfolder && mv "$filename" "${aabdestinationfolder}${AABPACKAGE}_${VERSIONNAME}_${hash}_signedaligned.${ext}"
    finalaab="${aabdestinationfolder}${AABPACKAGE}_${VERSIONNAME}_${hash}_signedaligned.${ext}"
    #echo $finalaab
    echo ${yellow}"Unpacking the universal apk, you may install on any android device for testing"${reset}
    java -jar $bundletool build-apks --bundle=$finalaab --output=${aabdestinationfolder}universal.apks --overwrite --mode=universal --ks=$AndroidKeystore --ks-pass=pass:$AndroidKeystorepwd --ks-key-alias=$aabalias
    cd $aabdestinationfolder && if [ $( ls -l *universal.apks 2> /dev/null | wc -l ) -ne 0 ]
    then
        mkdir apk && unzip -qo universal.apks -d apk
        # Copy .app into Payload dir
        zipalign -p -f -v 4 "$aabdestinationfolder/apk/universal.apk" "${aabdestinationfolder}${AABPACKAGE}_${VERSIONNAME}.apk" > /dev/null
        echo ${green}"APK Zip Align Complete!"${reset}
        echo ${yellow}"Checking 64bit architecture, please wait"${reset}
        cd $aabdestinationfolder/apk/ && unzip -qo "universal.apk" 2> /dev/null
        arch="${aabdestinationfolder}apk/lib/"
        #echo $arch
        if [ -d "${arch}arm64-v8a" ] && [ -d "${arch}x86_64" ]; then
            echo ${green}"App is 64bit compliant."${reset}
        else
            echo ${red}"App is NOT 64bit compliant. Please inform the developer to provide a new build with 64bit support"${reset}
        fi
        #mv "$aabdestinationfolder/apk/universal.apk" "${aabdestinationfolder}${AABPACKAGE}_${VERSIONNAME}.apk"
        cd .. && rm -rf universal.apks apk
    else 
        echo ${red}"No bundletool.jar or universal.apks files found"${reset}
        exit
    fi
    echo ${yellow}"Signed Package=$AABPACKAGE" && echo "Signed Versioncode=$VERSIONCODE" && echo "Signed Versionname=$VERSIONNAME" && echo "Signed TargetSDKversion=$TARGETSDKVERSION"${reset}
    echo  ${red}  # (optional) move to a new line
    printf "${Green}>>>>>>>>>>>>>>>> ${Yellow}You will see the ${Green}Signed & Aligned ${Yellow}AAB/APK in the Signed folder${Green}<<<<<<<<<<<<<<<<<${NC}\n"
    printf "${Red}   Signed Key Alias: ${Green} $aabalias ${NC}\n"
    printf "${Red}   Destination: ${Green} $aabdestinationfolder ${NC}\n"
    printf "${Red}   PlayStore AAB Filename : ${Green} ${AABPACKAGE}_${VERSIONNAME}_${hash}_signedaligned.${ext} ${NC}\n"
    printf "${Red}   Universal APK Filename : ${Green} ${AABPACKAGE}_${VERSIONNAME}.apk ${NC}\n"
    printf "${Green}>>>>>>>>>>>>>>>>> ${Yellow}$developer1 ${Green}Signing Successful <<<<<<<<<<<<<<<${NC}\n"
    cd $aabsourcefolder && mv "$aabfullpath.original" "$aabbundle"
    exit 1
}

certs=("IPA Signing" "AAB Sign&Align" "Xcarchive Build&Sign" "Quit")
COLUMNS=12
select dev in "${certs[@]}"; do
    case $dev in
        "IPA Signing") # Manually Update the dates on the cert names
            echo ${green}"Selected $dev Method"${reset}
            #developer1=$PublicCertificate
            #publicsigning=$PublicCertificate
            ipasign $developer1 # optionally calling a function, add more code to run if needed
            break
            ;;
        "Xcarchive Build&Sign")
            echo ${green}"Selected $dev Method"${reset}
            #developer1=$InhouseOLD
            #publicsigning=$PublicCertificate
            xcarchivesign $developer1 # optionally calling a function, add more code to run if needed
            break
            ;;
        "AAB Sign&Align")
            developer1=$AndroidKeystore
            aabsign $developer1
  	        break
      	    ;;
      	"Quit")
      	    echo "User requested exit"
  	    exit
      	    ;;    
        *) echo "invalid option $REPLY";;
    esac
done
