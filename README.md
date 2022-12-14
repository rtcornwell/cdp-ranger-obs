# Ranger Plugin for OBS Installation and Integration Instructions

Overview of Ranger plugin for OBS service on open Telekom Cloud

![image](https://user-images.githubusercontent.com/16845371/193598831-b8431450-0f09-462c-b477-604cc02d6452.png)

**ranger-obs-plugin:** Provides a service definition plugin on the Ranger server. It provides OBS service permission control on the Ranger side; After the plug-in is deployed, users can fill in the appropriate permissions policy on the Control page of Ranger.

**ranger-obs-service:** The service provides an RPC interface that verifies permissions locally after receiving an authentication request from hadoop-obs/ranger-obs-client; It periodically synchronizes permission policies from the Ranger server

**ranger-obs-client:** Hadoop-obs integrates this plugin to forward requests that require permission validation to the ranger-obs-service

## Cloudera CDP Version 7.1.x

Compiled to run on Cloudewra CDP which supports these versions of components: <https://docs.cloudera.com/cdp-private-cloud-base/7.1.3/runtime-release-notes/topics/rt-runtime-component-versions.html>

## Development Environment requirements (JAVA)

  Development Kits for Java

  JDK 1.8.0 X86_64

  JRE 1.8.0 X86_64

  Apache Maven Compiler Plugin 3.8.1

  Visual Studio Code from Microsoft

## Source code compilation

1. git clone "https://github.com/rtcornwell/cdp-ranger-obs"

2. mvn clean package -D maven.test.skip=true

3. Generate the following components using Maven in the root directory. The pom.xml file has been updated with required libraries
   including the HuaweiCloud libraries in maven repository.

* ranger-obs/ranger-obs-client/target/ranger-obs-client-0.1.0.jar
* ranger-obs/ranger-obs-plugin/target/ranger-obs-plugin-0.1.0.tar.gz
* ranger-obs/ranger-obs-service/target/ranger-obs-service-0.1.0.tar.gz

## [Installation on Cloudera Cluster]

**Gather the following information from your apache ranger installation:**

* ENV_VARS: RANGER_ADMIN_HOME
* Directory to put plugin = [RANGERADMIN_HOME]/ews/webapp/WEB-INF/classes/ranger-plugins/obs
* RANGER_ADMIN_CONF_DIR = [RANGERADMIN_HOME]/etc

**Use the built in account "rangeradmin" for all configuration of ranger or the account you setup for ranger.**

## [Ranger-obs Plugin Install]

The plugin is integrated into the ranger console which allows you to setup policies

## (1) Unzip and extract the ranger-obs-plugin-0.1.0 .tar.gz, including the following

ranger-obs-plugin-0.1.0.jar (ranger obs plugin package)

ranger-obs.json (ranger plugin registration file)

## (2) Place both in the directory

Place the ranger-obs-plugin-0.1.0 .jar in the {rangeradminhome}/ews/webapp/WEB-INF/classes/ranger-plugins/obs] directory. Create it if it doesn???t exist
Note: the permissions of the users and user groups of the obs directory and the ranger-obs-plugin-0.1.0.jar

## (3) Restart the Ranger service

## (4) Register the OBS service on Ranger, make sure you point to the ranger-obs.json full path

    curl -u {rangeradmin}:{password} -X POST -d @ranger-obs.json -H "Accept: application/json" -H "Content-Type: application/json" -k 'http://{rangerhost}:6080/service/public/v2/api/servicedef'

## Successful Registration

curl -u xxxxx:xxxxx -X POST -d @ranger-obs.json -H "Accept: application/json" -H "Content-Type: application/json" - k 'http://192.168.0.169:6080/service/public/v2/api/servicedef'

