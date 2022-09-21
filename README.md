Overview of Ranger plugin for OBS service on open Telekom Cloud
 

1.	ranger-obs-plugin: Provides a service definition plugin on the Ranger server. It provides OBS service permission control on the Ranger side; After the plug-in is deployed, users can fill in the appropriate permissions policy on the Control page of Ranger. 

2.	ranger-obs-service: The service provides an RPC interface that verifies permissions locally after receiving an authentication request from hadoop-obs/ranger-obs-client; It periodically synchronizes permission policies from the Ranger server 

3.	ranger-obs-client: Hadoop-obs integrates this plugin to forward requests that require permission validation to the ranger-obs-service

Development Environment requirements (JAVA)

Development Kits for Java

JDK 1.8.0 X86_64

JRE 1.8.0 X86_64

Apache Maven 3.8

Gather the following information from your apache ranger installation:
In ENV_VARS: RANGER_ADMIN_HOME

Directory to put plugins = <RANGERADMIN_HOME>/ews/webapp/WEB-INF/classes/ranger-plugins/obs
RANGER_ADMIN_CONF_DIR=<RANGERADMIN_HOME>/etc
Use the built in account "rangeradmin" for all configuration of ranger or the account you setup for ranger.


Source code compilation
1.	git clone https://github.com/rtcornwell/ranger-obs
2.	mvn clean package -D maven.test.skip=true
3.	Generate the following components using Maven in the root directory. The pom.xml file has been updated with required libraries including the HuaweiCloud libraries in maven repository.
ranger-obs/ranger-obs-client/target/ranger-obs-client-0.1.0.jar
ranger-obs/ranger-obs-plugin/target/ranger-obs-plugin-0.1.0.tar.gz
ranger-obs/ranger-obs-service/target/ranger-obs-service-0.1.0.tar.gz

[Ranger-obs Plugin Install:]

(1) Unzip and extract the ranger-obs-plugin-0.1.0 .tar.gz, including the following:

	ranger-obs-plugin-0.1.0.jar (ranger obs plugin package)
	ranger-obs.json (ranger plugin registration file)

(2) Place both in the <RANGER_ADMIN_HOME> directory

Place the ranger-obs-plugin-0.1.0 .jar in the <clouderahome>/ranger-admin/ews/webapp/WEB-INF/classes/ranger-plugins/obs directory
Note the permissions of the users and user groups of the obs directory and the ranger-obs-plugin-0.1.0.jar

(3) Restart the Ranger service

(4) Register the OBS service on Ranger

	curl -u rangerobs:rangerobs -X POST -d @ranger-obs.json -H "Accept: application/json" -H "Content-Type: application/json" -k 'http://192.168.0.13:6080/service/public/v2/api/servicedef'
	

 Note: The following display means it was successful; HTTP/1.1 200 OK

(5) Create an obs service in the following directory


[Ranger OBS Service Installation]

1.	Log into master node and Add kerberos and local  users:

		sudo useradd rangerobs -g hadoop -p rangerobs
                kadmin.local
		kdadminm.local: addprinc -randkey rangerobs/hadoop@example.com
		quit
		mkdir /etc/security/keytabs
		cd /etc/security/keytabs
		ktutil
		ktutil: addent -password -p rangerobs/hadoop@example.com -k 1 -e RC4-HMAC
		Password for rangerobs/hadoop@example.com: rangerobs
		ktutil: wkt rangerobs.keytab
		ktutil: ktadd -k /etc/security/keytabs/rangerobs.keytab rangerobs/hadoop@example.com
		ktutil:  quit
	

2.	Extract service components from ranger-obs-service-0.1.0 .tar.gz
	
	- lib directory to /opt/cloudera/parcels/CDH-7.1.7-1.cdh7.1.7.p0.15945976/lib/ranger-admin/ews/webapp/WEB-INF/lib
	
	- conf directory to cp ranger* /opt/cloudera/parcels/CDH-7.1.7-1.cdh7.1.7.p0.15945976/lib/ranger-admin/ews/webapp/WEB-INF/classes/conf
	
	- bin directory to /opt/cloudera/parcels/CDH-7.1.7-1.cdh7.1.7.p0.15945976/lib/ranger-admin/bin
	

