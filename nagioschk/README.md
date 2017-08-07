nagios pre-flight configuration check
===

From the rootdir of this repo:

    make check

or

    (cd nagioschk && make)
    docker run -ti --privileged -v $(pwd)/nagios:/etc/nagios nagioschk
