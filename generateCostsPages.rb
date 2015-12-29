#!/usr/bin/env ruby
#coding: utf-8

require "json"
require "pp"

filename = "./data/ss.info.json"

ssInfoJson = File.read(filename)
ssInfo = JSON.parse(ssInfoJson)

# costs are in pence
# (G-cloud 7 costing Computer as a Service, 2015)
# "assured" / hour, not "elevated" / hour
# standard service level
# unoptimised storage
$costmodel = [
	{	"name" => "micro", "cost" => 4, "cpus" => 1, "ram" => 512, "disksize" => 10	},
	{	"name" => "tiny", "cost" => 13, "cpus" => 1, "ram" => 2048, "disksize" => 60	},
	{	"name" => "small", "cost" => 18, "cpus" => 2, "ram" => 4096, "disksize" => 60	},
	{	"name" => "medium", "cost" => 30, "cpus" => 4, "ram" => 8192, "disksize" => 60	},
	{	"name" => "medium_high_mem", "cost" => 43, "cpus" => 4, "ram" => 16384, "disksize" => 60	},
	{	"name" => "large", "cost" => 63, "cpus" => 8, "ram" => 16384, "disksize" => 60	},
	{	"name" => "large_high_mem", "cost" => 100, "cpus" => 8, "ram" => 32768, "disksize" => 60	},
	{	"name" => "t1apps_small", "cost" => 140, "cpus" => 8, "ram" => 49152, "disksize" => 60	},
	{	"name" => "t1apps_medium", "cost" => 180, "cpus" => 8, "ram" => 65536, "disksize" => 60	},
	{	"name" => "t1apps_large", "cost" => 255, "cpus" => 8, "ram" => 98304, "disksize" => 60	}
]
$diskCostGbPerMon = 20  # n.b. per month


