import sys
import os
import os.path
import errno
import time
import shlex, subprocess
import shutil
import re
import traceback
import logging

import awr_common
import ocr


from com.android.monkeyrunner import MonkeyRunner, MonkeyDevice

default_color = 1
default_bw_edge_value=150

success_count = 0
fail_count = 0
start_image_index = 1

def GetBWValue(pixelTuple, __color, __edge):
    if pixelTuple[__color] > __edge:
        return 0
    else:
        return 1


def ConvertMonkeyImageToMyImage(image, rect, __color, __edge):
    result_img = []
    white_count = 0
    black_count = 0
    for y in range(rect[3]):
        for x in range(rect[2]):
            pixel_t = image.getRawPixel(x, y)
            bw = GetBWValue(pixel_t, __color, __edge)
            if bw == 0:
                white_count = white_count + 1
            else:
                black_count = black_count + 1
            result_img.append(bw)
    if white_count > black_count:
        for i in range(white_count + black_count):
            result_img[i] = 1 - result_img[i]
    return (rect[2], rect[3], result_img)


def TakeRectScreenshot(w_info, actionName):
    global default_color
    global default_bw_edge_value
    global start_image_index
    
    color = default_color
    bw_edge_value = default_bw_edge_value
    
    if actionName + '.bw_edge' in w_info:
        bw_edge_value = int(w_info[actionName + '.bw_edge'])
    if actionName + '.color' in w_info:
        color = int(w_info[actionName + '.color'])
    
    rotate = 0
    if actionName + '.rotate' in w_info:
        rotate = int(w_info[actionName + '.rotate'])
    rectLeft = int(w_info[actionName + '.screen_left'])
    rectTop = int(w_info[actionName + '.screen_top'])
    rectWidth = int(w_info[actionName + '.screen_width'])
    rectHeight = int(w_info[actionName + '.screen_height'])
    
    rect = (rectLeft, rectTop, rectWidth, rectHeight)
    
    image = w_info['device'].takeSnapshot()
    image.writeToFile(w_info['r_dir'] + 'full_screenshot' + w_info['action'] + '_' + str(start_image_index) + '.png', 'png')
    if rotate == 1:
        os.system("convert -rotate 90 " +(w_info['r_dir'] + 'full_screenshot' + w_info['action'] + '_' + str(start_image_index) + '.png ') + (w_info['r_dir'] + 'full_screenshot' + w_info['action'] + '_' + str(start_image_index) + '.png '))
        image = MonkeyRunner.loadImageFromFile(w_info['r_dir'] + 'full_screenshot' + w_info['action'] + '_' + str(start_image_index) + '.png', 'png');
    result_rect = image.getSubImage(rect)
    my_image = ConvertMonkeyImageToMyImage(result_rect, rect, color, bw_edge_value)
    ocr.WriteImage(my_image, w_info['r_dir'] + 'results_screenshot' + w_info['action'] + '_' + str(start_image_index) + '.img')
    start_image_index = start_image_index + 1
    return my_image

def RecognizeScreenshot(w_info, actionName):
    image = TakeRectScreenshot(w_info, actionName)
    return ocr.RecognizeImage(image);
def Drag(device, fromLeft, fromTop, toLeft, toTop, duration, steps):
    device.drag((fromLeft, fromTop), (toLeft, toTop), duration, steps)
def Click(device, left, top, duration):
    if duration == 0:
        device.touch(left, top, MonkeyDevice.DOWN_AND_UP)
    else:
        device.touch(left, top, MonkeyDevice.DOWN)
        time.sleep(duration)
        device.touch(left, top, MonkeyDevice.UP)
    
def PushButton(device, button):
    device.press(button, MonkeyDevice.DOWN_AND_UP)

def ProcessLogcat(w_info,actionName):
    image = w_info['device'].takeSnapshot()
    image.writeToFile(w_info['r_dir'] + 'full_screenshot' + w_info['action'] + '.png', 'png')
    
    result_value = []
    q, logcat_data = w_info['adb']('logcat -d')
    step = 1
    while (actionName + '.result_regexp.' + str(step)) in w_info:
        resultRegexp = w_info[actionName + '.result_regexp.' + str(step)]
        result = ProcessRegexp(logcat_data, resultRegexp, w_info['log'])
        result_value.append(result)    
        step = step + 1
    return result_value

def ReadFile(w_info, fileName):
    if not os.path.exists(fileName):
        raise Exception('No results file!')
    f = open(fileName)
    res = ''
    for line in f:
        res = res + line
    f.close()
    os.remove(fileName)
    
    #linearizeKeyName = actionName + '.linearizeFile'
    #if linearizeKeyName in w_info and w_info[linearizeKeyName] == 'true':
    res = res.replace('\t', ' ')
    res = res.replace('\r', ' ')
    res = res.replace('\n', ' ')
    
    return res

