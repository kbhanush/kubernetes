FROM oraclelinux:7-slim

MAINTAINER oracle


# ==========================================
# Install from yum
RUN echo "Installing EPEL, python-pip, unzip, libaio, oci_cli, requests, cx_Oracle"  && \
    yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm && \
    yum -y install python-pip &&\
    yum -y install unzip && \
    yum -y install libaio && \ 
    yum -y install nodejs npm --enablerepo=epel && \
    yum -y install git && \
    yum -y install nano && \
    yum clean all && \
    rm -rf /var/cache/yum


# ==========================================
# Setup oracle instant client and sqlcl
ENV SQLPLUS oracle-instantclient12.2-sqlplus-12.2.0.1.0-1.x86_64.rpm
#ENV SQLCL sqlcl-18*.zip
ENV INSTANT_CLIENT oracle-instantclient12.2-basic-12.2.0.1.0-1.x86_64.rpm

WORKDIR /opt/oracle/lib
ADD ${INSTANT_CLIENT} ${SQLPLUS} ./
RUN echo "Installing instant client........" && \
   rpm -ivh ${INSTANT_CLIENT} && \
   echo "Installing SQL*Plus..........." && \
   rpm -ivh ${SQLPLUS} && \
   #unzip ${SQLCL} && \
   rm ${INSTANT_CLIENT} ${SQLPLUS} && \
   mkdir -p /opt/oracle/database/wallet && \
   mkdir -p /opt/oracle/tools/oci

#set env variables
ENV ORACLE_BASE /opt/oracle/lib/instantclient_12_2
ENV LD_LIBRARY_PATH /usr/lib/oracle/12.2/client64/lib/:$LD_LIBRARY_PATH
ENV TNS_ADMIN /opt/oracle/database/wallet/
ENV ORACLE_HOME /opt/oracle/lib/instantclient_12_2
ENV PATH $PATH:/usr/lib/oracle/12.2/client64/bin:/opt/oracle/lib/sqlcl/bin

# ==========================================
# install node app
WORKDIR /opt/oracle/tools/nodejs
RUN mkdir sdk apps
# Get the ATPConnectionTest node app
WORKDIR /opt/oracle/tools/nodejs/apps
RUN git clone https://github.com/kbhanush/ATPConnectionTest && \
    mv ATPConnectionTest/* . && \
    npm install oracledb && \
    rm -r ATPConnectionTest
EXPOSE 3050



# Uninstall packages
RUN echo "Cleaning up yum packages........................." && \
    yum -y remove unzip && \
    yum -y remove git
   
