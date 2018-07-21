import sys
import os

if __name__ == '__main__':
    version = 1
    try:
        f = open("version.cfg")
        content = f.read()
        content = content.strip('\r\n\t')
        f.close()
        version = int(content)
    except:
        print 'exception..'
    version = version + 1
    print "Vew version: " + str(version)
    f = open("version.cfg", "w")
    f.write(str(version))
    f.close()
