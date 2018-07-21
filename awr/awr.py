import sys
import os
import errno
import time
import datetime
import shlex, subprocess
import shutil
import logging
import logging.config
import traceback
from datetime import datetime

if os.getenv('PYTHONPATH'):
    sys.path.append(os.environ['PYTHONPATH'])
if os.getenv('PATH'):
    sys.path.append(os.environ['PATH'])

import awr_config
import awr_performance
import apk_utils
import awr_traq_output

from com.android.monkeyrunner import MonkeyRunner, MonkeyDevice

#__adb_path = 'adb'
#__tag

def GetVersionNumber(scriptsFolder):
    version = 0
    try:
        f = open(scriptsFolder + '/version.cfg')
        content = f.read()
        content = content.strip('\r\n\t')
        f.close()
        version = int(content)
    except:
        version = 0
    return version

def GetPhoneName():
    if os.getenv('ANDROID_SERIAL'):
	device_name = os.getenv('ANDROID_SERIAL')
	Phones={'Nexus4':['019270fc9908425c', '00289867da111923'], 'GalaxyNexus':['0146AFFC18020012', '0146A0CD1601301E'], 'medfield':['MedfieldB12636D7', 'MedfieldE906493B'], 'clovertrail':['Medfield2D7DC688', 'Medfield5344EBC9', 'RHBEC245500390', 'RHBEC245500319', 'RHBEC244100327'],'merrifield':['INV131700234', 'INV131701015'], 'harris':['msticltz103.ims.intel.com:5555', 'msticltz104.ims.intel.com:5555'], 'merrifield_pr2':['INV133600823', 'INV133601000']}
        for key in Phones:
            if device_name in Phones[key]:
                return key
    else:
        raise Exception('No environment variable ANDROID_SERIAL. This variable is required')
    raise Exception('Such model was not found in Phones list, please contact with AWR developer for adding such model to Phones list!')  
def adb(cmd, check=False):
    #print 'ADB -> ' + __adb_path + cmd
    global __adb_logger
    if __adb_logger == None:
        __adb_logger = logging.getLogger('subprocess.adb')
    ret = shell(__adb_path + cmd, __adb_logger)
    if check and ret != 0:
        print cmd
        print 'ERROR: device was not found by ADB. Please, check that device connected.'
        sys.exit(1)

def read_dictionary(fn):
    info = {}
    for line in open(fn, 'rt'):
        try:
            line = line.strip('\n\r\t ')
            #p, v = line.split('=')
            idx = line.find('=')
            p = line[:idx]
            v = line[idx+1:]
            info[p.strip('\n\r\t ')] = v.strip('\n\r\t ')
        except:
            pass
    return info

def shell(cmd, logger = None, writeLog = True):
    global __shell_logger
    my_logger = __shell_logger
    if logger != None:
        my_logger = logger
    if my_logger == None:
        __shell_logger = logging.getLogger('subprocess.shell')
        my_logger = __shell_logger
    
    result = ''
    try:
        my_logger.info('Shell execute: ' + str(cmd))
        args = shlex.split(cmd)
        p = subprocess.Popen(args, stdout = subprocess.PIPE, stderr=subprocess.PIPE)
        line = p.stdout.readline()
        while line != '':
            result += line
            if line.strip('\r\n') != '':
                if writeLog:
                    my_logger.info(line.strip('\r\n'))
            line = p.stdout.readline()
        line = p.stderr.readline()
        while line != '':
            result += line
            if line.strip('\r\n') != '':
                if writeLog:
                    my_logger.info('e: ' + line.strip('\r\n'))
            line = p.stderr.readline()
        return p.wait(), result
    except:
        pass
    return 1, result

"""
proc = subprocess.Popen(args, stdout = subprocess.PIPE)
line = proc.stdout.readline()
while line != '':
    result += line
    line = proc.stdout.readline()
return result
"""