3.	 bin: Script directory

	* start_rpc_server.sh: 

	Cloudera is integrated and used, which involves a lot ofmr.-specific related information. make sure the following line points to the kerebos config file:
	
		-Djava.security.krb5.conf=/etc/krd5.conf

	* start_server.sh: 
	
	Open source big data cluster use: Make sure the following path is the correct path to the haddop native libaries: 
	
		native_path=/opt/cloudera/parcels/CDH-7.1.7-1.cdh7.1.7.p0.15945976/lib/hadoop/lib/native

4.	 conf: Profile directory

	core-site .xml and hdfs-site .xml: Configuration files needed to access THE HDFS service(this service relies on the HDFS service)

	Ranger-obs-security.xml and ranger-obs-audit .xml: (access to the configuration file of the rangerAdmin service)

	ranger-obs.xml: (The main configuration file of the ranger-obs-service service itself)

	Kdc.conf and rangerobs.keytab, etc.: Other optional configuration files

	log4j.properties: Log configuration file

5.	lib: Dependent package directory

6.	Configuration: Fill in the required options according to your own environment, and the others will remain at default values

	(1) Core-site .xml and HDFS-site .xml configuration files:
	You can copy it from the hadoop root /etc/hadoop/directory
	Note: Configure-ranger.obs.xxx-site .xml and HDFs-site .xml configuration files forranger-obs-service do not appear

	(2) Ranger-obs .xml configuration file: required configuration items


		<!-- ranger-obs-service Kerberos -->
		<property>
		<name>ranger.obs.service.kerberos.principal</name>
		<value>rangerobs/hadoop@NOVALOCAL</value>
		</property>
		
		<!-- ranger-obs-servic Kerberos  -->
		<property>
		<name>ranger.obs.service.kerberos.keytab</name>
		<value>/etc/security/keytabs/rangerobs.keytab</value>
		</property>

	(3) ranger-obs-security.xml configuration file: 

		 <property>
       			 <name>ranger.plugin.obs.policy.cache.dir</name>
      			 <value><clouderapolicycachedirectory></value>
   		 </property> 
		
		<property>
        		<name>ranger.plugin.obs.policy.rest.url</name>
        		<value>http:/<rangeradminhlostip>:6080</value>
   		 </property>
  

7. Launch
	
		 nohup ./start_server.sh 



[ranger-obs-client installation]

	1. Installation:

		Place the ranger-obs-client-0.1.0-SNAPSHOT .jar and the ranger-obs-client-0.1.0-SNAPSHOT-tests .jar in the hadoop-obs directory

	2. Configuration
			
		Add the following configuration key to the core-site .xml file under the hadoop component directory:

		<property>
			<name>ranger.obs.service.rpc.address</name>
			<value>ipaddress:26900</value>
		</property>
		<property>
			<name>ranger.obs.service.kerberos.principal</name>
			<value>rangerobs/hadoop@example.com</value>
		</property>
	        <property>
			<name>fs.obs.authorize.provider</name>
			<value>org.apache.hadoop.fs.obs.security.RangerAuthorizeProvider</value>
		</property>
				
		When this parameter is configured, the hadoop-obs module will walk the rangerauthentication logic, 
		otherwise it will not take the ranger authentication logic

	ranger-admin configuration

	(1)	Enter the obs service on ranger and create a policy for a bucket. The bucket should have been created ahead

	The relevant parameters are meanings as follows:

	bucket: OBS bucket name
	path: Object path, support wildcards, note that object paths do not start with /.
	include: Indicates whether the set permission applies to path itself or to a pathother than path.
	recursive: Indicates that permissions apply not only to path, but also to childmembers under path path (i.e., recursive child members). Typically used when
	pathis set to a directory.

	Note: For bucket root directories, because the corresponding object path is an empty string, it can only be set by the * wildcard character at present, and it
	is recommended that you set the permissions of the root directory only for administrators

	user/group: 
	User name and user group. Here is the relationship of or, that is, the user name or user group satisfies one of them, and it can have the corresponding 
	operation permissions.

	Permissions：
	Read: Read operation. Corresponding to get and HEAD class operations in object storage, including downloading objects and querying object metadata.
	Write: Write operation. Corresponds to modification operations such as the PUT class in object storage, such as uploading objects.