class CostBucket
    def initialize(name)
        @name = name
        @children = []
        @cost_ph = 0
        @cost_pd = 0
        @cost_pw = 0
        @cost_pm = 0
        @cost_py = 0
        @disk_cost_ph = 0
        @disk_cost_pd = 0
        @disk_cost_pw = 0
        @disk_cost_pm = 0
        @disk_cost_py = 0
        @vm_cost_ph = 0
        @vm_cost_pd = 0
        @vm_cost_pw = 0
        @vm_cost_pm = 0
        @vm_cost_py = 0
        @cpus = 0
        @mem = 0
        @diskSize = 0
    end

    def setName(name)
        @name = name
    end
    def getName
        @name
    end
    def getCleanedName
        @name.tr("()","").tr(". ","_")
    end
    def getChildren
        @children
    end
    def setCostPerHour(cost)
        @cost_ph = cost.to_i
    end
    def getCostPerHour
        @cost_ph
    end
    def setCostPerDay(cost)
        @cost_pd = cost.to_i
    end
    def getCostPerDay
        @cost_pd
    end
    def setCostPerWeek(cost)
        @cost_pw = cost.to_i
    end
    def getCostPerWeek
        @cost_pw
    end
    def setCostPerMonth(cost)
        @cost_pm = cost.to_i
    end
    def getCostPerMonth
        @cost_pm
    end
    def setCostPerYear(cost)
        @cost_py = cost.to_i
    end
    def getCostPerYear
        @cost_py
    end
    def setDiskCostPerHour(cost)
        @disk_cost_ph = cost.to_i
    end
    def getDiskCostPerHour
        @disk_cost_ph
    end
    def setDiskCostPerDay(cost)
        @disk_cost_pd = cost.to_i
    end
    def getDiskCostPerDay
        @disk_cost_pd
    end
    def setDiskCostPerWeek(cost)
        @disk_cost_pw = cost.to_i
    end
    def getDiskCostPerWeek
        @disk_cost_pw
    end
    def setDiskCostPerMonth(cost)
        if(cost<0) then
            @disk_cost_pm = 0
        else
            @disk_cost_pm = cost.to_i
        end
    end
    def getDiskCostPerMonth
        @disk_cost_pm
    end
    def setDiskCostPerYear(cost)
        @disk_cost_py = cost.to_i
    end
    def getDiskCostPerYear
        @disk_cost_py
    end
    def setVMCostPerHour(cost)
        @vm_cost_ph = cost.to_i
    end
    def getVMCostPerHour
        @vm_cost_ph
    end
    def setVMCostPerDay(cost)
        @vm_cost_pd = cost.to_i
    end
    def getVMCostPerDay
        @vm_cost_pd
    end
    def setVMCostPerWeek(cost)
        @vm_cost_pw = cost.to_i
    end
    def getVMCostPerWeek
        @vm_cost_pw
    end
    def setVMCostPerMonth(cost)
        @vm_cost_pm = cost.to_i
    end
    def getVMCostPerMonth
        @vm_cost_pm
    end
    def setVMCostPerYear(cost)
        @vm_cost_py = cost.to_i
    end
    def getVMCostPerYear
        @vm_cost_py
    end
    def addChild(item)
        @children.push(item)
    end
    def getCpus
        @cpus
    end
    def setCpus(num)
        @cpus = num
    end
    def getMem
        @mem
    end
    def setMem(num)
        @mem = num
    end
    def getDiskSize
        @diskSize
    end
    def setDiskSize(num)
        @diskSize = num
    end
    def calculateCost    
        @children.each do |child|
            child.calculateCost
            self.setDiskSize(self.getDiskSize + child.getDiskSize)
            self.setCpus(self.getCpus + child.getCpus)
            self.setMem(self.getMem + child.getMem)
            self.setDiskCostPerHour(self.getDiskCostPerHour + child.getDiskCostPerHour)
            self.setDiskCostPerDay(self.getDiskCostPerDay + child.getDiskCostPerDay)
            self.setDiskCostPerWeek(self.getDiskCostPerWeek + child.getDiskCostPerWeek)
            self.setDiskCostPerMonth(self.getDiskCostPerMonth + child.getDiskCostPerMonth)
            self.setDiskCostPerYear(self.getDiskCostPerYear + child.getDiskCostPerYear)
            self.setVMCostPerHour(self.getVMCostPerHour + child.getVMCostPerHour)
            self.setVMCostPerDay(self.getVMCostPerDay + child.getVMCostPerDay)
            self.setVMCostPerWeek(self.getVMCostPerWeek + child.getVMCostPerWeek)
            self.setVMCostPerMonth(self.getVMCostPerMonth + child.getVMCostPerMonth)
            self.setVMCostPerYear(self.getVMCostPerYear + child.getVMCostPerYear)
        end
        self.setCostPerHour(self.getDiskCostPerHour + self.getVMCostPerHour)
        self.setCostPerDay(self.getDiskCostPerDay + self.getVMCostPerDay)
        self.setCostPerWeek(self.getDiskCostPerWeek + self.getVMCostPerWeek)
        self.setCostPerMonth(self.getDiskCostPerMonth + self.getVMCostPerMonth)
        self.setCostPerYear(self.getDiskCostPerYear + self.getVMCostPerYear)
    end
    def toHash
        hash_self = {
                    "name" => self.getName,
                    "vm_cost_ph" => self.getVMCostPerHour,
                    "vm_cost_pd" => self.getVMCostPerDay,
                    "vm_cost_pw" => self.getVMCostPerWeek,
                    "vm_cost_pm" => self.getVMCostPerMonth,
                    "vm_cost_py" => self.getVMCostPerYear,
                    "disk_cost_ph" => self.getDiskCostPerHour,
                    "disk_cost_pd" => self.getDiskCostPerDay,
                    "disk_cost_pw" => self.getDiskCostPerWeek,
                    "disk_cost_pm" => self.getDiskCostPerMonth,
                    "disk_cost_py" => self.getDiskCostPerYear,
                    "cost_ph" => self.getCostPerHour,
                    "cost_pd" => self.getCostPerDay,
                    "cost_pw" => self.getCostPerWeek,
                    "cost_pm" => self.getCostPerMonth,
                    "cost_py" => self.getCostPerYear,
                    "children" => []
                    }
        @children.each do |child|
            hash_self["children"].push(child.toHash)
        end
        return hash_self
    end
            
