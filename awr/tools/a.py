import shlex, subprocess
import re
import sys
import os
import time

def ExecuteSubprocess(cmd):
    print 'Execute: ' + cmd
    args = shlex.split(cmd)
    result = ''
    proc = subprocess.Popen(args, stdout = subprocess.PIPE)
    line = proc.stdout.readline()
    while line != '':
        result += line
        line = proc.stdout.readline()
    return result

def ExecuteSubprocessNoString(cmd):
    print 'Execute: ' + cmd
    try:
        args = shlex.split(cmd)
        proc = subprocess.Popen(args)
        return proc.wait()
    except:
        pass

def WaitForWiFiConnected():
    wifiIP = '0.0.0.0'
    i = 0
    while wifiIP == '0.0.0.0' and i < 6:
        i = i + 1
        time.sleep(5)
        execStatus = ExecuteSubprocess('adb shell netcfg')
        regex = 'wlan0\s*(?:UP|DOWN)\s*([0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3})'
        result = re.findall(regex, execStatus)
        if len(result) > 0:
            wifiIP = result[0]
            print 'WiFi IP: ' + wifiIP


if __name__ == '__main__':
    # After reset my must:
    # 1. Enable USB-tethering
    # 2. Enable WiFi
    # 3. Wait for WiFi connection
    # 4. Run enable_internet.py scripts with arguments:
    #  4.1 -clean (with sudo)
    #  4.2 -iptables (with sudo)
    #  4.3 -device
    #  4.4 -no-internet
    #  4.5 -rndis-only
    # 5. Unlock phone (after reset phone is locked by default)
    #
    # Device will be ready to AWR after this script.

    sudo_script = 'python enable_internet.py'
    if len(sys.argv) > 2:
        if sys.argv[1] == '-sudo-script':
            sudo_script = sys.argv[2]

    ExecuteSubprocessNoString('adb reboot')
    ExecuteSubprocessNoString('adb wait-for-device')
    ExecuteSubprocessNoString('adb root')
    time.sleep(15)
    ExecuteSubprocessNoString('adb shell "su -c setprop sys.usb.config rndis,adb"')
    time.sleep(4)
    ExecuteSubprocessNoString('adb shell su -c sh -c " ifconfig wlan0 up "')
    WaitForWiFiConnected()
    ExecuteSubprocessNoString('adb shell su -c sh -c " ifconfig rndis0 up "')
    time.sleep(4)
    ExecuteSubprocessNoString('sudo -E ' + sudo_script + ' -clean')
    ExecuteSubprocessNoString('sudo -E ' + sudo_script + ' -iptables')
    ExecuteSubprocessNoString('sudo -E ' + sudo_script + ' -enable-host-interface')
    ExecuteSubprocessNoString(sudo_script + ' -device')
    ExecuteSubprocessNoString(sudo_script + ' -no-internet')
    ExecuteSubprocessNoString(sudo_script + ' -rndis-only')
    ExecuteSubprocessNoString('monkeyrunner unlock_screen.py')
    ExecuteSubprocessNoString('adb shell su -c sh -c "echo userspace > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor"')
    ExecuteSubprocessNoString('adb shell su -c sh -c "echo 1600000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq"')
    ExecuteSubprocessNoString('adb shell su -c sh -c "echo 1600000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq"')
