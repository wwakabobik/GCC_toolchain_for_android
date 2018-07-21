import sys
import os
import time
import shlex
import subprocess

from com.android.monkeyrunner import MonkeyRunner, MonkeyDevice
device = MonkeyRunner.waitForConnection(99, os.getenv('ANDROID_SERIAL'))

def Click(device, left, top, duration = 0):
    if duration == 0:
        device.touch(left, top, MonkeyDevice.DOWN_AND_UP)
    else:
	device.touch(left, top, MonkeyDevice.DOWN)
	time.sleep(duration)
	device.touch(left, top, MonkeyDevice.UP)

def ExecuteSubprocessNoString(cmd):
    print 'Execute: ' + cmd
    ags = shlex.split(cmd)
    proc = subprocess.Popen(args)
    return proc.wait()
                                                        
def CS(name):
    image = device.takeSnapshot()
    image.writeToFile('/nfs/ims/proj/icl/gcc_cw/users/abantonx/Monkeyrunner_nexus4/' + name + '.png', 'png')
    time.sleep(1)
    #ExecuteSubprocessNoString("sh -c 'mv /tmp/1.png /users/abantonx/AndroidBuild/repos/images_from_phone'")
    
def Unlock():
    device.drag((395, 950), (665, 950), 1, 10) # screen unlocking
    time.sleep(4)
#    CS("unlock");
    
def Settings_menu():
    package='com.android.settings'
    activity='.Settings'
    component_name=package + "/" + activity 
    device.startActivity(component=component_name)
    time.sleep(2)
    CS("Settings");
#    time.sleep(2)
#    Click (device,142,416);# 
#    time.sleep(2)
#    CS("Settings1");
    #Click (device,142,416);# 
#    time.sleep(2)
#    CS("Settings1");
#    Click (device,189,351);# 
#    time.sleep(2)
#    CS("Settings2");

def Enabling_wifi(): # don't forget to enter to the Settings_menu
    device.drag((520, 265), (660, 265), 1, 10) # Wifi enabling in settings
    CS("WifiEnabling0");
    time.sleep(1)
    CS("WifiEnabling1");
    time.sleep(2)
    CS("WifiEnabling2");
    time.sleep(7)
    CS("WifiEnabling3");
    
def tap_wifi(): # don't forget to enter to the Settings_menu
    Click(device, 220, 265)
    time.sleep(2)
    CS("WifiTap");
    Click(device, 114, 138)
    time.sleep(2)
    CS("WifiTap2");


def DragVerifyApp(): # don't forget to enter to the Settings_menu
    device.drag((400, 900), (400, 400), 1, 10) # Drag menu up
    device.drag((400, 900), (400, 400), 1, 10) # One more time
    time.sleep(1)
    CS("DragDown_VerifyApp");
#    00289867da111923

def dmark():
    package='com.futuremark.dmandroid.application'
    activity='.activity.MainActivity'
    component_name=package + "/" + activity
    device.startActivity(component=component_name)
    time.sleep(2);
    CS("3dmarkstart");
    time.sleep(10);
    CS("3dmarkstart1");
    time.sleep(10);
    CS("3dmarkstart2");
    time.sleep(10);
    CS("3dmarkstart3");
                                                

def DeveloperOptions(): # don't forget to enter to the Settings_menu
    device.drag((400, 900), (400, 400), 1, 10) # Drag menu up
    device.drag((400, 900), (400, 400), 1, 10) # One more time
    device.drag((400, 900), (400, 400), 1, 10) # One more time
    time.sleep(1)
    CS("DragDown");
    Click (device,200,1041);# enter to Developer Options in Settings menu
    time.sleep(1);
    CS("DevOptions");
#    Click (device,667,467);# enter to Developer Options in Settings menu
    time.sleep(1);
    CS("DevOptions2");
#    device.drag((400, 900), (400, 400), 1, 10) # One more time
#    time.sleep(1)
#    CS("DragDown1");
#    device.drag((400, 900), (400, 400), 1, 10) # One more time
#    time.sleep(1)
#    CS("DragDown2");
#    device.drag((400, 900), (400, 400), 1, 10) # One more time
#    time.sleep(1)
#    CS("DragDown3");
#    device.drag((400, 900), (400, 400), 1, 10) # One more time
#    time.sleep(1)
#    CS("DragDown4");
#    device.drag((400, 900), (400, 400), 1, 10) # One more time
#    time.sleep(1)
#    CS("DragDown5");

def Network_more(): # don't forget to enter to the Settings_menu
    Click (device,110,195);# 
    time.sleep(3);
    CS("NetworkMore");
    
def AnTuTu():
    package='com.antutu.ABenchMark'
    activity='.ABenchMarkStart'
    component_name=package + "/" + activity 
    device.startActivity(component=component_name)
    time.sleep(4);
    CS("antutu0");
    Click (device,304,962);
    time.sleep(5);
    CS("antutu1");

def AboutPhone(): # don't forget to enter to the Settings_menu
    device.drag((400, 900), (400, 400), 1, 10) # Drag menu up
    device.drag((400, 900), (400, 400), 1, 10) # Drag menu up
    CS("About Phone0");
    Click (device,300,990);# Enter to "About Phone" menu
    time.sleep(1);
    CS("About Phone1");

def VellamoTutorial():
    package='com.quicinc.vellamo'
    activity='.Vellamo'
    component_name=package + "/" + activity 
    device.startActivity(component=component_name)
    time.sleep(2);
    CS("VellamoStart");
#    Click (device,230,1100);# Discard "Vellamo Tutorial"
    time.sleep(2);
    CS("VellamoTutor");
#    Click (device,525,655);# Discard "Vellamo Tutorial"
    time.sleep(1);
    CS("VellamoAfterTutor");
#    device.stopActivity(component=component_name)
    Click (device,131,965)# Discard "Vellamo Tutorial"
    time.sleep(5);
    CS("VellamoStart2");
    Click (device,525,750);# Discard "Vellamo Tutorial"
    time.sleep(5);
    CS("VellamoStart3");

#adb shell am start -a android.intent.action.VIEW -d http://pnphub.jf.intel.com/BM/FishTank_2.0.1/  # command for run fishtank
def SelectBrowser():
    #adb shell am start -a android.intent.action.VIEW -d http://pnphub.jf.intel.com/BM/FishTank_2.0.1/
    CS("Br0");
    Click (device,218,655);
    time.sleep(2);
    CS("Br1");
    Click (device,210,880);
    time.sleep(2);
    CS("Br2");
    
def VerifyApp():
    Click (device,170,655);
    time.sleep(2);
    CS("VerifyApp");

def Security():
    Click (device,154,386);
    time.sleep(2);
    CS("Security");
def UncheckVerifyApps():
    Click (device,526,964);
    time.sleep(2);
    CS("UncheckVerifyApps");

Unlock();
CS("State");

Unlock();
CS("State2");

#CS("State1")
#VerifyApp();
#SelectBrowser();

#Settings_menu();
#Click (device,300,266);#Chrome1
#time.sleep(2);
#CS("State2")
#Click (device,232,208);#Chrome1
#time.sleep(2);
#CS("State3")
dmark();
#DeveloperOptions();
#DragVerifyApp();
#tap_wifi();
#Security();
#UncheckVerifyApps();
#Network_more();
#Enabling_wifi();
#AboutPhone();
#AnTuTu();
#VellamoTutorial();