def ProcessFileFromDevice(w_info, actionName):
    image = w_info['device'].takeSnapshot()
    image.writeToFile(w_info['r_dir'] + 'full_screenshot' + w_info['action'] + '.png', 'png')
    
    filePathOnDevice = w_info[actionName + '.targetFile']
    tempFilePath = w_info['temp_dir'] + 'deviceFile'
    w_info['adb']('pull ' + filePathOnDevice + ' ' + tempFilePath)
    w_info['adb']('shell rm ' + filePathOnDevice)

    fileContent = ReadFile(w_info, tempFilePath)
    w_info['log'].info('file content: ' + fileContent)
    result_value = []
    step = 1
    while (actionName + '.result_regexp.' + str(step)) in w_info:
        resultRegexp = w_info[actionName + '.result_regexp.' + str(step)]
        result = ProcessRegexp(fileContent, resultRegexp, w_info['log'])
        result_value.append(result)
        step = step + 1
    if len(result_value) < 1:
        raise Exception('No results!')
    return result_value

def GetIPAddress():
    args = shlex.split('uname -n')
    p = subprocess.Popen(args, stdout = subprocess.PIPE)
    hostname = p.stdout.readline()
    p.wait()
    args = shlex.split('host ' + hostname)
    p = subprocess.Popen(args, stdout = subprocess.PIPE)
    res = p.stdout.readline()
    return re.findall('([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3})', res)[0]
    
def RegExperiseExpression(str):
    str = str.replace('.', '\.')
    return str

def GetLinkData(w_info,link,lines,remTag):
    linkFilePath_tmp = w_info['temp_dir'] + 'LinkFile_tmp'
    linkFilePath = w_info['temp_dir'] + 'LinkFile'
    if remTag:
        os.system('curl ' + link + ' > ' + linkFilePath_tmp)
        if os.path.exists(linkFilePath_tmp):
	    os.system('sed -n "/^$/!{s/<[^>]*>/ /g;p;}" '+linkFilePath_tmp+' > '+ linkFilePath + '') #replace all tags with spaces
            os.remove(linkFilePath_tmp)
    else:
        os.system('curl ' + link + ' > ' + linkFilePath)
    try:
        str = ''
        f = open(linkFilePath, 'r')
        for line in range(lines):
            str = str + f.readline()
        f.close()
    finally:
        if os.path.exists(linkFilePath):
            os.remove(linkFilePath)
    return str
    
def ParseLink(w_info, actionName):
    image = w_info['device'].takeSnapshot()
    image.writeToFile(w_info['r_dir'] + 'full_screenshot' + w_info['action'] + '.png', 'png')
    linkFilePath = w_info['temp_dir'] + 'LinkFile'
    if actionName + '.remTags' in w_info:
        remTags = bool(w_info[actionName + '.remTags'])
    if actionName + '.link' in w_info:
        link = w_info[actionName + '.link']
    if actionName + '.lines' in w_info:
        lines = int(w_info[actionName + '.lines'])
    LinkContent = GetLinkData(w_info,link,lines,remTags)
    result_value = []
    step = 1
    while (actionName + '.result_regexp.' + str(step)) in w_info:
        resultRegexp = w_info[actionName + '.result_regexp.' + str(step)]
        result = ProcessRegexp(LinkContent, resultRegexp, w_info['log'])
        result_value.append(result)    
        step = step + 1
    if len(result_value) < 1:
        raise Exception('No results!')
    return result_value
def ExpandRegexp(str):
    if str.find('%IP%') > -1:
        ip = GetIPAddress()
        ip_regexp = RegExperiseExpression(ip)
        str = str.replace('%IP%', ip_regexp)
    return str

def ProcessRegexp(s, regexp, log):
    regexp = ExpandRegexp(regexp)
    s = s.replace('\r', '')
    s = s.replace('\n', '')
    s = s.replace('\t', ' ')
    log.debug('s = ' + s)
    log.debug('regexp = ' + regexp)
    #print s
    #print 'REGEXP: ' + regexp
    result = re.findall(regexp, s)
    if len(result) == 0:
        raise Exception('No results!')
    else:
        return float(result[0])

def ParseSelected(w_info, actionName):
    image = w_info['device'].takeSnapshot()
    image.writeToFile(w_info['r_dir'] + 'full_screenshot' + w_info['action'] + '.png', 'png')
    clipboardContent = w_info['clipboarder_tool'].GetClipboardText()
    result_value = []
    step = 1
    while (actionName + '.result_regexp.' + str(step)) in w_info:
        resultRegexp = w_info[actionName + '.result_regexp.' + str(step)]
        result = ProcessRegexp(clipboardContent, resultRegexp, w_info['log'])
        result_value.append(result)    
        step = step + 1
    if len(result_value) < 1:
        raise Exception('No results!')
    return result_value

