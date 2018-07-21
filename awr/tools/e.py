import shlex, subprocess
import re
import sys
import os
import time

__ProxyPort = '1234'
__DnsAddress = '10.248.2.1'

def ExecuteSubprocess(cmd):
	print 'Execute: ' + cmd
	args = shlex.split(cmd)
	result = ''
	proc = subprocess.Popen(args, stdout = subprocess.PIPE)
	line = proc.stdout.readline()
	while line != '':
		result += line
		line = proc.stdout.readline()
	result = result.replace('\r', '')
	result = result.replace('\n', '')
	result = result.replace('\t', ' ')
	
	return result

def ExecuteSubprocessNoString(cmd):
	print 'Execute: ' + cmd
	try:
		args = shlex.split(cmd)
		proc = subprocess.Popen(args)
		return proc.wait()
	except:
		pass


def GetParentByInterface(interface):
	ethtool_result = ExecuteSubprocess("sh -c 'ethtool -i " + interface + " 2>/dev/null'")
	interface_bus_result = re.findall('bus-info: usb-([0-9a-f:\.]+)\-([0-9]+)', ethtool_result)
	if len(interface_bus_result) < 1:
		return ''
	shell_command = 'find /sys/devices/pci0000:00/' + interface_bus_result[0][0] + '/*/*' + interface_bus_result[0][1] + ' -name serial | xargs cat'
	print 'Command: ' + shell_command
	serial = ExecuteSubprocess("sh -c '" + shell_command + " 2>/dev/null '")
	serial = serial.replace('\r', '')
	serial = serial.replace('\n', '')
	serial = serial.replace('\t', '')
	print interface + ' -> ' + serial
	return serial


def GetDeviceInterface(serial, interface_base = 'usb'):
	for i in range(10):
		current_serial = GetParentByInterface(interface_base + str(i))
		#print 'current serial = ' + current_serial
		#print 'orig serial    = ' + serial
		if serial == current_serial:
			return interface_base, i
	return '', 0
	"""
	current_interface = 0
	current_serial = GetParentByInterface(interface_base + str(current_interface))
	print 'current serial = ' + current_serial
	print 'sample serial  = ' + serial
	while current_serial != '' and (current_serial != serial):
		current_interface += 1
		current_serial = GetParentByInterface(interface_base + str(current_interface))
	print 'serial = ', current_serial
	__interface_base = interface_base if current_serial != '' else ''
	__interface_number = current_interface
	print 'base = ', __interface_base
	print 'number = ', __interface_number
	return __interface_base, __interface_number"""

def TurnOnInterface(serial):
	interface_name, interface_number =  GetDeviceInterface()
	ExecuteSubprocessNoString('sudo ifconfig ' + interface_name + str(interface_number) + ' up')

#finction 
def ObtainInterface(serial):
	global __interface_base
	global __interface_number
	global __device_interface
	__interface_base, __interface_number =  GetDeviceInterface(serial)
	#print 'result = ' ,__interface_base, __interface_number
	__device_interface = __interface_base + str( __interface_number )
	
	if __interface_base == '':
		raise Exception('No interface for serial')
"""
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
"""
def GetHostIP():
	"""global __host_ip
	if __host_ip == '':
		str = ExecuteSubprocess('ifconfig')
		regex = interface + '(?:[\\w\\W]*?)inet addr:([0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3})'
		result = re.findall(regex, str)
		if len(result) > 0:
			__host_ip = result[0]
	return __host_ip"""
	global __interface_number
	return '192.168.' + str(42 + __interface_number) + '.1'

def GetDeviceIP():
	global __interface_number
	return '192.168.' + str(42 + __interface_number) + '.101'
	"""global __device_ip
	if __device_ip == '':
		str = ExecuteSubprocess('adb shell netcfg')
		regex = interface + '(?:[\\w\\W]*?)([0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3})'
		result = re.findall(regex, str)
		if len(result) > 0:
			__device_ip = result[0]
		
	return __device_ip
	#return '192.168.42.101'"""

def ClearNAT():
	global __interface_number
	global __device_interface
	proxy_chain_name = 'tproxy' + str(__interface_number)
	ExecuteSubprocessNoString('iptables -t nat -F ' + proxy_chain_name)
	ExecuteSubprocessNoString('iptables -t nat -D PREROUTING -i ' + __device_interface + ' -p tcp -j ' + proxy_chain_name)
	ExecuteSubprocessNoString('iptables -t nat -X ' + proxy_chain_name)
	ExecuteSubprocessNoString('iptables -t nat -Z ')