{"id":204,"guid":"0d047247-bafe-4cf8-8e9b-d5d377284b2g","isEnabled":true,"createdBy":"Admin","updatedBy":"Admin","createTime":1665059305799,"updateTime":1665059305799,"version":1,"name":"obs","displayName":"obs","implClass":"org.apache.ranger.obs.RangerObsService","label":"OBS","description":"OBS","options":{"enableDenyAndExceptionsInPolicies":"true"},"configs":[],"resources":[{"itemId":1,"name":"bucket","type":"string","level":10,"mandatory":true,"lookupSupported":false,"recursiveSupported":false,"excludesSupported":true,"matcher":"org.apache.ranger.plugin.resourcematcher.RangerDefaultResourceMatcher","matcherOptions":{"wildCard":"true","ignoreCase":"false"},"validationRegEx":"","validationMessage":"","uiHint":"","label":"Bucket","description":"Bucket Name","accessTypeRestrictions":[],"isValidLeaf":false},{"itemId":2,"name":"path","type":"string","level":20,"parent":"bucket","mandatory":true,"lookupSupported":true,"recursiveSupported":true,"excludesSupported":true,"matcher":"org.apache.ranger.plugin.resourcematcher.RangerPathResourceMatcher","matcherOptions":{"wildCard":"true","ignoreCase":"false"},"validationRegEx":"","validationMessage":"","uiHint":"","label":"Path","description":"OBS Path, Should Not Start With /, exp. aaa/b.txt","accessTypeRestrictions":[],"isValidLeaf":true}],"accessTypes":[{"itemId":1,"name":"read","label":"Read","impliedGrants":[]},{"itemId":2,"name":"write","label":"Write","impliedGrants":[]}],"policyConditions":[],"contextEnrichers":[],"enums":[],"dataMaskDef":{"maskTypes":[],"accessTypes":[],"resources":[]},"rowFilterDef":{"accessTypes":[],"resources":[]}}root@cloudera-cdp:/home/ubuntu/cdp-ranger-obs/ranger-obs-plugin/target/ranger-obs-plugin-0.1.0#

