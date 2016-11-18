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
    output = get_result()
    print_headers(output)
    print(output, "\n")


def print_headers(body):
    print("Content-type: application/json")
    print("Content-Length: ", str(len(body)))
    print()


def get_result():
    result = dict()
    r = get_status()
    hl = json.loads(r[0])
    sl = json.loads(r[1])
    hd = dictify(hl)
    sd = dictify(sl)
    result["hosts"] = hd
    result["services"] = sd
    output = json.dumps(result, indent=4, sort_keys=True)
    return output


def dictify(qlist):
    if not qlist or len(qlist) < 2:
        return None
    retval = dict()
    headers = qlist[0]
    dsize = len(headers)
    for idx, dlist in enumerate(qlist[1:]):
        pkey = dlist[0]
        if pkey not in retval:
            if dsize == 1:
                retval[pkey] = True
                continue
            elif dsize == 2:
                val = dlist[1]
                if headers[1] == "state":
                    val = statelookup(val, "host")
                retval[pkey] = val
                continue
            else:
                retval[pkey] = dict()
        kname = dlist[1]
        if dsize == 3:
            val = dlist[2]
            if headers[2] == "state":
                val = statelookup(val, "service")
            retval[pkey][kname] = val
        else:
            retval[pkey][kname] = dlist[2:]
    return retval


def statelookup(ditem, dtype):
    statemap = {0: {"host": "UP",
                    "service": "OK"},
                1: {"host": "DOWN",
                    "service": "WARNING"},
                2: {"host": "UNKNOWN", "service": "CRITICAL"},
                3: {"host": "UNKNOWN", "service": "UNKNOWN"}}
    return statemap[ditem][dtype]


def get_status(unixcat="/bin/unixcat",
               sock="/var/spool/nagios/cmd/nagios.live"):
    hosts = "GET hosts\nColumns: host_name state\nOutputFormat: json\n"
    hosts = hosts + "ColumnHeaders: on\n"
    svcs = "GET services\nColumns: host_name service_description state\n"
    svcs = svcs + "OutputFormat: json\nColumnHeaders: on\n"
    retval = []
    for item in [hosts, svcs]:
        p1 = subprocess.Popen(["echo", item], stdout=subprocess.PIPE)
        p2 = subprocess.Popen([unixcat, sock], stdin=p1.stdout,
                              stdout=subprocess.PIPE)
        p1.stdout.close()
        retval.append(p2.communicate()[0])
    return retval

if __name__ == "__main__":
    main()
