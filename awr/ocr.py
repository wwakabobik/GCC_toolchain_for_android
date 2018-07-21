import sys
import os
import math
import ocr_splitter



def GetLearnedImages():
    return [('0.txt', '0'), ('1.txt', '1'), ('2.txt', '2'), ('3.txt', '3'), ('4.txt', '4'), ('5.txt', '5'), ('6.txt', '6'), ('7.txt', '7'), ('8.txt', '8'), ('9.txt', '9'), ('dot.txt', '.')]


samples = []
width = -1
height = -1

###################################
####  samples is tuple of arrays (arrays of bytes)
####  (width, height, samples[i]) is the image (see ocr_splitter.py)
###################################

def ReadImage(path):
    lst = []
    f = open(path, 'r')
    for line in f:
        for x in line.split():
            lst.append(int(x))
    f.close()
    return (lst[0], lst[1], lst[2:])

def WriteImage(image, path):
    #with open(path, 'w') as f:
    f = open(path, 'w')
    f.write(str(image[0])+ ' ' + str(image[1]) + '\n')
    ln = 0
    for v in image[2]:
        f.write(str(v) + ' ')
        ln = ln + 1
        if ln >= image[0]:
            f.write('\n')
            ln = 0
    f.close()

def Learn(samples_path):
    global width
    global height
    #samples = GetLearnedImages()
    for s in GetLearnedImages():
        #print 'open file: ' + 'P:\\AWR\\samples\\' + s[0]
        #img = ReadImage('P:\\AWR\\samples\\' + s[0])
        img = ReadImage(samples_path + s[0])
        width = img[0]
        height = img[1]
        
        # we add to samples just array of bytes (from image) and mapped symbol
        samples.append((img[2], s[1]))

def IsNearSample(x, y, sample):
    __width = sample[0]
    __height = sample[1]
    
    if (y-1) > 0:
        if sample[2][__width * (y-1) + x] == 0:
            return True
    if (y+1) < __height:
        if sample[2][__width * (y+1) + x] == 0:
            return True
    if (x-1) > 0:
        if sample[2][__width * y + (x-1)] == 0:
            return True
    if (x+1) < __width:
        if sample[2][__width * y + (x+1)] == 0:
            return True

    return False

def GetDiff(image1, sample):
    result = 0.0
    #for i in range(0, len(image1) - 1):
    for y in range(0, image1[1]):
        #str = ''
        for x in range(0, image1[0]):
            i = y*image1[0] + x
            #print i
            if image1[2][i] != sample[2][i]:
                #result = result + 1
                #else:
                if IsNearSample(x, y, sample):
                    result = result + 0.1
                    #str = str + '*'
                else:
                    result = result + 5
                    #str = str + ' '
        #print str
        
    return result
    
def RecognizeSymbol(image):
    global width
    global height
    min_value = float(sys.maxint)
    result = ''
    for s in samples:
        #value = GetDiff(image[2], s[0])
        value = GetDiff(image, (width, height, s[0]))
        #print 'for ' + s[1] + ' diff = ' + str(value)
        if value < min_value:
            min_value = value
            result = s[1]
        
    return result

def NormalizeSymbol(image):
    src_width = image[0]
    src_height = image[1]
    
    scaleX = float(width) / (src_width)
    scaleY = float(height) / (src_height)
    
    result = [0 for i in range(width*height)]
    
    for y in range(height):
        for x in range(width):
            src_x = (float(x)/scaleX)
            src_y = (int((y/scaleY)*src_width)/src_width)*src_width
            #print 'x = ' + str(x) + ', y = ' + str(y) + ' -> ' + str(int(src_x + src_y)) + ', (' + str(src_x) + '; ' + str(src_y) + ')'
            value = image[2][int(src_x + src_y)]
            result[(y*width) + x] = value
            
    return (width, height, result)

def NormalizeSymbols(images):
    result = []
    for img in images:
        result.append(NormalizeSymbol(img))
        
    return result


def ConvertToNumber(symbols):
    pow_number = len(symbols) - 1
    result = 0
    
    for c in symbols:
        result = result + int(c)*math.pow(10, pow_number)
        pow_number = pow_number - 1
        
    return result


def RecognizeImage(image):
    img_symbols = ocr_splitter.SplitSymbols(image)
    #img_symbols = SplitSymbols(image)
    
    normalized_symbols = NormalizeSymbols(img_symbols)
    
    recognized_symbols = []
    #i = 0
    for s in normalized_symbols:
        recognized_symbols.append(RecognizeSymbol(s))
        #WriteImage(s, 'c:/temp/' + str(i) + '.cpp')
        #i = i + 1
    #print recognized_symbols
    if '.' in recognized_symbols:
        #float-point number
        dot_indx = recognized_symbols.index('.')
        
        #print 'int: ', recognized_symbols[0:dot_indx]
        #print 'float: ', recognized_symbols[dot_indx+1:]
        
        int_part = ConvertToNumber(recognized_symbols[0:dot_indx])
        float_part = ConvertToNumber(recognized_symbols[dot_indx+1:])
        float_part = float_part / math.pow(10, len(recognized_symbols) - dot_indx - 1)
        
        return int_part + float_part
    else:
        #integer number
        
        return ConvertToNumber(recognized_symbols)
        
        

def TestOcr(learning_path, testcase_file):
    samples = []
    Learn(learning_path)
    print "---------------------------------------------------"
    f = open(testcase_file, 'r')
    for line in f:
        num = float(line[:line.find('?')])
        f_path = line[(line.find('?') + 1):-1]
        img = ReadImage(f_path)
        recognized = RecognizeImage(img)
        if recognized != num:
            print 'FAILED ', num, ' != ', str(recognized), ' at file -> ', f_path, '\t\t\t\t<---- !!!!!!!!!'
        else:
            print 'PASSED ', num, ' at file -> ', f_path
        print "---------------------------------------------------"
    f.close()
























