FROM centos:7
MAINTAINER sqre-admin

USER root

RUN yum update -y && \
    yum install -y epel-release && \
    yum -y install nagios nagios-plugins-all && \
    yum clean -y all

RUN mkdir -p /var/log/nagios/spool/checkresults && \
    chmod -R 777 /var/log/nagios

#CMD ["/usr/sbin/nagios", "-v", "/etc/nagios/nagios.cfg"]
CMD mkdir -p /etc/nagios/private && touch /etc/nagios/private/resource.cfg && /usr/sbin/nagios -v /etc/nagios/nagios.cfg
