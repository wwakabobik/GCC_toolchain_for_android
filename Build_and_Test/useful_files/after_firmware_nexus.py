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
    image.writeToFile('/nfs/ims/proj/icl/gcc_cw/users/abantonx/Monkeyrunner_nexus/' + name + '.png', 'png')
    time.sleep(1)
    #ExecuteSubprocessNoString("sh -c 'mv /tmp/1.png /users/abantonx/AndroidBuild/repos/images_from_phone'")
    
def Unlock():
    device.drag((300, 1000), (600, 1000), 1, 10) # screen unlocking
    time.sleep(1)
    CS("unlock");
    
def Settings_menu():
    package='com.android.settings'
    activity='.Settings'
    component_name=package + "/" + activity 
    device.startActivity(component=component_name)
    time.sleep(2)
    CS("Settings");
#    Click (device,136,409);
#    time.sleep(2)
#    CS("Settings1");
#    Click (device,146,350);
#    time.sleep(2)
#    CS("Settings2");

def Quadrant():
    package='com.aurorasoftworks.quadrant.ui.professional'
    activity='.QuadrantProfessionalActivity'
    component_name=package + "/" + activity 
    device.startActivity(component=component_name)
    time.sleep(4);
    CS("Quadrant");
    Click (device,190,1020); #accept licence
    time.sleep(2);
    CS("Quadrant1");

def Bench():
    package='org.zeroxlab.zeroxbenchmark'
    activity='.Benchmark'
    component_name=package + "/" + activity 
    device.startActivity(component=component_name)
    time.sleep(4);
    CS("0xBench");
    Click (device,60,670);
    Click (device,60,765);
    Click (device,60,860);
    Click (device,60,955);
    Click (device,60,1050);
    device.drag((500, 1050), (500, 560), 1, 10) # Wifi enabling in settings
    Click (device,60,945);
#    Click (device,60,1050);
    time.sleep(5);
    CS("OxBench2");


def Enabling_wifi(): # don't forget to enter to the Settings_menu
    device.drag((495, 260), (620, 260), 1, 10) # Wifi enabling in settings
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
    Click (device,200,1037);# enter to Developer Options in Settings menu
    time.sleep(1);
    CS("DevOptions");
    device.drag((400, 900), (400, 400), 1, 10) # One more time
    time.sleep(1)
    CS("DragDown1");
    device.drag((400, 900), (400, 400), 1, 10) # One more time
    time.sleep(1)
    CS("DragDown2");
    device.drag((400, 900), (400, 400), 1, 10) # One more time
    time.sleep(1)
    CS("DragDown3");
    device.drag((400, 900), (400, 400), 1, 10) # One more time
    time.sleep(1)
    CS("DragDown4");
    device.drag((400, 900), (400, 400), 1, 10) # One more time
    time.sleep(1)
    CS("DragDown5");

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
    #Click (device,304,962);
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
#    Click (device,200,1090);# accept "Vellamo Licence"
    time.sleep(2);
    CS("VellamoTutor");
#    Click (device,510,700);# Discard "Vellamo list of websites"
    time.sleep(1);
    CS("VellamoAfterTutor");
#    device.stopActivity(component=component_name)
    Click (device,120,990);# "Start Vellamo"
    time.sleep(5);
    CS("VellamoStart2");
    Click (device,520,780);# "Discard vellamo tutorial"
    time.sleep(2);
    CS("VellamoStart3");
def certificate():
    CS("cert0");
    Click (device,550,740);
#adb shell am start -a android.intent.action.VIEW -d http://pnphub.jf.intel.com/BM/FishTank_2.0.1/  # command for run fishtank
def SelectBrowser():
    CS("Br0");
    Click (device,183,537);
    time.sleep(2);
    CS("Br1");
    Click (device,178,698);
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
    
CS("State");
Unlock();
#certificate();
#Bench();
#Quadrant();
#VerifyApp();
SelectBrowser();
#Settings_menu();
#DeveloperOptions();
#DragVerifyApp();
#Security();
#UncheckVerifyApps();
#Network_more();
#Enabling_wifi();
#AboutPhone();
#AnTuTu();

