#!/usr/bin/env python

from __future__ import print_function
import json
import subprocess
import cgi
import cgitb

def main():
    cgitb.enable()
    application()

def application():
    output=get_result()
    print_headers(output)
    print(output,"\n")
    
def print_headers(body):
    print("Content-type: application/json")
    print("Content-Length: ",str(len(body)))
    print()

def get_result():
    result = dict()
    r=get_status(unixcat="/bin/unixcat")
    result["hosts"]=json.loads(r[0])
    result["services"]=json.loads(r[1])
    output=json.dumps(result,indent=4,sort_keys=True)
    return output

def get_status(unixcat="/usr/local/bin/unixcat-nagios",
               sock="/var/spool/nagios/cmd/nagios.live"):
    hosts="GET hosts\nOutputFormat: json"
    svcs="GET services\nOutputFormat: json"
    retval = []
    for item in [ hosts, svcs ]:
        p1=subprocess.Popen(["echo",item],stdout=subprocess.PIPE)
        p2=subprocess.Popen([unixcat,sock],stdin=p1.stdout,
                            stdout=subprocess.PIPE)
        p1.stdout.close()
        retval.append(p2.communicate()[0])
    return retval

if __name__ == "__main__":
    main()
