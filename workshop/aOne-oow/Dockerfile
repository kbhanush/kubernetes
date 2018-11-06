FROM oraclelinux:7-slim

MAINTAINER oracle


# ==========================================
# Install from yum
RUN echo "Installing EPEL, python-pip, unzip, libaio, oci_cli, requests, cx_Oracle"  && \
    yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm && \
    yum -y install python-pip &&\
    yum -y install libaio && \ 
    yum -y install nodejs npm --enablerepo=epel && \
    yum clean all && \
    rm -rf /var/cache/yum


# ==========================================
# Setup oracle instant client
ENV INSTANT_CLIENT oracle-instantclient18.3-basic-18.3.0.0.0-1.x86_64.rpm

WORKDIR /opt/oracle/lib
ADD database/downloads/${INSTANT_CLIENT}  ./
RUN echo "Installing instant client........" && \
   rpm -ivh ${INSTANT_CLIENT} && \
   rm ${INSTANT_CLIENT} && \
   mkdir -p /opt/oracle/tools/oci

#set env variables
ENV ORACLE_BASE /opt/oracle/lib/instantclient_18_3
ENV LD_LIBRARY_PATH /usr/lib/oracle/18.3/client64/lib/:$LD_LIBRARY_PATH
ENV TNS_ADMIN /opt/oracle/database/wallet/
ENV ORACLE_HOME /opt/oracle/lib/instantclient_18_3
ENV PATH $PATH:/usr/lib/oracle/18.3/client64/bin:/opt/oracle/lib/sqlcl/bin

# ==========================================
# install node app
WORKDIR /opt/oracle
ADD . .
RUN npm install 
EXPOSE 8080


CMD [ "node", "server.js" ]
   
