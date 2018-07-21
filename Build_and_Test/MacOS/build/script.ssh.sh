#!/bin/bash
user=""
mirror=""
echo "what is your unix username ?"
echo "(for example, mine is \"ialberdi\")"
read user
echo "we'll configure the files with username:$user"

function site_to_mirror {
    case $1 in
	"jf")
	    echo "umgsw-gcrmirror5.jf.intel.com"
	    ;;
	"tm")
	    echo "repo-mirror.tm.intel.com"
	    ;;
	"sh")
	    echo "shlabacsbb06.sh.intel.com"
	    ;;
	"iind")
	    echo "umpe-gcrmirror1.iind.intel.com"
	    ;;
	"nc")
	    echo "ncsgit002.nc.intel.com"
	    ;;
	"tl")
	    echo "gerrit-glb.tl.intel.com"
	    ;;
	"tlext")
	    echo "gerrit-celad.tl.intel.com"
	    ;;
	"tlext2")
	    echo "gerrit-sii.tl.intel.com"
	    ;;
	*)
	    echo "USAGE"
	    ;;
    esac
}
sites="[jf(john's farm),tm(tempere),sh(shangai),iind(bangalore),nc(nice),tl(toulouse),tlext(celad),tlext2(sii)]"
got_mirror=$((1))
while [[ $got_mirror -ne 0 ]]; do
    echo "in which site are you located ?"
    echo "please choose between $sites"
    read mirror_candidate
    mirror=`site_to_mirror $mirror_candidate`
    if [[ "$mirror" != "USAGE" ]];
    then
	got_mirror=$((0));
    else
	echo "bad mirror given";
    fi;
done

echo "starting update"
echo ""
echo "handling .ssh/known_hosts"
#function to update .ssh/known_hosts
function update_known_hosts {
   arg=$1
   sed -i s/^"$arg".*$//g ${HOME}/.ssh/known_hosts
   res=`ssh-keyscan -p 29418 $arg`
   if [[ -z $res ]];
   then
       echo "could not get the key of the gerrit ssh server in $arg";
   else
       echo $res >> ${HOME}/.ssh/known_hosts;
   fi
   #erase blank lines that could have been inserted
   #by the previous commands
   sed -i "/^$/{N; s/\n\(.*\)/\1/}" ${HOME}/.ssh/known_hosts
}
#add the entry related to the dns label $mirror in .ssh/known_hosts
update_known_hosts $mirror
#add the entry related to the ip_address behind $mirror in .ssh/known_hosts
mirror_ip=`host $mirror | grep "has address" | cut -d" " -f4`
if [[ ! -z $mirror_ip ]];
then
    update_known_hosts $mirror_ip;
else
    echo "skipping updating known_hosts with $mirror mirrors ip address because the dns label could not be resolved";
fi

#update .ssh/config
echo ""
echo "handling .ssh/config"
#The ssh server of gerrit is not OpenSSH (default tcp port 22),
#but an internal one (default tcp port 29418).
#Both have different banners, like for example:
#.openssh:  SSH-2.0-OpenSSH_5.9p1 Debian-5ubuntu1,
#.gerritssh: SSH-2.0-GerritCodeReview_2.2.2.1.
if [[ -z `grep $mirror ${HOME}/.ssh/config` ]];
then
    echo "#gerrit mirror setup"  >> ${HOME}/.ssh/config
    echo "host $mirror" >> ${HOME}/.ssh/config
    echo "     user $user" >> ${HOME}/.ssh/config
    echo "     port 29418" >> ${HOME}/.ssh/config;
else
    echo "skipping configuring client access to the ssh gerrit server of the mirror as it already exists";
fi

#now we handle the .gitconfig
echo ""
echo "handling .gitconfig"
android_intel="android.intel.com"

#first setup gitconfig so that repo uploads do not fail
if [[ -z `grep 'review \"$android_intel:8080\"' ${HOME}/.gitconfig` ]];
then
    git_var="review.$android_intel:8080.username"
    git config --global $git_var $user;
else
    echo "skipping adding the line review \"android.intel.com:8080\" in .gitconfig as it already exists";
fi

mirror_alias="jfumg-gcrmirror.jf.intel.com"

#if the mirror is already setup, this sed command
#will replace all that's necessary
sed -i "/^[ tab]*\[ *url/{N; s/.*\n.*insteadOf.*=.*\(ssh\|git\):\/\/$mirror_alias.*/[url \"ssh:\/\/$mirror\/\"]\n insteadOf=\1:\/\/$mirror_alias\// }" ${HOME}/.gitconfig
#else, we add the required lines
if [[ -z `grep insteadOf ${HOME}/.gitconfig | grep "git://$mirror_alias"` ]];
then
    echo "#setup the ssh access of the mirror when doing repo sync-s in git" >> ${HOME}/.gitconfig
    echo "[url \"ssh://$mirror/\"]" >> ${HOME}/.gitconfig
    echo " insteadOf=git://$mirror_alias/" >> ${HOME}/.gitconfig;
else
    echo "skipping configuring git access to $mirror_alias in .gitconfig as it already exists";
fi

if [[ -z `grep insteadOf ${HOME}/.gitconfig | grep "ssh://$mirror_alias"` ]];
then
    echo "#setup the ssh access of the mirror when doing repo sync-s in ssh" >> ${HOME}/.gitconfig
    echo "[url \"ssh://$mirror/\"]" >> ${HOME}/.gitconfig
    echo " insteadOf=ssh://$mirror_alias/" >> ${HOME}/.gitconfig;
else
    echo "skipping configuring ssh access to $mirror_alias in .gitconfig as it already exists";
fi


#the same when setting the mirror for android.intel.com (manifest+repo executable, download)
sed -i "/^[ tab]*\[ *url/{N; s/.*\n.*insteadOf.*=.*git:\/\/$android_intel.*/[url \"ssh:\/\/$mirror\/\"]\n insteadOf=git:\/\/$android_intel\// }" ${HOME}/.gitconfig
#again, we add the required lines if they're not there
if [[ -z `grep insteadOf ${HOME}/.gitconfig | grep "git://$android_intel"` ]];
then
    echo "#setup the ssh access of the mirror when downloading manifests or updating repo" >> ${HOME}/.gitconfig
    echo "[url \"ssh://$mirror/\"]" >> ${HOME}/.gitconfig
    echo " insteadOf=git://$android_intel/" >> ${HOME}/.gitconfig;
else
    echo "skipping configuring ssh access for $android_intel downloads in .gitconfig as it already exists";
fi

echo ""
echo "update done"
echo "if your repos do not work, check the correction of the modified files (.gitconfig,.ssh/[known_hosts,config])"
echo "in http://umgwiki.intel.com/wiki/?title=UMSE_One-Time_Setup#Gerrit_connection"