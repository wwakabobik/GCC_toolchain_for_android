import sys
import os
import datetime
import shlex, subprocess
from datetime import datetime
import marshal

def shell(cmd):
    #print 'Run: ', cmd
    args = shlex.split(cmd)
    p = subprocess.Popen(args)
    p.wait()

def shell_output(cmd):
    result = ''
    try:
        args = shlex.split(cmd)
        p = subprocess.Popen(args, stdout = subprocess.PIPE, stderr=subprocess.PIPE)
        line = p.stdout.readline()
        while line != '':
            line = line.strip('\r\n')
            result += line
            line = p.stdout.readline()
        
        line = p.stderr.readline()
        while line != '':
            line = line.strip('\r\n')
            result += line
            line = p.stderr.readline()
        p.wait()
        return result
    except:
        pass
    return result


def GetTraqSettings(globalParams, performanceResults):
    traq_global = {}
    traq_global["tools_dir"] = globalParams["tools_dir"]
    traq_global["TRAQTemplatePath"] = globalParams["TRAQTemplatePath"]
    traq_global["results_dir"] = globalParams["results_dir"]
    #traq_global["BeginTime"] = globalParams["BeginTime_forTRAQ"]
    #traq_global["EndTime"] = globalParams["EndTime_forTRAQ"]
    traq_global["RunDate"] = globalParams["RunDate_forTRAQ"]
    return (traq_global, performanceResults)

def GetBuildID():
    utc_str = int(shell_output('adb shell getprop ro.build.date.utc'))
    time_obj = datetime.fromtimestamp(utc_str)
    return time_obj.strftime('Android NDK %Y%m%d')

def WriteTraqReport(globalParams, performanceResults, BuildID = None):
    params = GetTraqSettings(globalParams, performanceResults)
    
    # if Build isn't provided we try calculate it
    if BuildID == None:
        params[0]['Build'] = GetBuildID()
    else:
        params[0]['Build'] = BuildID
    
    f = open('/tmp/traq_report_params', 'w')
    marshal.dump(params, f)
    f.close()
    
    shell('python ' + globalParams['tools_dir'] + 'py_traq_xml_writer.py')

    if os.path.exists('/tmp/traq_report_params'):
        os.remove('/tmp/traq_report_params')
    
def GetCurrentTimeForTRAQ():
    now = datetime.now()
    return now.strftime('%m/%d/%Y %I:%M:%S %p')

def GetCurrentDateForTRAQ():
    if os.getenv('cur_date'):
      curdate = os.getenv('cur_date')
      dt = datetime.strptime(curdate, "%Y%m%d")
    else:
      dt = datetime.now()
    return dt.strftime('%Y/%m/%d %I:%M:%S %p')


def ValidateTRAQDateTimeFormat(str):
    return True

def Test():
    globalParams = {}
    globalParams["tools_dir"] = "/users/smelniko/awr/tools/"
    globalParams["TRAQTemplatePath"] = "/users/smelniko/awr/tools/traq-template.xml"
    globalParams["results_dir"] = "/tmp/"
    globalParams["RunDate_forTRAQ"] = GetCurrentDateForTRAQ()
    performanceResult = []
    performanceResult.append({"BeginTime":GetCurrentTimeForTRAQ(), "EndTime":GetCurrentTimeForTRAQ(), "results":[("B1", 123), ("b2", 3323)], "Title": "Vellamo"})
    performanceResult.append({"BeginTime":GetCurrentTimeForTRAQ(), "EndTime":GetCurrentTimeForTRAQ(), "results":[("B1", 123), ("b2", 987)], "Title": "Linpack"})

    WriteTraqReport(globalParams, performanceResult)

if __name__ == "__main__":
    Test()