end

class VM < CostBucket

    def initialize(name)
        @diskCount = 0
        @status = "unknown"
        @vmType = "unknown"
        super
    end

    def getStatus
        @status
    end
    def setStatus(stat)
        @status = stat
    end
    def getVMType
        @vmType
    end
    def setVMType(type)
        @vmType=type
    end
    def getDiskCount
        @diskCount
    end
    def setDiskCount(num)
        @diskCount = num
    end
    def calculateCost
        if(self.getStatus == "on") then
            thisCostModel = ""
            $costmodel.each do |vmtype|
                thisCostModel = vmtype
                if(self.getCpus <= vmtype["cpus"].to_i && self.getMem <= vmtype["ram"].to_i ) then 
                    self.setVMType(vmtype["name"])
                    break
                end
                self.setVMCostPerHour(thisCostModel["cost"])
            end
            if(self.getDiskCount.to_i > 1) then
                self.setDiskCostPerMonth(((self.getDiskSize - thisCostModel["disksize"])*$diskCostGbPerMon)/1024)
            else
                self.setDiskCostPerMonth(0)
            end
        end

        self.setDiskCostPerYear(self.getDiskCostPerMonth * 12 )
        self.setDiskCostPerDay(self.getDiskCostPerYear / 365)
        self.setDiskCostPerHour(self.getDiskCostPerDay / 24)
        self.setDiskCostPerWeek(self.getDiskCostPerDay * 7)

        self.setVMCostPerDay(self.getVMCostPerHour * 24)
        self.setVMCostPerWeek(self.getVMCostPerDay * 7)
        self.setVMCostPerYear(self.getVMCostPerDay * 365)
        self.setVMCostPerMonth(self.getVMCostPerYear / 12)

        self.setCostPerHour(self.getDiskCostPerHour + self.getVMCostPerHour)
        self.setCostPerDay(self.getDiskCostPerDay + self.getVMCostPerDay)
        self.setCostPerWeek(self.getDiskCostPerWeek + self.getVMCostPerWeek)
        self.setCostPerMonth(self.getDiskCostPerMonth + self.getVMCostPerMonth)
        self.setCostPerYear(self.getDiskCostPerYear + self.getVMCostPerYear)

    end
    def toHash
        hash_self = {
                    "name" => self.getName,
                    "vm_cost_ph" => self.getVMCostPerHour,
                    "vm_cost_pd" => self.getVMCostPerDay,
                    "vm_cost_pw" => self.getVMCostPerWeek,
                    "vm_cost_pm" => self.getVMCostPerMonth,
                    "vm_cost_py" => self.getVMCostPerYear,
                    "disk_cost_ph" => self.getDiskCostPerHour,
                    "disk_cost_pd" => self.getDiskCostPerDay,
                    "disk_cost_pw" => self.getDiskCostPerWeek,
                    "disk_cost_pm" => self.getDiskCostPerMonth,
                    "disk_cost_py" => self.getDiskCostPerYear,
                    "cost_ph" => self.getCostPerHour,
                    "cost_pd" => self.getCostPerDay,
                    "cost_pw" => self.getCostPerWeek,
                    "cost_pm" => self.getCostPerMonth,
                    "cost_py" => self.getCostPerYear,
                    "vmtype" => self.getVMType,
                    "status" => self.getStatus
                    }
        return hash_self
    end
end