def CreateTProxyChain():
	global __ProxyPort
	global __device_interface
	global __interface_number
	proxy_chain_name = 'tproxy' + str(__interface_number)
	ExecuteSubprocessNoString('ifconfig ' + __device_interface + ' ' + GetHostIP() + ' netmask 255.255.255.0 up')
	ExecuteSubprocessNoString('iptables -t nat -N ' + proxy_chain_name)
	ExecuteSubprocessNoString('iptables -t nat -A ' + proxy_chain_name + ' -d 0.0.0.0/8 -j RETURN')
	ExecuteSubprocessNoString('iptables -t nat -A ' + proxy_chain_name + ' -d 10.0.0.0/8 -j RETURN')
	ExecuteSubprocessNoString('iptables -t nat -A ' + proxy_chain_name + ' -d 127.0.0.0/8 -j RETURN')
	ExecuteSubprocessNoString('iptables -t nat -A ' + proxy_chain_name + ' -d 163.33.0.0/8 -j RETURN')
	ExecuteSubprocessNoString('iptables -t nat -A ' + proxy_chain_name + ' -d 134.134.0.0/8 -j RETURN')
	ExecuteSubprocessNoString('iptables -t nat -A ' + proxy_chain_name + ' -d 169.254.0.0/8 -j RETURN')
	ExecuteSubprocessNoString('iptables -t nat -A ' + proxy_chain_name + ' -d 172.16.0.0/12 -j RETURN')
	ExecuteSubprocessNoString('iptables -t nat -A ' + proxy_chain_name + ' -d 192.168.0.0/8 -j RETURN')
	ExecuteSubprocessNoString('iptables -t nat -A ' + proxy_chain_name + ' -d 224.0.0.0/4 -j RETURN')
	ExecuteSubprocessNoString('iptables -t nat -A ' + proxy_chain_name + ' -d 240.0.0.0/4 -j RETURN')
	ExecuteSubprocessNoString('iptables -t nat -A ' + proxy_chain_name + ' -p tcp -j REDIRECT --to-ports ' + __ProxyPort)
	ExecuteSubprocessNoString('iptables -t nat -A PREROUTING -i ' + __device_interface + ' -p tcp -j ' + proxy_chain_name)
	ExecuteSubprocessNoString('iptables -A POSTROUTING -t nat -s ' + GetDeviceIP() + ' -j MASQUERADE')

def ClearRouteTableOnDevice():
	time.sleep(1)
	ExecuteSubprocessNoString('adb shell "su -c ip route flush all"');

def EnableRNDIS(interface='rndis0'):
	global __device_interface
	global __interface_number
	time.sleep(1)
	ExecuteSubprocessNoString('adb shell "su -c ip route add 192.168.' + str(42 + __interface_number) + '.0/24 dev ' + 'rndis0' + ' proto kernel  scope link  src ' + GetDeviceIP() + ' " ')
	time.sleep(1)
	ExecuteSubprocessNoString('adb shell "su -c ip route add default via ' + GetHostIP() + ' dev ' + 'rndis0 "')
	time.sleep(1)

def EnableHostInterface():
	ExecuteSubprocessNoString('ifconfig ' + __device_interface + ' up')

def PrepareDevice():
	global __DnsAddress
	global __device_interface
	time.sleep(5)
	ExecuteSubprocessNoString('adb shell "su -c netcfg ' + 'rndis0' + ' ' + 'up"')
	time.sleep(10)
	
	ExecuteSubprocessNoString('adb shell "su -c ifconfig ' + 'rndis0' + ' ' + GetDeviceIP() + ' netmask 255.255.255.0"')
	time.sleep(1)
	ExecuteSubprocessNoString('adb shell "su -c setprop net.dns1 ' + __DnsAddress + ' "')
	time.sleep(1)
	ExecuteSubprocessNoString('adb shell "su -c route add default gw ' + GetHostIP() + ' dev ' + 'rndis0 "')
	time.sleep(1)

if __name__ == '__main__':
	if len(sys.argv) < 2:
		print 'No Command!'
		print 'Usage: '
		print '-iptables   \tModify iptables'
		print '-device     \tUpdate device'
		print '-clean      \tClean IPTABLES settings (may be dangerous!)'
		print '-no-internet\tFlush all route table (really dangerous!)'
		print '-rndis-only \tFlush all route table, add default connection via rndis0 interface only! (may be dangerous!)'
		sys.exit(0)
	
	#print 'Device IP: ' + GetDeviceIP()
	#print 'My IP: ' + GetHostIP(__DeviceInterface)
	
	#global __interface_base
	#global __interface_number
	#global __device_interface
	
	
	#serial = ''
	#if len(sys.argv) > 2:
	#	serial = sys.argv[2]
	#else:
	serial = os.environ['ANDROID_SERIAL']
	
	ObtainInterface(serial)
	
	time.sleep(2)
	
	#print 'interface
	if sys.argv[1] == '-iptables':
		CreateTProxyChain()
	#elif sys.argv[1] == '-masquerade':
	#	UpdateMasquerade()
	elif sys.argv[1] == '-device':
		PrepareDevice()
	elif sys.argv[1] == '-clean':
		ClearNAT()
	elif sys.argv[1] == '-rndis-only':
		ClearRouteTableOnDevice()
		EnableRNDIS()
	elif sys.argv[1] == '-no-internet':
		ClearRouteTableOnDevice()
	elif sys.argv[1] == '-enable-host-interface':
		EnableHostInterface()
	else:
		print 'Unknown command'
	












