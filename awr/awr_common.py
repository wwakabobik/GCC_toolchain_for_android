import sys
import os
import errno
import time
import shlex, subprocess
import shutil
import re
import traceback
import logging

global __is_debug

def Sleep(time_to_sleep):
    time.sleep(time_to_sleep)
    return
    if not __is_debug:
        time.sleep(time_to_sleep)
    else:
        time.sleep(1 if time_to_sleep > 1 else time_to_sleep)

def Init(awr_info):
    global __is_debug
    __is_debug = False
    if 'debug' in awr_info:
        if awr_info['debug'] == 'true':
            __is_debug = True
