import os
import sys
import json
import time
import subprocess
from ipaddress import ip_network, ip_address
import argparse

version = '1.2.4'

dnIp	= {
	"domains": [
			"xxxx"
	],
	"ipRange": [xxxx
		
	]
}

# Check specified "program" is in PATH and is executable
def which(program):
	
	def is_exe(fpath):
		return os.path.isfile(fpath) and os.access(fpath, os.X_OK)
	
	# Fix program for Windows platforms
	if sys.platform == "win32" and not program.endswith(".exe"): program += ".exe"
	fpath, fname = os.path.split(program)
	if fpath:
		if is_exe(program):
			return program
	else:
		for path in os.environ["PATH"].split(os.pathsep):
			exe_file = os.path.join(path, program)
			#print(exe_file)
			if is_exe(exe_file):
				return exe_file
	
	return None

#print(which('tshark'))
#quit()

# Create cmdline options
parser = argparse.ArgumentParser()
parser.add_argument("-cap", help="Use tshark to capture packets",action="store_true")
#parser.add_argument("-file", type=ascii, help="Name of the pcap or json file to analyze")
parser.add_argument("-scap", help="Save tshark capture json",action="store_true")
parser.add_argument("-dnfile", help="The json formatted ip/domain name file to use for validation. Default is:\n" +str(dnIp), default='' )
parser.add_argument("-filter", help="tshark capture filter to use", default='')
parser.add_argument("-delay", type=int, help="Wait N Seconds then start capture, Default is 0 seconds", default=0)
parser.add_argument("-pcount", type=int, help="Capture this many packets then stop and analyze them. -cap required, Default is 4000", default=4000)
parser.add_argument("-ver", help="Show current version of PAT and exit",action="store_true")
parser.add_argument("file", help="Absolute path to save or load capture file")
args = parser.parse_args()

if args.ver:
	print('Ver:',version)
	quit()

# Read the dnIp file if one was given
try:
	if args.dnfile != '':
		del dnIp
		with open(args.dnfile) as json_file: 
			dnIp = json.load(json_file)
except Exception as e:
	print('Reading the dnfile failed:',e)
	quit()

# We got a valid json file but was it really a dnIp file??
if 'ipRange' not in dnIp:
	print("Invalid domain name file. ipRange missing. File must contain both domains and ip ranges. Aborting ...")
	quit()

#net = ip_network("xxxx")
#print(ip_address("xxxx") in net)
#quit()