def mkdir_p(path):
    try:
        os.makedirs(path)
    except OSError, e:
        pass

def dump_logcat_logs(w_info, fn, device):
    global __logcat
    if __logcat == None:
        __logcat = logging.getLogger('logcat')
    __logcat.info(str(device.shell('logcat -d')))
    device.shell('logcat -c')

"""
def log(w_info, fn, msg):
    f_log = open(w_info['r_dir'] + fn + '.log', 'at')
    if msg is None:
        msg = 'None'
    f_log.write(msg.encode('utf-8'))
    f_log.close()
"""

"""
def stdout_log(msg):
    print msg

def log_awr(w_info, msg):
    print msg
    log(w_info, 'awr', msg + '\n')
"""

def cleanup(w_info):
#   kill_zygote()
    device.press('KEYCODE_HOME', MonkeyDevice.DOWN_AND_UP)
    #go_back(w_info['device'])

def ExecuteShellCommands(w_info, key, title, logger):
    i = 1
    time.sleep(10)
    actionName = key + '.' + str(i)
    logger.info('Execute ' + title + ' actions')
    while actionName in w_info:
        logger.info(title + ' shell action #' + str(i) + ': ' + w_info[actionName])
        shell(w_info[actionName])
        i = i + 1
        actionName = key + '.' + str(i)
        time.sleep(4)

def install_workload(w_info):
    if 'apk' not in w_info:
        w_info['log'].info('No apk to install')
        return
    
    w_info['log'].info('Try to remove %s before install' % (w_info['package']))
    #device.removePackage(w_info['package'])
    adb('uninstall ' + w_info['package'])
    
    w_info['log'].info('Install apk file %s' % (w_info['apk']))
    adb('install ' + w_info['apk'])
    #if not device.installPackage(w_info['w_dir'] + w_info['apk']):
    #if not device.installPackage(w_info['apk']):
    #    w_info['status'] = False
    #    w_info['status_text'] = 'bad_install'
    #else:
    #    time.sleep(5)

def start_workload(w_info):
    if 'activity' not in w_info:
        w_info['log'].info('No activity to start')
        return
    
    runComponent = w_info['package'] + '/' + w_info['activity']
    w_info['log'].info('Run %s' % (runComponent,))
    device.startActivity(component=runComponent)
    time.sleep(5) # 10 seconds delay
    
    return

def CleanUpWorkload(w_info):
    #remove_workload(w_info)
    #install_workload(w_info)
    #adb('shell am force-stop ' + w_info['package'])
    #start_workload(w_info)
    return

def remove_workload(w_info):    
    if 'package' in w_info:
        adb('shell am force-stop ' + w_info['package'])
    if 'apk' in w_info and 'package' in w_info:  #if we have installed apk (apk key exists) - we remove it
        time.sleep(2)
        w_info['log'].info('Remove package %s' % (w_info['package']))
        #device.removePackage(w_info['package'])
        adb('uninstall ' + w_info['package'])

def prepare_device():
    adb('root', True)
    time.sleep(5) # waiting for ADB restart
    adb('shell rm -r /data/awr')
    adb('shell mkdir /data/awr')

def go_back(device):
    for i in xrange(0, 10):
        device.press('KEYCODE_BACK', MonkeyDevice.DOWN_AND_UP)
        time.sleep(0.5)
    