#returns set of floats    
def BenchmarkStart(w_info):
    bechmarkValue = []
    device = w_info['device']
    i = 1
    if 'start_step' in w_info:
        i = int(w_info['start_step'])
    
    device.shell('setprop net.dns1 10.248.2.1')
    device.shell('logcat -c')
    w_info['log'].info('set dns server')
    
    actionName = 'action' + str(i)
    
    while actionName + '.type' in w_info:
        w_info['log'].info('Action #' + str(i) + ' ->  Type: ' + w_info[actionName + '.type'])
        
        if w_info[actionName + '.type'] == 'drag':
            fromLeft = int(w_info[actionName + '.fromLeft'])
            fromTop = int(w_info[actionName + '.fromTop'])
            toLeft = int(w_info[actionName + '.toLeft'])
            toTop = int(w_info[actionName + '.toTop'])
            duration = 1
            if actionName + '.duration' in w_info:
                duration = int(w_info[actionName + '.duration'])
            steps = 10
            if actionName + '.steps' in w_info:
                duration = int(w_info[actionName + '.steps'])
            w_info['log'].info('Action #' + str(i) + ' ->  Drag from (' + str(fromLeft) + ', ' + str(fromTop) + ')' + 'to' + ' (' + str(toLeft) + ', ' + str(toTop) + ')')
            Drag(device, fromLeft, fromTop, toLeft, toTop, duration, steps)
        elif w_info[actionName + '.type'] == 'click':
            left = int(w_info[actionName + '.left'])
            top = int(w_info[actionName + '.top'])
            
            duration = 0
            if actionName + '.duration' in w_info:
                duration = int(w_info[actionName + '.duration'])
            
            w_info['log'].info('Action #' + str(i) + ' ->  Click at (' + str(left) + ', ' + str(top) + ')')
            
            Click(device, left, top, duration)
        
        elif w_info[actionName + '.type'] == 'wait':
            wait_time = int(w_info[actionName + '.time'])
            w_info['log'].info('Action #' + str(i) + ' ->  Wait for ' + str(wait_time) + ' seconds')
            
            time.sleep(wait_time)
            
        elif w_info[actionName + '.type'] == 'push_button':
            button = w_info[actionName + '.button']
            w_info['log'].info('Action #' + str(i) + ' ->  Push button ' + button)
            
            PushButton(device, button)
            
        elif w_info[actionName + '.type'] == 'adb':
            adb_command = w_info[actionName + '.adb_command']
            w_info['log'].info('Action #' + str(i) + ' ->  Execute of adb command "' + adb_command + '"')
            w_info['adb'](adb_command)
            
        elif w_info[actionName + '.type'] == 'parse_selected_result':
            #ckipboarderApkPath = w_info[actionName + '.clipboarder_apk']
            # w_info;
            #resultRegexp = w_info[actionName + '.result_regexp']
            w_info['log'].info('Action #' + str(i) + ' ->  Analyze clipboarded data')
            results = ParseSelected(w_info, actionName)
            for item in results:
                bechmarkValue.append(item)
            
        elif w_info[actionName + '.type'] == 'parse_link':
             w_info['log'].info('Action #' + str(i) + ' ->  Analyze link data')
             results = ParseLink(w_info, actionName)
             for item in results:
                bechmarkValue.append(item)
        elif w_info[actionName + '.type'] == 'recognize_result':
            w_info['log'].info('Action #' + str(i) + ' ->  Recognize screenshot')
            result = RecognizeScreenshot(w_info, actionName)
            w_info['log'].info('\tbenchmark result: ' + str(result))
            bechmarkValue.append(result)
        elif w_info[actionName + '.type'] == 'process_logcat':
            w_info['log'].info('Action #' + str(i) + ' ->  Analyze logcat')
            results = ProcessLogcat(w_info, actionName)
            for item in results:
                bechmarkValue.append(item)
        elif w_info[actionName + '.type'] == 'process_file':
            w_info['log'].info('Action #' + str(i) + ' ->  Analyze file')
            results = ProcessFileFromDevice(w_info, actionName)
            for item in results:
                bechmarkValue.append(item)
        else:
            w_info['log'].info('Action #' + str(i) + ' ->  Unrecognized action type')
        
        i = i + 1
        actionName = 'action' + str(i)
        
        #time.sleep(4)
        awr_common.Sleep(4)
    
    return bechmarkValue

#input: set of set of float
#output: set of set of float
#performs: eliminates 'below zero values' from input set
def GetSuccessResults(data, dimension):
    result_values = []
    for res_vector in data:
        if len(res_vector) > dimension:
            if res_vector[dimension] > 0:
                result_values.append(res_vector[dimension])
    return [-1] if len(result_values) == 0 else result_values

