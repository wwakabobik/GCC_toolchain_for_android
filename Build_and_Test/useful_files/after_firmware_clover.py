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
    image.writeToFile('/nfs/ims/proj/icl/gcc_cw/users/abantonx/Monkeyrunner/' + name + '.png', 'png')
    time.sleep(1)
    #ExecuteSubprocessNoString("sh -c 'mv /tmp/1.png /users/abantonx/AndroidBuild/repos/images_from_phone'")
    
def Unlock():
    device.drag((300, 900), (600, 900), 1, 10) # screen unlocking
    time.sleep(1)
    CS("unlock");
    
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
    device.drag((544, 257), (676, 257), 1, 10) # Wifi enabling in settings
    CS("WifiEnabling0");
    time.sleep(1)
    CS("WifiEnabling1");
    time.sleep(2)
    CS("WifiEnabling2");
    time.sleep(7)
    CS("WifiEnabling3");

def DragVerifyApp(): # don't forget to enter to the Settings_menu
    device.drag((400, 900), (400, 400), 1, 10) # Drag menu up
    device.drag((400, 900), (400, 400), 1, 10) # One more time
    time.sleep(1)
    CS("DragDown_VerifyApp");

def DeveloperOptions(): # don't forget to enter to the Settings_menu
    device.drag((400, 900), (400, 400), 1, 10) # Drag menu up
    device.drag((400, 900), (400, 400), 1, 10) # One more time
    device.drag((400, 900), (400, 400), 1, 10) # One more time
    time.sleep(1)
    CS("DragDown");
    Click (device,224,1135);# enter to Developer Options in Settings menu
    time.sleep(1);
    CS("DevOptions");
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
    Click (device,100,870);# Discard "Vellamo Tutorial"
    time.sleep(2);
    CS("VellamoTutor");
    Click (device,425,615);# Discard "Vellamo Tutorial"
    time.sleep(1);
    CS("VellamoAfterTutor");
#    device.stopActivity(component=component_name)
    Click (device,100,900);# Discard "Vellamo Tutorial"
    time.sleep(5);
    CS("VellamoStart2");

#adb shell am start -a android.intent.action.VIEW -d http://pnphub.jf.intel.com/BM/FishTank_2.0.1/  # command for run fishtank
def StayAwake():
    Click (device, 622, 463);
    time.sleep(2);
    CS("StayAwake");
    
def SelectBrowser():
    #adb shell am start -a android.intent.action.VIEW -d http://pnphub.jf.intel.com/BM/FishTank_2.0.1/
    CS("Br0");
    Click (device,218,655);
    time.sleep(2);
    CS("Br1");
    Click (device,210,880);
    time.sleep(2);
    CS("Br2");
    
def FirstLaunch():
    CS("FirstLaunch_start");    
#    Click (device, 493, 798);
#    time.sleep(2);
    
#    CS("FirstLaunch_sim_skip");    
#    Click (device, 350, 1205);
#    time.sleep(2);
    
#    CS("FirstLaunch_wifi_skip");    
#    Click (device, 500, 1225);
#    time.sleep(2);
    
#    CS("FirstLaunch_wifi_skip_anyway");    
#    Click (device, 216, 742);
#    time.sleep(2);
    
#    CS("FirstLaunch_location");    
#    Click (device, 624, 1192);
#    time.sleep(2);
    
#    CS("FirstLaunch_date_time");    
#    Click (device, 624, 1192);
#    time.sleep(2);
    
#    CS("FirstLaunch_Phone_belongs_to");    
#    Click (device, 622, 738);
#    time.sleep(2);
    
#    CS("FirstLaunch_google_legal");    
#    Click (device, 349, 841);
#    time.sleep(2);
    
#    CS("FirstLaunch_google_legal_continue");    
#    Click (device, 624, 1192);
#    time.sleep(2);

#    CS("FirstLaunch_setup_complete");    
#    Click (device, 350, 1200);
#    time.sleep(2);

    CS("FirstLaunch_tutor");    
    Click (device, 600, 1200);
    time.sleep(2);
    
    
    CS("FirstLaunch_after_start");    
    
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

device.press('KEYCODE_HOME', MonkeyDevice.DOWN_AND_UP)



CS("State1_");
Unlock();
CS("State2_");
Unlock();
CS("State3_");

#FirstLaunch();
#CS("State1")
#VerifyApp();
#SelectBrowser();
Settings_menu();
DeveloperOptions();
StayAwake();
#DragVerifyApp();
#Security();
#UncheckVerifyApps();
#Network_more();
#Enabling_wifi();
#AboutPhone();
#AnTuTu();
#VellamoTutorial();

