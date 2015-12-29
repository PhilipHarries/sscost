#!/usr/bin/env ruby

require "json"
require "psych"

accountsArray = []

ARGV.each do |arg|
    accountName=arg
    filename1 = "./data/#{accountName}_vcloud-query.vm.yaml"
    filename2 = "./data/#{accountName}_vcloud-walk.vdcs.json"
    vmInfo = Psych.load_file(filename1)
    vdcsFileContents = File.read(filename2)
    vdcsInfo = JSON.parse(vdcsFileContents)
    vdcsHash = Hash.new()
    tempVdcsHash = Hash.new()
    vmInfo.each do |vm|
    	thisVmHash = Hash.new()
    	thisVappName = vm[:containerName]
    	if(!tempVdcsHash.has_key?(thisVappName)) then
    		tempVdcsHash[thisVappName] = Hash.new()
    		tempVdcsHash[thisVappName]["vms"] = Array.new()
    	end
    	thisVmHash["name"] = vm[:name]
    	thisVmHash["id"] = vm[:href].sub("https://api.vcd.portal.skyscapecloud.com/api/vApp/","")
    	thisVmHash["network_name"] = vm[:networkName]
    	thisVmHash["status"] = vm[:status]
    	thisVmHash["storage profile"] = vm[:storageProfileName]
    	thisVmHash["cpus"] = vm[:numberOfCpus]
    	thisVmHash["memMb"] = vm[:memoryMB]
    	thisVmHash["inMaintenance"] = vm[:isInMaintenanceMode]
    	thisVmHash["isBusy"] = vm[:isBusy]
    	thisVmHash["os"] = vm[:guestOs]
    	tempVdcsHash[thisVappName]["vms"].push(thisVmHash)
    end
    vdcsInfo.each do |vdc|
    	vdcsHash[vdc["name"]] = Hash.new()
    	vdcsHash[vdc["name"]]["id"] = vdc["id"]
    	vdcsHash[vdc["name"]]["quotas"] = { "network" => vdc["quotas"]["network"], "nic" => vdc["quotas"]["nic"], "vm" => vdc["quotas"]["vm"] }
    	vdcsHash[vdc["name"]]["capacity"] = { 
    		"memory" => {
    				"allocated" => vdc["compute_capacity"]["Memory"]["Allocated"],
    				"limit" => vdc["compute_capacity"]["Memory"]["Limit"],
    				"reserved" => vdc["compute_capacity"]["Memory"]["Reserved"], 
    				"used" => vdc["compute_capacity"]["Memory"]["Used"],
    				"overhead" => vdc["compute_capacity"]["Memory"]["Overhead"]
    					},
    		"cpu" => {
    				"allocated" => vdc["compute_capacity"]["Cpu"]["Allocated"],
    				"limit" => vdc["compute_capacity"]["Cpu"]["Limit"],
    				"reserved" => vdc["compute_capacity"]["Cpu"]["Reserved"], 
    				"used" => vdc["compute_capacity"]["Cpu"]["Used"],
    				"overhead" => vdc["compute_capacity"]["Cpu"]["Overhead"]
    					} 
    		}
    	
    	vdcsHash[vdc["name"]]["vapps"] = Hash.new()
    	if (vdc["vapps"].length != 0) then
    		vdc["vapps"].each do |vapp|
    			vdcsHash[vdc["name"]]["vapps"][vapp["name"]] = Hash.new()
    			vdcsHash[vdc["name"]]["vapps"][vapp["name"]]["networks"] = Hash.new()
    			vdcsHash[vdc["name"]]["vapps"][vapp["name"]]["vms"] = Hash.new()
    			vdcsHash[vdc["name"]]["vapps"][vapp["name"]]["id"] = vapp["id"]
    			if(vapp["description"].nil?) then 
    				thisDescription = ""
    			else
    				thisDescription = vapp["description"].gsub(/\n/m, "  -  ").gsub(/\|/m,":").gsub(/"/m," ")
    			end
    			vdcsHash[vdc["name"]]["vapps"][vapp["name"]]["description"] = thisDescription
    			vapp["network_config"].each do |netconf|
    				vdcsHash[vdc["name"]]["vapps"][vapp["name"]]["networks"][netconf["network_name"]] = Hash.new()
    				vdcsHash[vdc["name"]]["vapps"][vapp["name"]]["networks"][netconf["network_name"]]["deployed?"] = netconf["is_deployed"]
    				if(netconf["config"]["ipscopes"]["IpScope"].has_key?("IpRanges")) then
    					vdcsHash[vdc["name"]]["vapps"][vapp["name"]]["networks"][netconf["network_name"]]["startIp"] = netconf["config"]["ipscopes"]["IpScope"]["IpRanges"]["IpRange"]["StartAddress"]
    					vdcsHash[vdc["name"]]["vapps"][vapp["name"]]["networks"][netconf["network_name"]]["endIp"] = netconf["config"]["ipscopes"]["IpScope"]["IpRanges"]["IpRange"]["EndAddress"]
    				end
    			end
    			vapp["vms"].each do |vm|
    				vmKey = vm["id"]
    				matchFound = false
    				ourVm = ""
    				tempVdcsHash[vapp["name"]]["vms"].each do |aVm|
    					if(aVm["id"] == vm["id"]) then
    						vmKey = aVm["name"]
    						ourVm = aVm
    						matchFound = true
    					end
    				end
    				vdcsHash[vdc["name"]]["vapps"][vapp["name"]]["vms"][vmKey] = Hash.new()
    				vdcsHash[vdc["name"]]["vapps"][vapp["name"]]["vms"][vmKey]["disks"] = Array.new()
    				vdcsHash[vdc["name"]]["vapps"][vapp["name"]]["vms"][vmKey]["network"] = Hash.new()
    				vdcsHash[vdc["name"]]["vapps"][vapp["name"]]["vms"][vmKey]["network"]["cards"] = Array.new()
    				if(!matchFound) then
    					puts "No match found for " + vm["id"] + ", using id as key instead of name"
    				else
    					vdcsHash[vdc["name"]]["vapps"][vapp["name"]]["vms"][vmKey]["memMb"] = ourVm["memMb"]
    					vdcsHash[vdc["name"]]["vapps"][vapp["name"]]["vms"][vmKey]["ncpus"] = ourVm["cpus"]
    					vdcsHash[vdc["name"]]["vapps"][vapp["name"]]["vms"][vmKey]["textStatus"] = ourVm["status"]
    					vdcsHash[vdc["name"]]["vapps"][vapp["name"]]["vms"][vmKey]["network"]["networkName"] = ourVm["network_name"]
    					vdcsHash[vdc["name"]]["vapps"][vapp["name"]]["vms"][vmKey]["inMaintenance"] = ourVm["inMaintenance"]
    					vdcsHash[vdc["name"]]["vapps"][vapp["name"]]["vms"][vmKey]["isBusy"] = ourVm["isBusy"]
    					
    				end
    				vdcsHash[vdc["name"]]["vapps"][vapp["name"]]["vms"][vmKey]["status"] = vm["status"]
    				vdcsHash[vdc["name"]]["vapps"][vapp["name"]]["vms"][vmKey]["os"] = vm["operating_system"]
    				vdcsHash[vdc["name"]]["vapps"][vapp["name"]]["vms"][vmKey]["cpus"] = vm["cpu"]
    				vdcsHash[vdc["name"]]["vapps"][vapp["name"]]["vms"][vmKey]["mem"] = vm["memory"]
    				vdcsHash[vdc["name"]]["vapps"][vapp["name"]]["vms"][vmKey]["storage_profile_name"] = vm["storage_profile"]["name"]
    				vdcsHash[vdc["name"]]["vapps"][vapp["name"]]["vms"][vmKey]["storage_profile_id"] = vm["storage_profile"]["id"]
    				vm["disks"].each do |disk|
    					vdcsHash[vdc["name"]]["vapps"][vapp["name"]]["vms"][vmKey]["disks"].push({"name"=>disk["name"],"size"=>disk["size"] })
    				end
    				vm["network_cards"].each do |netcard|
    					vdcsHash[vdc["name"]]["vapps"][vapp["name"]]["vms"][vmKey]["network"]["cards"].push({"name"=>netcard["name"],"type"=>netcard["type"],"mac"=>netcard["mac_address"]})
    				end
    				vdcsHash[vdc["name"]]["vapps"][vapp["name"]]["vms"][vmKey]["network"]["connections"] = Array.new()
    				if(vm["network_connections"].kind_of?(Array))
    					vm["network_connections"].each do |vmnetwork|
    						ipAddr=""
    						if(vmnetwork["IpAddress"].nil?) then
    						else
    							ipAddr=vmnetwork["IpAddress"]
    						end
    						vdcsHash[vdc["name"]]["vapps"][vapp["name"]]["vms"][vmKey]["network"]["connections"].push({"ipaddr"=>ipAddr,"isConnected"=>vmnetwork["IsConnected"],"mac"=>vmnetwork["MACAddress"]})
    					end
    				else
    					if(!vm["network_connections"].nil?) then
        					if(!vm["network_connections"]["IpAddress"].nil?) then
         						ipAddr=vm["network_connections"]["IpAddress"]
                            else
                                ipAddr=""
    					    end
                        else
                            ipAddr=""
                            isConnected=""
                            mac=""
                        end
    					vdcsHash[vdc["name"]]["vapps"][vapp["name"]]["vms"][vmKey]["network"]["connections"].push({"ipaddr"=>ipAddr,"isConnected"=>isConnected,"mac"=>mac})
    				end
    			end
    			
    		end
    	end
    end
    accountHash={accountName => vdcsHash}
    accountsArray.push(accountHash)
end

File.open("./data/ss.info.json", 'w'){ |file| file.write(accountsArray.to_json)}

exit 0
