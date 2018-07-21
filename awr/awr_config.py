#receive configure info from awr's user

import sys
import os
import errno
import time
import shlex, subprocess
import shutil

# list of needed info options for check
#Please be free to extend mandatory options as similiar to case below
AWR_INFO_OPTIONS = ['workloads_dir', 'results_dir', 'temp_dir', 'samples_dir', 'tools_dir', 'config_log_file', 'awr_dir']
#############
FILENAME = 'settings'
#case of awr configure file
CASE = """
workloads_dir=<your workload_dir>
results_dir=<your result_dir>
temp_dir=<your temp files folder>
samples_dir=<your dir with recognition samples>
tools_dir=<dir with AWR additional android tools>
config_log_file=<logging configuration file>
"""
############

def _create_file(path_to_file):
    try:
       awr_file = open(path_to_file,"w+")
       awr_file.write(CASE)
       awr_file.close()
       print 'Creating a awr configure file\n', path_to_file
    except IOError:
        print 'Doesnt create a awr configure file'
        sys.exit(0)

def _ensure_dir(dir):
    if not os.path.exists(dir):
        try:
           os.makedirs(dir)
        except OSError:
           print 'Permission denied for making directory\n'
           sys.exit(0)

def _read_info(fn, awr_info):
    for line in open(fn, 'rt'):
        try:
            line = line.strip('\n\r\t ')
            p, v = line.split('=')
            awr_info[p.strip('\n\r\t ')] = v.strip('\n\r\t ')
        except:
            pass
            
def fix_info(awr_info):
    # finish path with '/'
    for k in ['base_dir', 'workloads_dir', 'results_dir', 'tasks_dir']:
        if k in awr_info and len(awr_info[k]) != 0 and awr_info[k][-1:] != '/':
            awr_info[k] += '/'

def _check_info(info):
    for option in AWR_INFO_OPTIONS:
        if option not in info:
            print 'mandatory option ', option, ' missed'
            return 'bad'
    return 'good'

def SubstituteOptions(info, awr_info):
    result = {}  #target
    for k, v in info.iteritems():
        result[k] = v
        if isinstance(v, str):
            for config_item in AWR_INFO_OPTIONS:
                if v.find('%' + config_item + '%') > -1:
                    result[k] = v.replace('%' + config_item + '%', awr_info[config_item])
    return result

def TestPath(awr_info, key):
    path = awr_info[key]
    if not os.path.exists(path):
        print 'Directory ' + path + ' does not exists!'
        sys.exit(0)

def simple_configure(awr_path):
    awr_info = {}
    
    if awr_path[-1] != '/' and awr_path[-1] != '\\':
        awr_path += '/'
    
    #['workloads_dir', 'results_dir', 'temp_dir', 'samples_dir', 'tools_dir', 'config_log_file']
    for item in AWR_INFO_OPTIONS:
        awr_info[item] = awr_path
    
    awr_info['workloads_dir'] += 'workloads'
    awr_info['results_dir'] += 'results/';
    awr_info['temp_dir'] += 'temp/'
    awr_info['samples_dir'] += 'samples/'
    awr_info['tools_dir'] += 'tools/'
    awr_info['config_log_file'] += 'scripts/log.config'
    
    for item in AWR_INFO_OPTIONS:
        TestPath(awr_info, item)
    
    return awr_info

"""
def read_config(awr_info):
    tmp = os.path.expanduser('~/.config/awr/settings')
    if os.path.isfile(tmp):
        _read_info(tmp, awr_info)
        check = _check_info(awr_info)
        if check == 'bad':
            print 'Incorrect awr configure file\n'
            print '--------------------------'
            print 'Case of a awr configure file:'
            print CASE
            print 'Come out from the platform'
            sys.exit(1)
        fix_info(awr_info)
    else :
        print 'Now you dont have a awr configure file'
        key = raw_input('Do you want the platform to create it [Y/N]:')
        if key == "Y" or key == "y":
            dir = os.path.expanduser('~/.config/awr/')
            _ensure_dir(dir)
            path_to_file = dir + FILENAME
            _create_file(path_to_file)
            print 'Please to complete needed paths in settings file in ~/.config/awr/ directory before you are getting started\n'
        else:
            print 'Please to create and complete awr configure file by yourself in ~/.config/awr/ directory\n'
        print 'Come out from the platform'
        sys.exit(1)
"""