#print(dnIp['ipRange'])
#quit()
try:
	# Make sure tshark is in PATH
	if which('tshark') == None:
		print("This program relies on tshark. It must be installed on your system and must be \npresent in the PATH environment variable. Please correct this and try again!")
	
	file = args.file
	#print('FILE: ',file)
	
	# Show file name without extension
	#if file.lower().endswith(('.json', '.pcap', '.pcapng')):
	#	print(os.path.splitext(file)[0])
	#quit()
	
	start_time = time.time()
	
	# Should be run a packet capture?
	if args.cap:
		# Ensure we can see tshark
		
		# We need to run tshark to capture packets to analyze
		
		# Just in case the user provides and extension, we remove it.
		if file.lower().endswith(('.json', '.pcap', '.pcapng')):
			file = os.path.splitext(file)[0]
		
		# Wait for delay seconds	
		if args.delay > 0:
			time.sleep(args.delay)
		
		# Create argument list
		arglist = ["tshark", "-w", file, "-T", "json", "-a", 'packets:' + str(args.pcount)]
		if args.filter != "":
			arglist.append("-f", args.filter)
		print('tshark ARGLIST: ', arglist)
		
		# Start capture
		process = subprocess.run(arglist, check=True, stdout=subprocess.PIPE, universal_newlines=True)
		capraw = process.stdout
		
		# Save capture json file
		if args.scap:
			fh = open(file + '.json', 'w')
			fh.write(capraw)
			fh.close()
	#quit()
	
	# First read the NetworkEnvironmentProduction.json file to get the URL we're looking for
	#nepraw = open('c:/python/data/NetworkEnvironmentProduction.json', 'r').read()
	#print(nepraw)
	
	# extract out the data for the platform we're testing
	#nep = json.loads(nepraw)
	#neppretty = json.dumps(nep, indent=4)
	#print(neppretty)
	
	#quit()
	
	# If we're not running a capture then the user has provided a capture file to analyze
	if not args.cap:
		if 'pcap' in file:
			# Get json from tshark: tshark -r c:/python/data/SessionTrace.pcapng -T json > ST2.json
			print( "Converting input file '" + file + "' to json ...", flush=True)
			process = subprocess.run(["tshark", "-r", file, "-T", "json"], check=True, stdout=subprocess.PIPE, universal_newlines=True)
			capraw = process.stdout
		else:
			capraw = open(file, 'r').read()
	#print(nepraw)
	
	# Show time it took
	end_time = time.time()
	print( "    File load/conversion time: ", end_time-start_time, flush=True)
	#quit()
	
	# Extract out the data for the platform we're testing
	packets = json.loads(capraw)
	
	#print(len(packets))
	
	#print( nep[0],"\n" )
	#quit()
	cnt		= 1
	scnt	= 0
	ecnt	= 0
	for frame in packets:
		fs = json.dumps(frame['_source']['layers'], indent=4)
		if True or 'sip' in fs or '_turn.' in fs:
			if 'dns' in frame['_source']['layers'].keys():
				if 'Answers' in frame['_source']['layers']['dns'].keys():
					#print("\n",frame['_source']['layers']['frame']['frame.number'],json.dumps(frame['_source']['layers'], indent=4), flush=True)
					for ans in frame['_source']['layers']['dns']['Answers'].keys():
						if 'intouch' in ans:
							error = False
							#print( "....................................................................... HAS ANSWERS", flush=True)
							print(cnt,ans)
							# We need to look at the domain name and the IP address
							# DN
							#frame['_source']['layers']['dns']['Answers'][answer]['dns.resp.name']
							# IP
							#frame['_source']['layers']['dns']['Answers'][answer]['dns.a']
							#print(frame['_source']['layers']['dns']['Answers'])
							
							if 'dns.srv.service' in frame['_source']['layers']['dns']['Answers'][ans].keys():
								dn = frame['_source']['layers']['dns']['Answers'][ans]['dns.srv.name']
								ip = frame['_source']['layers']['dns']['Answers'][ans]['dns.srv.target']
							else:
								uparts	= frame['_source']['layers']['dns']['Answers'][ans]['dns.resp.name'].split(".")
								dn		= uparts[len(uparts)-2] + '.' + uparts[len(uparts)-1]
								if 'dns.a' in frame['_source']['layers']['dns']['Answers'][ans]:
									ip		= frame['_source']['layers']['dns']['Answers'][ans]['dns.a']
								else:
									ip		= frame['_source']['layers']['dns']['Answers'][ans]['dns.aaaa']
								
								# We should also look forr IPV6 here:
								# "dns.aaaa": "xxxx"
							
							# Need to constrain this a bit by looking at the ipRange stuff
							found = False
							for ipSpec in dnIp['ipRange']:
								net = ip_network(ipSpec)
								if ip_address(ip) in net:
									found = True
									break
							
							#print(dn)
							
							# Check for a bad domain
							badDomain = False
							if dn not in dnIp['domains'] and found:
								print('    --> ERROR!!! Packet #' + str(cnt) + ' includes a domain (' + dn + ') that is not included in the list of official intouch domain names!')
								badDomain = True
								error = True
								ecnt =+ 1
							
							# If we had a bad IP for a valid domain
							if dn in dnIp['domains'] and not found:
								print('    --> ERROR!!! Packet #' + str(cnt) + ' IP address ' + ip + ' is not a valid IP')
								error = True
								ecnt =+ 1
							
							# If no errors
							if not error:
								print('    --> OK')
							#if scnt == 6: quit()
							scnt += 1
				
		cnt += 1
		#quit()
	
	# Announce results
	print(cnt - 1, "packets in file,", scnt, "packets include xxxx URLs and/or IP addresses,", ecnt, 'errors found')

except Exception as e:
	
	print(e)
	exc_type, exc_value, exc_traceback = sys.exc_info()
	print("*** print_tb:")
	traceback.print_tb(exc_traceback, limit=1, file=sys.stdout)
	quit()
	
quit()	