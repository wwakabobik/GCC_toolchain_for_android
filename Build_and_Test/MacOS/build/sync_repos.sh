#!/bin/bash

source %path_file_path%

### Reset git  directory (remove all local changes)
### Remove all untracked files 
### cleanup_repo implemented at path.sh
cd $androidExternal
    cleanup_repo_ext

### Search difference in repos before sync (unnecessary check), just to be shure that is not local changes
echo "search diff AOSP"
cd $androidExternal
    repo_ext diff >> difference_before_sync_$cur_date.diff


### Sync repos
cd $androidExternal
echo "start sync AOSP"
    repo_ext sync
echo "end sync AOSP"








