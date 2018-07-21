import os
import sys
import shlex
import time
from com.android.monkeyrunner import MonkeyRunner, MonkeyDevice

class ApkApplication:
    def __init__(self, adb_, apk_file, package):
        #self.m_log = log
        self.m_adb = adb_
        self.m_apk_file = apk_file
        self.m_package = package
        self.m_installed = False
    def Install(self):
        if self.m_installed:
            return
        self.adb('uninstall ' + self.m_package)
        adb_command = 'install ' + self.m_apk_file
        self.adb(adb_command)
        self.m_installed = True
    def UnInstall(self):
        if not self.m_installed:
            return
        adb_command = 'uninstall ' + self.m_package
        self.adb(adb_command)
        self.m_installed = False
    def adb(self, command):
        #self.m_log('adb command: ' + command)
        #print 'adb: ' + command
        self.m_adb(' ' + command)

#screener = ScreenOrientationTool(_log, adb, 'p:\\\\AWR/tools/OrientationChanger.apk', 'com.intel.orientation')
class ScreenOrientationTool(ApkApplication):    
    def SetLandscape(self):
        adb_command = 'shell am start -S -a android.intent.action.VIEW -n ' + self.m_package + '/.LandscapeActivity'
        self.adb(adb_command)
        time.sleep(1.5)
    def SetPortrait(self):
        adb_command = 'shell am start -S -a android.intent.action.VIEW -n ' + self.m_package + '/.PortraitActivity'
        self.adb(adb_command)
        time.sleep(1.5)

#clipboarder = ClipboardContentTool(_log, adb, 'p:/AWR/tools/Clipboarder.apk', 'com.intel.clipboard', device, 'c:/temp/temp_file.txt')
#clipboarder.GetClipboardText()
class ClipboardContentTool(ApkApplication):    
    def __init__(self, adb_, apk_file, package, device, temp_file):
        self.m_adb = adb_
        self.m_apk_file = apk_file
        self.m_package = package
        self.m_monkey_device = device
        self.m_temp_file = temp_file
        self.m_installed = False
    def GetClipboardText(self):
        #self.adb('rm -f /data/data/com.intel.clipboard/files/clipboard_data.txt')
        self.m_monkey_device.startActivity(component='com.intel.clipboard/.PushToFile')
        time.sleep(1)
        self.m_monkey_device.touch(300, 360, MonkeyDevice.DOWN_AND_UP)
        time.sleep(2)
        self.adb('pull /data/data/com.intel.clipboard/files/clipboard_data.txt ' + self.m_temp_file)
        try:
            str = ''
            f = open(self.m_temp_file, 'r')
            for line in f:
                str = str + line
            f.close()
        finally:
            if os.path.exists(self.m_temp_file):
                os.remove(self.m_temp_file)
        return str