def kill_zygote():
    args = shlex.split(__adb_path + 'shell ps')
    p = subprocess.Popen(args, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    (stdout, stderr) = p.communicate()
    for line in stdout.split('\n'):
        line = line.strip('\n\r\t ')
        if line.endswith('zygote'):
            tmp = line.split()
            pid = tmp[1]
            adb('shell kill -9 ' + pid)
    time.sleep(15)

def GetLoggerForWorkload(workload, log_path):
    logger = logging.getLogger('workload')
    handler = logging.FileHandler(log_path)
    logger.addHandler(handler)
    
    return logger, handler

def AddHandlerToGlobalLoggers(handler):
    global __global_logger
    global __subprocess_logger
    
    __global_logger.addHandler(handler)
    __subprocess_logger.addHandler(handler)

def RemoveHandlerFromGlobalLoggers(handler):
    global __global_logger
    global __subprocess_logger
    
    __global_logger.removeHandler(handler)
    __subprocess_logger.removeHandler(handler)

def IsInternetAvailable():
    #retCode, retText = shell('adb shell wget -O - http://87.250.250.3/', None, False)
    #return   retText.find('100%') != -1
    return True

def process_workload(awr_info, device, workload):
    global __global_logger
    
    result = []
    w_info = {}
    
    w_info['workload'   ]   = workload
    w_info['device'     ]   = device #!!
    w_info['w_dir'      ]   = awr_info['workloads_dir'] + workload + '/'
    w_info['r_dir'      ]   = awr_info['results_dir'] + workload + '/'
    w_info['temp_dir'   ]   = awr_info['temp_dir']
    w_info['cleanup'    ]   = lambda : CleanUpWorkload(w_info)
    w_info['adb']    = lambda s : shell('adb ' + s)

    if os.path.isdir( w_info['r_dir']):
        shutil.rmtree(w_info['r_dir'])
    mkdir_p(w_info['r_dir'])
    
    w_info['log_path'   ]   = w_info['r_dir'] + workload + '.log'
    w_info['global_log' ]   = __global_logger
    w_info['log'], handler  = GetLoggerForWorkload(workload, w_info['log_path'])
    #__global_logger.addHandler(handler)
    AddHandlerToGlobalLoggers(handler)
    
    w_info['clipboarder_tool'] = awr_info['clipboarder_tool']
      
    
    info = read_dictionary(w_info['w_dir'] + 'awr_info')
    info = awr_config.SubstituteOptions(info, awr_info)
    #print info
    for k, v in awr_info.iteritems():
        w_info[k] = v
    for k,v in info.iteritems():
        w_info[k] = v
    
    if 'skip' in w_info:
        w_info['log'].warning('Skipped!')
    else:
        #w_info = awr_config.SubstituteOptions(awr_info, w_info)
        #print w_info
        
        device.shell('logcat -c') # clear logs
        
        install_workload(w_info)
        #time.sleep(20)
        
        if 'before_execution_shell_command.1' in w_info:
            ExecuteShellCommands(w_info, 'before_execution_shell_command', 'pre-execution', w_info['log'])
        
        device.press('KEYCODE_HOME', MonkeyDevice.DOWN_AND_UP)
        cleanup(w_info)
        device.wake()
        time.sleep(2)
        
        connectionIsOk = True
        if ('require_internet' in w_info) and w_info['require_internet'] == 'true':
            
            shell('python ' + awr_info['tools_dir'] + 'enable_internet.py -rndis-only')
            if not IsInternetAvailable():
                __global_logger.warn('Enable internet: Fail')
                __global_logger.error('No internet connection!')
                connectionIsOk = False
            else:
                __global_logger.warn('Enable internet')
        else:
            __global_logger.info('Disable internet!')
            shell('python ' + awr_info['tools_dir'] + 'enable_internet.py -no-internet')

        if connectionIsOk:
            time.sleep(7)
            if 'require_orientation' in w_info:
                if w_info['require_orientation'] == 'portrait':
                    awr_info['screen_orientation_tools'].SetPortrait()
                    w_info['log'].info('Change orientation to portrait')
                elif w_info['require_orientation'] == 'landscape':
                    awr_info['screen_orientation_tools'].SetLandscape()
                    w_info['log'].info('Change orientation to landscape')
                else:
                    w_info['log'].warning('Unknown orientation!')
                    
                
                start_workload(w_info)
                time.sleep(8)
            
            results = awr_performance.PerformanceTest(w_info)
                        
            for item in result:
                __global_logger.info('Mediana [' + item[0] + '] -> ' + item[1])
                    
            
        else:
            results = awr_performance.FailWholeTest(w_info, 'No internet connection')
        
        remove_workload(w_info)
        
        for i in range(len(results)):
            result.append((w_info['title' + str(i+1)], str(results[i])))
        
        if 'after_execution_shell_command.1' in w_info:
            ExecuteShellCommands(w_info, 'after_execution_shell_command', 'after-execution', w_info['log'])
        
    __global_logger.info('=========================================')
    RemoveHandlerFromGlobalLoggers(handler)
    #shell('python ' + awr_info['tools_dir'] + 'enable_internet.py -no-internet')
    #handler.close()
    #print 'result = '
    #print result
    return result

def get_workloads(awr_info):
    global __global_logger
    
    r_dir = awr_info['workloads_dir']
    result = []
    #print r_dir + 'tasks.txt'
    if os.path.isfile(r_dir + 'tasks.txt'):
        f = open(r_dir + 'tasks.txt', 'r')
        for line in f:
            if line.find('#') == -1:
                result.append((line.replace('\n', '')).replace('\r', ''))
        f.close()
    else:
        for tmp in os.listdir(r_dir):
            if os.path.exists(r_dir + tmp.strip() + '/awr_info'):
                result.append(tmp.strip())
        result.sort()
    return result

def GetNowStr():
    now = datetime.now()
    return now.strftime('%Y%m%d_%H%M%S')

def Configure():
    awr_info = {}
    if len(sys.argv) < 2:
        raise Exception('No actual parameter -awr-dir=PathToAWRDir')
        #sys.exit(1)
    else:
        for param in sys.argv[1:]:
            if param[:len('-awr-dir=')] == '-awr-dir=':
                awr_info = awr_config.simple_configure(param[len('-awr-dir='):])
            if param[:len('-comment=')] == '-comment=':
                awr_info['comment'] = param[len('-comment='):]
            if param[:len('-traq-template=')] == '-traq-template=':
                awr_info['TRAQTemplatePath'] = param[len('-traq-template='):]
            if param == '-submit':
                awr_info['TRAQSubmit'] = 'yes'
        return awr_info

if __name__ == '__main__':
    global __tag
    global __device_id
    global __global_logger
    global __adb_logger
    global __shell_logger
    global __subprocess_logger
    
    try:
        __adb_logger = None
        __shell_logger = None
        __global_logger = None
        __subprocess_logger = None
	__device_id = None
        __tag = GetNowStr()
	__device_model = GetPhoneName()
        
        awr_info = Configure()
	awr_info['results_dir'] = awr_info['results_dir'] + __device_model + '/' +__tag + '/'
        awr_info['RunDate_forTRAQ'] = awr_traq_output.GetCurrentDateForTRAQ()
        mkdir_p(awr_info['results_dir'])
        
        logging.config.fileConfig(awr_info['config_log_file'])
        
        __global_logger = logging.getLogger('global')
        __subprocess_logger = logging.getLogger('subprocess')
        file_out_handler = logging.FileHandler(awr_info['results_dir'] + 'awr.log')
        logging.getLogger().addHandler(file_out_handler)
        
        __global_logger.info('AWR [' + __tag + ']')
        
        __adb_path = 'adb '
        
        
        __global_logger.info('Internal init...')
        version = GetVersionNumber(awr_info['awr_dir'] + '/scripts/')
        __global_logger.info("Version: " + str(version))
        
        if 'comment' in awr_info:
            __global_logger.info('Comment: ' + awr_info['comment'])
        awr_performance.Init(awr_info)
        
        __global_logger.info('Disable internet on device...')
        shell('python ' + awr_info['tools_dir'] + 'enable_internet.py -no-internet')
        
        __global_logger.info('Android model: ' + __device_model)
	device = MonkeyRunner.waitForConnection(99, os.getenv('ANDROID_SERIAL'))
	awr_info['workloads_dir'] = awr_info['workloads_dir'] + '_' + __device_model + '/'
        
        workloads = get_workloads(awr_info)
        __global_logger.info('Running ' + str(len(workloads)) + ' workloads:')
        for w in workloads:
            __global_logger.info('>' + w)
        
        screen_orientation_tools = apk_utils.ScreenOrientationTool(adb, awr_info['tools_dir'] + 'OrientationChanger.apk', 'com.intel.orientation')
        clipboarder_tool = apk_utils.ClipboardContentTool(adb, awr_info['tools_dir'] + 'Clipboarder.apk', 'com.intel.clipboard', device, awr_info['temp_dir'] + 'clipboard_temp_file.txt')
        
        results = []
        traq_report = []
        try:
            __global_logger.info('Setting up additional tools')
            
            screen_orientation_tools.Install()
            clipboarder_tool.Install()
            awr_info['screen_orientation_tools'] = screen_orientation_tools 
            awr_info['clipboarder_tool'] = clipboarder_tool
            
            __global_logger.info('Start benchmarks')
            __global_logger.info('=========================================')
            
            for workload in workloads:
                traq_report_item = {}
                traq_report_item["Title"] = workload
                traq_report_item["BeginTime"] = awr_traq_output.GetCurrentDateForTRAQ()
                r = process_workload(awr_info, device, workload)
                #if len(r) > 0:
                for item in r:
                    results.append(item)
                traq_report_item["EndTime"] = awr_traq_output.GetCurrentTimeForTRAQ()
                traq_report_item["results"] = r
                                
                traq_report.append(traq_report_item)
        finally:
            

            screen_orientation_tools.UnInstall()
            clipboarder_tool.UnInstall()
            device.press('KEYCODE_HOME', MonkeyDevice.DOWN_AND_UP)
            #cleanup(w_info)
        
        __global_logger.info('Testing Done!')
        __global_logger.info('Success: ' + str(awr_performance.success_count))
        __global_logger.info('FAIL: ' + str(awr_performance.fail_count))
        __global_logger.info('Passrate: ' + str(awr_performance.success_count*100 / (awr_performance.success_count + awr_performance.fail_count)) + '%')
        
        __global_logger.info('=========================================')
        __global_logger.info('Report:')
        f = open(awr_info['results_dir'] + 'results.log', 'w')
        f.write('ANDROID_SERIAL=' + os.getenv('ANDROID_SERIAL'))
        for res in results:
            result_str = ''
            if float(res[1]) > 0 :
                result_str = str(res[1])
            else:
                result_str = 'FAIL'
            __global_logger.info('\t' + res[0] + '\t->\t' + result_str)
            f.write(res[0] + ': ' + result_str + '\r\n')
        f.close()
        __global_logger.info('Report with results available here: ' + awr_info['results_dir'] + 'results.log')
        __global_logger.info('Detailed log available here: ' + awr_info['results_dir'] + 'awr.log')
       
        
        if 'TRAQTemplatePath' in awr_info:
            awr_traq_output.WriteTraqReport(awr_info, traq_report)
            __global_logger.info('TRAQ report available here: ' + awr_info['results_dir'] + 'traq_report.xml')
            
        if 'TRAQSubmit' in awr_info:
            os.chdir(awr_info['results_dir'])
            cur_user = os.getenv('USER')
            cmd = "/usr/bin/perl /users/common/submit.pl scstraqs2new.sc.intel.com GCC GCC %s traq_report.xml" %cur_user
            args = shlex.split(cmd)
            p = subprocess.Popen(args, stdout = subprocess.PIPE, stderr=subprocess.PIPE)
            (stdout, stderr) = p.communicate()
            __global_logger.info('out:%s' %stdout)
            __global_logger.info('err:%s' %stderr)

    except Exception:
        if __global_logger != None:
            __global_logger.critical(traceback.format_exc())
        else:
            print traceback.format_exc()