![image](https://github.com/rtcornwell/cdp-ranger-obs/blob/02644d982deea19924ef0e7e2a644a54fe8ac2a7/servicescreen.png)

## [Ranger OBS Service Installation]

The ranger service is a service modules that runs as a service on the ranger host with it???s own url and ports. The calls to access OBS fiules go through this service. The services loads the policies from the plugin.

The following files will be loaded by the service when it starts so they should be complete and in the configuration directory of the service

 ranger-obs.xml
 core-site.xml - Copy from ranger conf directory
 hdfs-site.xml - copy from Hdfs conf directory
 hadoop-policy.xml - copy from hadoop conf directory

### (1) Extract service components from ranger-obs-service-0.1.0.tar.gz

* extract ranger-obs-service-0.1.0.tar.gz to /lib/opt/cloudera/parcels/CDH/lib/ranger-obs-plugin

* mkdir /var/lib/ranger/obs/policy-cache

[Setup Kerberos accounts] (Kerebos should already be installed on a kerberos server)

### (2) Log into ranger host and Add kerberos and local  users

    sudo useradd rangerobs -g hadoop -p rangerobs (this will be used by the service and the client)

    sudo mkdir /var/lib/ranger/obs
    sudo mkdir /var/lib/ranger/obs/policy-cache
    sudo mkdir /etc/security/keytabs
    cd /etc/security/keytabs
    
    sudo kadmin.local
    kdadmin.local: addprinc -pw 'rangerobs' rangerobs/hadoop@EXAMPLE.COM
    kdadmin.local: ktadd -norandkey -k rangerobs.keytab rangerobs/hadoop@EXAMPLE.COM
    kdadmin.local: quit  
    
    kinit -kt rangerobs.keytab rangerobs/hadoop@EXAMPLE.COM

### (3)Extract service components from "ranger-obs-service-0.1.0.tar.gz"

  sudo mkdir /opt/cloudera/parcels/CDH/lib/ranger-obs-plugin
  sudo mkdir /opt/cloudera/parcels/CDH/lib/ranger-obs-plugin/conf
  sudo mkdir /opt/cloudera/parcels/CDH/lib/ranger-obs-plugin/bin
  sudo mkdir /opt/cloudera/parcels/CDH/lib/ranger-obs-plugin/lib
  sudo mkdir /opt/cloudera/parcels/CDH/lib/ranger-obs-plugin/log

* copy lib directory to /opt/cloudera/parcels/CDH/lib/ranger-obs-plugin/lib

* conf directory to /opt/cloudera/parcels/CDH/lib/ranger-obs-plugin/conf

* bin directory to /opt/cloudera/parcels/CDH/lib/ranger-obs-plugin/bin

### (4) bin: Script directory

    in the start_rpc_server.sh:

      make sure the following line points to the kerebos config file:  -Djava.security.krb5.conf=/etc/krb5kdc/kdc.conf 

    In the start_server.sh:

      Make sure the following path is the correct path to the Hadoop native libraries: 

      native_path=/opt/cloudera/parcels/CDH/lib/hadoop/lib/native

### (5) conf: Profile directory

   core-site .xml and hdfs-site .xml: Configuration files needed to access THE HDFS service(this service relies on the HDFS service). Copy them from the HDFS service directory

   Ranger-obs-security.xml and ranger-obs-audit.xml: (access to the configuration file of the rangerAdmin service)

   ranger-obs.xml: (The main configuration file of the ranger-obs-service service itself)

   log4j.properties: Log configuration file

   haddop-policy.xml find a copy of it and place it in the conf folder. original copy is under /etc/hadoop/conf.cloudera.hdfs

### (6) lib: Dependent package directory

### (6) Configuration: Fill in the required options according to your own environment, and the others will remain at default values

(1) Core-site .xml and HDFS-site .xml configuration files: You can copy it from the hadoop root /etc/hadoop/directory

(2) Ranger-obs.xml configuration file: required configuration items. Change these settings in the file. The java module serverconstants.java reads and sets all these parameters.

   1. mkdir /etc/obs/conf
   2. copy Core-site.xml and HDFS-site.xml configuration files from the hadoop root /etc/hadoop/conf to /etc/obs/conf
   3. place the ranger-obs.xml, ranger-obs-security.xml
   4. Ranger-obs .xml configuration file: required configuration items  
  
  <!-- ranger-obs-service Kerberos

  <property>
    <name>ranger.obs.service.kerberos.principal</name>
    <value>rangerobs/hadoop@EXAMPLE.COM</value>
  </property> 
  -->

  <!-- ranger-obs-service Kerberos  

  <property>
      <name>ranger.obs.service.kerberos.keytab</name>
      <value>/etc/security/keytabs/rangerobs.keytab</value>
  </property> 
  -->

  <!-- ranger-obs-service-sts (OTC Token Service) --

  <property>
      <name>ranger.obs.service.sts.enable</name>
      <value>false</value>
  </property>
  <property>
      <name>ranger.obs.service.sts.token.url</name>
      <value>"https://iam.eu-de.otc.t-systems.com.com/v3/auth/tokens?nocatalog=true"</value>
  </property>
  <property>
      <name>ranger.obs.service.sts.domain.name</name>
      <value>OTC0000000100001497</value>
  </property>
  <property>
      <name>ranger.obs.service.sts.user.name</name>
      <value>rangerobs</value>
  </property>
  <property>
      <name>ranger.obs.service.sts.user.password</name>
      <value>rangerobs</value>
  </property>
  <property>
      <name>ranger.obs.service.sts.securitytoken.url</name>
      <value>https://iam.eu-de.otc.t-systems.com/v3.0/OS-CREDENTIAL/securitytokens</value>
  </property>
  --
    <!--STS Token validity in seconds (24 Hours = 86400) --
  <property>
      <name>ranger.obs.service.sts.securitytoken.duration</name>
      <value>86400</value>
  </property>
-->

(3) ranger-obs-security.xml configuration file:

 <!-- 
 
  <property>
      <name>ranger.plugin.obs.policy.cache.dir</name>
      <value>/var/lib/ranger/obs/policy-cache</value>
  </property>

  <property>
      <name>ranger.plugin.obs.policy.rest.url</name>
      <value>http://<ip of Rangeradmint>:6080</value>
  </property>"
-->
### 7.Launch

  sudo  nohup ./start_server.sh [path to config files]

## [ranger-obs-client installation]

 1. Installation:

  Place the ranger-obs-client-0.1.08 jars /opt/cloudera/parcels/CDH-7.1.7-1.cdh7.1.7.p0.15945976/jars
 2. Configuration

  Add the following configuration key to the core-site .xml file under the hadoop component directory:/etc/hadoop/conf.cloudera.hdfs

        <property>
            <name>ranger.obs.service.rpc.address</name>
            <value>ipaddress:26900</value>
        </property>
        <property>
            <name>ranger.obs.service.kerberos.principal</name>
            <value>rangerobs/hadoop@EXAMPLE.COM</value>
        </property> </h1?>
        <property>
            <name>fs.obs.authorize.provider</name>
            <value>org.apache.hadoop.fs.obs.security.RangerAuthorizeProvider</value>
        </property>

When this parameter is configured, the hadoop-obs module will walk the rangerauthentication logic,otherwise it will not take the ranger authentication logic

## [ranger-admin Policy configuration]

 (1) Enter the obs service on ranger and create a policy for a bucket. The bucket should have been created ahead

     The relevant parameters are meanings as follows:

     bucket: <OBS bucket name>
     path: <path>         (Object path, support wildcards, note that object paths do not start with /.)
     include:                  (Indicates whether the set permission applies to path itself or to a path other than path.)
     recursive:               (Indicates that permissions apply not only to path, but also to child members under path (i.e., recursive child members). Typically used when path is set to a directory.
    
     Note: For bucket root directories, because the corresponding object path is an empty string, it can only be set by the * wildcard character at present, and it is recommended that you set the permissions of the root directory only for administrators

    user/group:
    User name and user group. Here is the relationship of or, that is, the user name or user group satisfies one of them, and it can have the corresponding operation permissions.
    Permissions???
    Read: Read operation. Corresponding to get and HEAD class operations in object storage, including downloading objects and querying object metadata.
    Write: Write operation. Corresponds to modification operations such as the PUT class in object storage, such as uploading objects.
