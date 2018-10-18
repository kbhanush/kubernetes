FROM oraclelinux:7-slim

RUN yum update -y && \
    yum-config-manager --enable ol7_developer_EPEL && \
    yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm openssl unzip docker-engine python36 gcc libffi-devel python-devel openssl-devel libaio --enablerepo=ol7_addons ol7_developer_EPEL



RUN yum install -y python-pip && \
    pip install oci-cli


# Setup oracle instant client & sqlplus
ENV SQLPLUS oracle-instantclient18.3-sqlplus-18.3.0.0.0-1.x86_64.rpm
ENV INSTANT_CLIENT oracle-instantclient18.3-basic-18.3.0.0.0-1.x86_64.rpm

WORKDIR /opt/oracle/lib
ADD ${INSTANT_CLIENT} ${SQLPLUS} ./
RUN rpm -ivh ./${INSTANT_CLIENT} && \
   rpm -ivh ./${SQLPLUS} && \
   rm ${INSTANT_CLIENT} ${SQLPLUS}


RUN mkdir -p /opt/oracle/tools/oci

ENV ORACLE_BASE /opt/oracle/lib/instantclient_18_3
ENV LD_LIBRARY_PATH /usr/lib/oracle/18.3/client64/lib/:$LD_LIBRARY_PATH
ENV TNS_ADMIN /opt/oracle/database/wallet/
ENV ORACLE_HOME /opt/oracle/lib/instantclient_18_3
ENV PATH $PATH:/usr/lib/oracle/18.3/client64/bin:/opt/oracle/lib/sqlcl/bin

# setup kubectl and oci-cli
WORKDIR /opt/oracle

RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl && \
    chmod +x ./kubectl && \
    mv ./kubectl /usr/local/bin/kubectl

RUN curl -LO https://download.docker.com/linux/centos/7/x86_64/stable/Packages/docker-ce-18.06.1.ce-3.el7.x86_64.rpm && \
    yum install ./docker-ce-18.06.1.ce-3.el7.x86_64.rpm -y && \
    rm ./docker-ce-18.06.1.ce-3.el7.x86_64.rpm && \
    yum clean all && \
    rm -rf /var/cache/yum


ADD create_schema.sql delete.sh deployApp.sh deployInfra.sh deployOracleDB.sh ./
ADD aOne-oow aOne-oow