#input: set of set of float
#output: float
def CalculateResultValue(results, i):
    #assert len(results) > 0
    rafined_results = GetSuccessResults(results, i)
    #assert len(rafined_results) > 0
    
    if len(rafined_results) == 0:
        return -1
    elif len(rafined_results) == 1:
        return rafined_results[0]
    elif len(rafined_results) == 2:
        return (rafined_results[0] + rafined_results[1])/2
    
    __results = sorted(rafined_results)#, key=lambda res_tuple: res_tuple[i])
    __results.pop(0)
    __results.pop(-1)
    
    if len(__results) % 2 == 1:
        return __results[len(__results)/2]
    else:
        a = __results[(len(__results)-1)/2]
        b = __results[(len(__results)+1)/2]
        return float(a+b)/2

def ClearHandlers(logger):
    cout_handler = None
    for item in logger.handlers:
        if item.__class__.__name__ == 'StreamHandler':
            cout_handler = item
    #    else:
    #        result.append(item)
    #logger.handlers = []
    if cout_handler != None:
        logger.removeHandler(cout_handler)
    return cout_handler

#def RestoreHandlers(logger, __handlers):
#    logger.handlers = __handlers
#    #for item in handlers:
#    #    logger.addHandler(item)
#    #logger.addHandler(stream_handler)

def AddResult(lst, value):
    lst.append(value)

def AddFailResult(lst):
    AddResult(lst, -1)

def GetBenchmarkIndexCount(w_info):
    i = 1
    while 'title' + str(i) in w_info:
        i = i + 1
    return i - 1
    
def FailWholeTest(w_info, reason):
    global success_count
    global fail_count
    count = int(w_info['exec_count'])
    fail_count += count
    for i in range(0, count):
        w_info['global_log'].info('Running: ' + w_info['workload'] + ', attempt (' + str(i+1) + '/' + str(count) + ') Failed: ' + reason)
    count = int(w_info['exec_count'])
    
    #create fails for all titles!
    results = []
    #i = 1
    #while 'title' + str(i) in w_info:
    #    results.append(-1)
    #    i = i + 1
    count = GetBenchmarkIndexCount(w_info)
    for i in range(count):
        results.append(-1)
    
    #for i in range(0, count):
    #    #results.append(-1)
    #    AddFailResult(results)
    return results

#return: set of pairs [indicator title, value]
def PerformanceTest(w_info):
    global success_count
    global fail_count
    
    count = int(w_info['exec_count'])
    results = []
    #results is set of ordered set of float (results)
    for i in range(0, count):
        w_info['action'] = str(i)
        #we want to print 2 messages in 1 line
        #remove console handler from logger.
        cout_handler = ClearHandlers(w_info['global_log'])
        message = 'Running: ' + w_info['workload'] + ', attempt (' + str(i+1) + '/' + str(count) + ') '
        res = []
        
        #in first, we print title, after benchmark execution we print execution state. 
        #message contains whole message. 
        #After try..except execution, we log this message (logger doesn't contains 
        #  console handler!) and add console handler to logger
        print message,
        
        try:
            start_result = BenchmarkStart(w_info)
            #success = True
            for item in start_result:
                if item < 0:
                    raise Exception('Invalid results')
            
            for item in start_result:
                res.append(item)
            
            res_str = ''
            for item in start_result:
                res_str += str(item) + ', '
            print 'Success: %s ' % (res_str)
            message += 'Success: %s ' % (res_str)
            success_count += 1
            
        except:
            e = traceback.format_exc()
            w_info['log'].error(e)
            message += 'Failed. See log at ' + w_info['log_path']
            print 'Failed. See log at ' + w_info['log_path']
            fail_count += 1
            #res = [-1]
            indexes_count = GetBenchmarkIndexCount(w_info)
            for i in range(indexes_count):
                res.append(-1)
        results.append(res)
        w_info['global_log'].info(message)
        w_info['global_log'].addHandler(cout_handler)
        
        #I'll implement it. Man^ana...
        #correct_min = float(w_info['correct_value_min'])
        #correct_max = float(w_info['correct_value_max'])
        #for item in res:
        #    if (item > correct_max) or (item < correct_min):
        #        raise Exception('Result doesn''t belong to the correct interval')
        
        if i < count - 1:
            w_info['cleanup']()
    avg_results = []
    for i in range(len(results[0])):
        #avg_results.append(CalculateResultValue(results, i))
        result = CalculateResultValue(results, i)
        AddResult(avg_results, result)
    return avg_results

def Init(awr_info):
   ocr.Learn(awr_info['samples_dir'])
