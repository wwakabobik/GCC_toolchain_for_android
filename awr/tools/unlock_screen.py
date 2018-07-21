from com.android.monkeyrunner import MonkeyRunner, MonkeyDevice
import sys
import os

device_serial = os.environ['ANDROID_SERIAL']
device = MonkeyRunner.waitForConnection(99, device_serial)
device.drag((300, 900), (600, 900), 1, 10)