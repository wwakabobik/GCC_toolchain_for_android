#!/usr/bin/python

import os
import sys

import awr_config
import awr_status

def result(rf, text):
    with open(rf, 'at') as f:
        f.write(text)
        
def _check_result():
    if os.path.isfile('result.log'):
        f = open('result.log', 'rt')
        line = f.readline().strip('\n\r\t ')
        if line != 'finished':
            return line
        else:
            return None
    else:
        return 'files_missed'
        
def _check_success():
    return 'success'

_files = set(['after_start.png', 'before_end.png', 'install.log', 'startup.log', 'run.log', 'uninstall.log'])
_m_files = set(['after_start.png', 'before_end.png', 'startup.log', 'run.log'])

def _check_files():
    files = set(os.listdir(os.curdir))
    if _m_files.issubset(files):
        return None
    else:
        return 'files_missed'

def _check_logs():
    logs = [f for f in os.listdir(os.curdir) if f[-4:] in ('.log', '.txt')]
    if 'startup.log' not in logs:
        return 'bad_start'
    for line in open('startup.log', 'rt'):
        if line.startswith('I/DEBUG'):
            return 'bad_start'
        if 'FATAL EXCEPTION' in line:
            return 'bad_start'
        if 'WIN DEATH' in line:
            return 'bad_start'

    if 'uninstall.log' in logs:
        for line in open('uninstall.log', 'rt'):
            if line.startswith('I/DEBUG'):
                return 'bad_uninstall'
            if 'FATAL EXCEPTION' in line:
                return 'bad_uninstall'
        
    for f in logs:
        for line in open(f, 'rt'):
            if line.startswith('I/DEBUG'):
                return 'bad_run'
            if 'FATAL EXCEPTION' in line:
                return 'bad_run'
    return None

check_pipeline = [
    _check_result,
    _check_files,
    _check_logs,
    _check_success,
]

def check_workload(workload):
    for check in check_pipeline:
        t = check()
        if t is not None:
            return t

if __name__ == '__main__':
    awr_info = {}
    awr_config.read_config(awr_info)
    failed_workloads = []
    output = sys.argv[1]
    result_dir = awr_info['results_dir'] + output + '/'
    if not os.path.isdir(result_dir + 'summary'):
        os.mkdir(result_dir + 'summary')
    rf = result_dir + 'summary/result.htm'
    if os.path.isfile(rf):
        os.remove(rf)
    result(rf, """<html>
<head>
    <title>AWR Testing Results</title>
</head>
<body>
    <table border="1" cellpadding="4px"">
    <tr><td><strong>Application</strong></td><td><strong>Status</strong></td></tr>
""")
    with open(result_dir + 'summary/result.txt', 'wt') as f:
        f.write('Workload,Status\n')
    for workload in os.listdir(result_dir):
        if not os.path.isdir(result_dir + workload) or workload == 'summary':
            continue
        os.chdir(result_dir + workload)
        status = check_workload(workload)
        status_text = awr_status.get_status_text(status)
        status_color = awr_status.get_status_color(status)
        with open(result_dir + 'summary/result.txt', 'at') as f:
            f.write('{0},{1}\n'.format(workload, status))
            result(rf, '        <tr><td>{0}</td><td bgcolor="{1}" align="center">{2}</td></tr>\n'.format(
                 workload, status_color, status_text))
            failed_workloads.append(workload)
    result(rf, """</table>
</body>
</html>
""")
    os.chdir(result_dir)
    with open('failed_workloads.txt', 'wt') as f:
        for workload in failed_workloads:
            f.write('{0}\n'.format(workload))