bigBucket = CostBucket.new("environments")
ssInfo.each do |acc|
    acc.each do |accName,vdcs|
        thisAccount = CostBucket.new(accName)
        vdcs.each do |vdcName,vdc|
            thisVdc = CostBucket.new(vdcName)
            vdc["vapps"].each do |vappName,vapp|
                thisVapp = CostBucket.new(vappName)
                vapp["vms"].each do |vmName,vm|
                    thisVm = VM.new(vmName)
                    if(vm["textStatus"] == "POWERED_ON") then
                        thisVm.setStatus("on")
                    else
                        thisVm.setStatus("off")
                    end
                    thisVm.setCpus(vm["ncpus"].to_i)
                    thisVm.setMem(vm["memMb"].to_i)
                    vm["disks"].each do |disk|
                        thisVm.setDiskCount(thisVm.getDiskCount + 1)
                        thisVm.setDiskSize(thisVm.getDiskSize + disk["size"])
                    end
                    thisVapp.addChild(thisVm)
                end
                thisVdc.addChild(thisVapp)
            end
            thisAccount.addChild(thisVdc)
        end
        bigBucket.addChild(thisAccount)
    end
end

bigBucket.calculateCost()




htmlStr = "<!DOCTYPE html>" +
          "<meta charset=\"ISO-8859-1\">" + 
          "<!-- charset=\"utf-8\"> -->" +
          "<head><link rel=\"stylesheet\" type=\"text/css\" href=\"style/cost.css\"/></head>"

htmlStr = htmlStr + "<body>" +
        "<table id=\"environmentCosts\">
<tr class=\"title\"><th>Account</th><th>VDC name</th><th>Vapp name</th><th>VM name</th><th>State</th><th>CPU</th><th>Mem</th><th>Disks#</th><th>Disk size</th><th>Disk Cost/month</th><th>VM/month</th><th>Cost/month</th></tr>"

bigBucket.getChildren.each { |account|

    htmlStr = htmlStr + "<tr class=\"account childrenClosed \" id=\"account-" + account.getCleanedName + "\">" +
            "<td colspan=\"5\" id=\"" + account.getCleanedName + "\">" + account.getName + "</td>" +
            "<td/>" +
            "<td/>" +
            "<td/>" +
            "<td/>" +
            "<td>&pound;" + (account.getDiskCostPerMonth/100).to_s + "</td>" + 
            "<td>&pound;" + (account.getVMCostPerMonth/100).to_s + "</td>" + 
            "<td>&pound;" + (account.getCostPerMonth/100).to_s + "</td>" + 
            "</tr>\n"
    account.getChildren.each { |vdc|

            htmlStr = htmlStr + "<tr class=\"vdc notshown childrenClosed account-" + account.getCleanedName + "\" id=\"vdc-" + vdc.getCleanedName + "\">" + 
                "<td/>" +
                "<td colspan=\"3\" id=\"" + vdc.getCleanedName + "\">" + vdc.getName + "</td>\n" +
    			"<td/>" + 
    			"<td/>" +
    			"<td/>" +
    			"<td />" +
    			"<td />" +
                "<td>&pound;" + (vdc.getDiskCostPerMonth/100).to_s + "</td>" + 
                "<td>&pound;" + (vdc.getVMCostPerMonth/100).to_s + "</td>" + 
                "<td>&pound;" + (vdc.getCostPerMonth/100).to_s + "</td>" + 
                "</tr>\n"

        vdc.getChildren.each{ |vapp|
                
                htmlStr = htmlStr + "<tr class=\"vapp notshown childrenClosed account-" + account.getCleanedName + " vdc-" + vdc.getCleanedName + "\" id=\"vapp-" + vapp.getCleanedName + "\">" + 
                "<td/>" + "<td/>" + 
                "<td colspan=\"3\" id=\"" + vapp.getCleanedName + "\">" + vapp.getName + "</td>\n" +
    			"<td/>" + "<td/>" + "<td/>" + "<td/>" +
                "<td/>&pound;" + (vapp.getDiskCostPerMonth/100).to_s + "</td>" + 
                "<td/>&pound;" + (vapp.getVMCostPerMonth/100).to_s + "</td>" + 
                "<td/>&pound;" + (vapp.getCostPerMonth/100).to_s + "</td>" + 
                "</tr>\n"

		        lineCount=1
		        vapp.getChildren.each { |vm|
			        if(lineCount % 2 == 1) then 
				        rowClass="odd"
			        else
				        rowClass="even"
			        end
                    vmClass="unknown"
			        if(vm.getStatus == "off") then
				        vmClass="vmoff"
			        else
				        vmClass="vmon"
			        end

			        htmlStr = htmlStr + "<tr class=\"vm notshown vapp-" + vapp.getCleanedName + " vdc-" + vdc.getCleanedName + " account-" + account.getCleanedName + " " + rowClass + " " + vmClass + "\">" +
    					"<td/>\n" + "<td/>\n" + "<td/>\n" +
    					"<td/>" + vm.getName + "</td>\n" +
    					"<td/>" + vm.getStatus + "</td>\n" +
    					"<td/>" + vm.getCpus.to_s + "</td>\n" +
    					"<td/>" + vm.getMem.to_s + "</td>\n" +
    					"<td/>" + vm.getDiskCount.to_s + "</td>\n" +
    					"<td/>" + vm.getDiskSize.to_s + "</td>\n" +
    					"<td/>&pound;" + (vm.getDiskCostPerMonth/100).to_s + "</th>\n" +
    					"<td/>&pound;" + (vm.getVMCostPerMonth/100).to_s + "</th>\n" +
    					"<td/>&pound;" + (vm.getCostPerMonth/100).to_s + "</th>\n" +
                        "</tr>"
                    lineCount = lineCount + 1
                }
        }

    }
}
    
