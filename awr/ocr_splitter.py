import math
import sys


#### image is tuple, which contains:
####   - image[0] is image width
####   - image[1] is image height
####   - image[2] is array of pixels (valid values is {1;-1})

def TotalizeImageByRows(image):
    result = [0 for i in range(image[1])]
    
    for x in range(image[0]):
        for y in range(image[1]):
            result[y] = result[y] + image[2][y*image[0] + x]
    
    return result


################################
## toalize summ values in column
################################
def TotalizeImageByCols(image):
    result = [0 for i in range(image[0])]
    
    for x in range(image[0]):
        for y in range(image[1]):
            result[x] = result[x] + image[2][y*image[0] + x]
    
    return result

MIN_SYMBOLS_COUNT = 2
MAX_SYMBOLS_COUNT = 7

def __IsNormalTestEuristic(totalized, edge):
    crossEdgeCount = 0
    prevBelowEdge = totalized[0] < edge
    
    for i in range(1, len(totalized)):
        if prevBelowEdge and totalized[i] > edge:
            prevBelowEdge = False
            crossEdgeCount = crossEdgeCount + 1
            
        elif (not prevBelowEdge) and totalized[i] < edge:
            prevBelowEdge = True
            crossEdgeCount = crossEdgeCount + 1
            
        if crossEdgeCount/2 > MAX_SYMBOLS_COUNT:
            return False
    
    return crossEdgeCount/2 >= MIN_SYMBOLS_COUNT

def GetSymbolsEdgeEuristic(totalized):
    min_value = min(totalized)
    max_value = max(totalized)
    
    val = max_value
    while val > min_value:
        #print val
        if __IsNormalTestEuristic(totalized, val):
            return val
        
        val = val - 1 #math.ceil(((max_value - min_value) / 10.0))
        
    print 'Can\'t split result image to symbols'
    sys.exit()


def GetNumberCols(totalized):
    result = []
    is_number_region = False
    start_value = 0
    
    edge_value = GetSymbolsEdgeEuristic(totalized)
    #print 'edge = ' + str(edge_value)
    for i in range(len(totalized)):
        if not is_number_region and totalized[i] <= edge_value:
            start_value = i
            is_number_region = True
        if is_number_region and totalized[i] > edge_value:
            is_number_region = False
            result.append((start_value, i))
    
    return result


def GetNumberRows(totalized):
    max_value = max(totalized)
    min_value = min(totalized)
    
    #print totalized
    #print max_value
    #print min_value
    
    edge_value = float(min_value) + (float(max_value - min_value)*0.8)
    
    top_border = 0
    bottom_border = len(totalized) - 1
    
    while totalized[top_border] >= edge_value:
        top_border = top_border + 1
    
    while totalized[bottom_border] >= edge_value:
        bottom_border = bottom_border - 1
    
    #print (top_border, bottom_border)
    return (top_border, bottom_border)


def GetSubImage(image, colStart, colEnd, rowStart, rowEnd):
    result = []
    #result[0] = colEnd - ColStart + 1
    #result[1] = rowEnd - rowStart
    
    for y in range(rowStart, rowEnd+1):
        for x in range(colStart, colEnd+1):
            result.append(image[2][y*image[0] + x])
    
    return (colEnd - colStart + 1, rowEnd - rowStart + 1, result)

def FindNextEmptyColumn(my_image, x_start):
    for x in range(x_start, my_image[0]):
        count = 0
        for y in range(0, my_image[1]):
            count = count + my_image[2][y * my_image[0] + x]
        if count == 0 or count == my_image[1]:
            return x
    return -1

def SplitSymbols(image):
    result = []
    
    totalizedByRows = TotalizeImageByRows(image)
    numberRows = GetNumberRows(totalizedByRows)
    
    x_start = 0
    while x_start != -1:
        x_next = FindNextEmptyColumn(image, x_start+1)
        #print x_start, ' -> ', x_next
        if x_next != -1:
            if x_start+2 < x_next:
                #print x_start+1, '...', x_next-1
                result.append(GetSubImage(image, x_start+1, x_next-1, numberRows[0], numberRows[1]))
            elif x_start+1 < x_next:
                #print 'one-column number!'
                result.append(GetSubImage(image, x_start, x_next-1, numberRows[0], numberRows[1]))
        x_start = x_next
        
    return result
    
    
    """
    totalizedByCols = TotalizeImageByCols(image)
    totalizedByRows = TotalizeImageByRows(image)
    
    numberCols = GetNumberCols(totalizedByCols)
    numberRows = GetNumberRows(totalizedByRows)
    
    for it in numberCols:
        img = GetSubImage(image, it[0], it[1], numberRows[0], numberRows[1])
        result.append(img)
        
    return result
    """