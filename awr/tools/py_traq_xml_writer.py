import sys
import os
import datetime
import marshal
from datetime import datetime
import libxml2

libxml2.keepBlanksDefault(0)

def OpenTraqTemplate(filePath):
    root = libxml2.parseFile(filePath)
    return root.xpathEval('/results/test-run')[0]

def GetParameter(node, propName):
    for property in node.properties:
        if property.type == 'attribute':
            if property.name == 'propName':
                return property.content
    return ""

PredefinedProcessor = {"QQQ": "MFLD", "AAAA": "CTP"}

def ValidateTargetProcessorType(node):
    processor = GetParameter(node, "TargetProcessor")
    if processor in PredefinedProcessor:
        node.setProp("TargetProcessor", PredefinedProcessor["processor"])

def CreateBenchamrkResultNode(performanceResultItem):
    node = libxml2.newNode('test')
    
    node.setProp("TestName", performanceResultItem[0])
    node.setProp("CompTime", "0")
    node.setProp("Reverse", "0")
    node.setProp("SysComment", "")
    if float(performanceResultItem[1]) > 0:
        node.setProp("Rate", str(performanceResultItem[1]))
        node.setProp("SysStatus", "1")
    else:
        node.setProp("Rate", str(0))
        node.setProp("SysStatus", "3")

    return node

def CreateTestsTag(performanceResults):
    root_node = libxml2.newNode("tests")
    
    for item in performanceResults:
        item_result_tag = CreateBenchamrkResultNode(item)
        root_node.addChild(item_result_tag)

    return root_node

def AppendRunTestTagAttributes(benchmarkParams, node):
    node.setProp("BeginTime", benchmarkParams["BeginTime"])
    node.setProp("EndTime", benchmarkParams["EndTime"])
    node.setProp("RunDate", benchmarkParams["RunDate"])
    node.setProp("TestGroup", benchmarkParams["Title"])
    node.setProp("Build", benchmarkParams["Build"])
    ValidateTargetProcessorType(node)

def WriteTraqReport(globalParams, performanceResults):
    report = libxml2.newNode('results')

    test_run_template_tag = OpenTraqTemplate(globalParams["TRAQTemplatePath"])
    for item in performanceResults:
        item["RunDate"] = globalParams["RunDate"]
        item["Build"] = globalParams["Build"]
        #item["BeginTime"] = globalParams["BeginTime"]
        #item["EndTime"] = globalParams["EndTime"]
        test_run_tag = test_run_template_tag.copyNodeList()
        
        AppendRunTestTagAttributes(item, test_run_tag)
        tests_tag = CreateTestsTag(item["results"])
        test_run_tag.addChild(tests_tag)
        report.addChild(test_run_tag)

    out_file = open(globalParams["results_dir"] + "traq_report.xml", "w")
    result_doc = libxml2.newDoc('1.0')
    result_doc.addChild(report)
    out_file.write(result_doc.serialize('UTF-8', 1))
    #print result_doc.serialize(None, 1)
    out_file.close()
    
def GetCurrentTimeForTRAQ():
    now = datetime.now()
    return now.strftime('%m/%d/%Y %I/%M/%S %p')

def ValidateTRAQDateTimeFormat(str):
    return True

if __name__ == "__main__":
    f = open('/tmp/traq_report_params', 'r')
    params = marshal.load(f)
    f.close()
    
    WriteTraqReport(params[0], params[1])