htmlStr = htmlStr + "<tr class=\"total\">" + 
    "<td colspan=9>TOTAL</td>" +
    "<td>&pound;" + (bigBucket.getDiskCostPerMonth/100).to_s + "</td>" + 
    "<td>&pound;" + (bigBucket.getVMCostPerMonth/100).to_s + "</td>" + 
    "<td>&pound;" + (bigBucket.getCostPerMonth/100).to_s + "</td>" + 
    "</tr>\n"


htmlStr=htmlStr + "</table>"




htmlStr=htmlStr + "
<script src=\"./jslib/d3.v3.min.js\"> </script>
<script src=\"./jslib/jquery-latest.min.js\"></script>
<script src=\"./jslib/costcircles.js\"></script>
<script>
  $(function() {
    $('tr').click(function() {
      if($(this).hasClass(\"childrenOpen\")) {
          $(this).removeClass(\"childrenOpen\").addClass(\"childrenClosed\");
          unshownChildRows=$(\"tr.notshown.\" + $(this).attr('id'));
          shownChildRows=$(\"tr.shown.\" + $(this).attr('id'));
          shownChildRows.removeClass(\"shown\").addClass(\"notshown\").addClass(\"childrenOpen\");
          unshownChildRows.addClass(\"childrenOpen\");
      } else {
          $(this).removeClass(\"childrenClosed\").addClass(\"childrenOpen\");
          unshownChildRows=$(\"tr.notshown.\" + $(this).attr('id'));
          shownChildRows=$(\"tr.shown.\" + $(this).attr('id'));
          unshownChildRows.removeClass(\"notshown\").addClass(\"shown\").addClass(\"childrenOpen\");
          shownChildRows.addClass(\"childrenOpen\");
      }
    });
  });
</script>
"
htmlStr=htmlStr + "</body></html>\n"

File.open("./web/cost.html", 'w'){ |file| file.write(htmlStr)}
File.open("./web/ss.costcircles.json", 'w'){ |file| file.write(bigBucket.toHash.to_json)}



exit 0
