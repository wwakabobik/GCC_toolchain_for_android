#!/bin/bash

if [ -z $baseDir ] ; then
    echo "Please setup work directory as baseDir variable"
    exit 1
fi

source $baseDir/scripts/path.sh

### Reset git  directory (remove all local changes)
curl http://android.intel.com/repo  > $baseDir/bin/repo_int
curl http://otc-android.intel.com/repo > $baseDir/bin/repo_otc
curl http://commondatastorage.googleapis.com/git-repo-downloads/repo > $baseDir/bin/repo_ext

chmod a+x $baseDir/bin/repo_ext
chmod a+x $baseDir/bin/repo_int
chmod a+x $baseDir/bin/repo_otc


### Remove all untracked files 
### cleanup_repo implemented at path.sh
cd $androidExternal
	repo_ext diff >> ${baseDir}/log/${cur_date}_AOSP_difference_before_cleanup.diff
    cleanup_repo_ext
cd $androidInternal
	repo_int diff >> ${baseDir}/log/${cur_date}_MCG_difference_before_cleanup.diff
    cleanup_repo_int

cd $androidInternal_OTC
	repo_otc diff >> ${baseDir}/log/${cur_date}_OTC_difference_before_cleanup.diff
    cleanup_repo_int_otc

### Search difference in repos before sync (unnecessary check), just to be shure that is not local changes
echo "search diff AOSP"
cd $androidExternal
    repo_ext diff >> ${baseDir}/log/${cur_date}_AOSP_difference_before_sync.diff

echo "search diff MCG"
cd $androidInternal
    repo_int diff >> ${baseDir}/log/${cur_date}_MCG_difference_before_sync.diff
    
echo "search diff MCG"
cd $androidInternal_OTC
    repo_otc diff >> ${baseDir}/log/${cur_date}_OTC_difference_before_sync.diff    

### Sync repos
cd $androidExternal
echo "start sync AOSP"
    repo_ext sync -j5
echo "end sync AOSP"

cd $androidInternal
echo "start sync MCG"
    repo_int sync -j5
echo "end sync MCG"

cd $androidInternal_OTC
echo "start sync MCG_OTC"
    repo_otc sync -j5
echo "end sync MCG_OTC"




