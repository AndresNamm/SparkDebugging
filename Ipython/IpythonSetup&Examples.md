---
title: Settin up Ipython on Yarn + examples
---

# TUTORIAL CONDITIONS

+ Spark 2.4.0 built for Hadoop 2.7.3
+ Hadoop 2.7.7
+ Spark and Hadoop in pseudo distributed mode installed manually without any cluster
+ 4.15.0-43-generic
+ as hduser2

# TUTORIAL SETUP

+ First my .profile
~~~
export SPARK_HOME=/opt/spark
export HADOOP_HOME=/opt/hadoop2.7
export PATH=$HADOOP_HOME/bin:$HADOOP_HOME/sbin:usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
export PATH=$SPARK_HOME/bin:$PATH
export LD_LIBRARY_PATH=$HADOOP_HOME/lib/native
export HADOOP_CONF_DIR=/opt/hadoop2.7/etc/hadoop
export HDFS_NAMENODE_USER=hduser2
export HDFS_DATANODE_USER=hduser2
export HDFS_SECONDARYNAMENODE_USER=hduser2
#export SPARK_HOME=/opt/spark
#export SPARK_CONF_DIR=/opt/spark/conf
#export SPARK_MASTER_HOST=localhost
export JAVA_HOME=/usr/lib/jvm/java-8-oracle
export PYSPARK_PYTHON=python3.6
export PYSPARK_DRIVER_PYTHON_OPTS='notebook --ip=192.168.115.203 --port=8899'
export PYSPARK_DRIVER_PYTHON=ipython3
~~~

1. [Set up hadoop, loads of tutorials. One of them is this](https://www.edureka.co/blog/install-hadoop-single-node-hadoop-cluster)
2. [Setting up Spark on Yarn](https://www.linode.com/docs/databases/hadoop/install-configure-run-spark-on-top-of-hadoop-yarn-cluster/)
3. [After that follow this to setup Ipython](https://blog.sicara.com/get-started-pyspark-jupyter-guide-tutorial-ae2fe84f594f)
    + I did this without findspark

## SETTING UP IPYTHON


~~~
sudo yum install yum-utils -y
sudo yum install https://centos7.iuscommunity.org/ius-release.rpm -y
sudo yum install python36u -y
sudo yum install python36u-pip -y
pip3.6 install pyspark
pip3.6 install findspark
~~~

~~~
Exception: Python in worker has different version 2.7 than that in driver 3.6, PySpark cannot run with different minor versions.Please check environment variables PYSPARK_PYTHON and PYSPARK_DRIVER_PYTHON are correctly set.
~~~

+ Solution. Add this to ~/.profile -> logout -> login "sudo su - hduser2"
~~~
export PYSPARK_PYTHON='/usr/bin/python3'
~~~


## ISSUES WITH CLASSES NOT EXISTING


~~~
su - spark
kinit -kt /etc/security/keytabs/spark.headless.keytab spark-logihadoopdev@TESTHADOOP.COM
git clone https://github.com/AndresNamm/SparkConfAndDebugging.git
cd SparkConfAndDebugging/
export PYSPARK_PYTHON=python3.6
./sparkDebug.sh
~~~

+ After executing this in bradus and bryht it did not work , other places it worked
    +
    ~~~
    Could not find valid SPARK_HOME while searching ['/home/spark', '/usr/bin']
    Failed to find Spark jars directory (/assembly/target/scala-2.12/jars).
    You need to build Spark with the target "package" before running this program.
    spark-submit --master yarn --deploy-mode client piExample.py
    ~~~
    +
    ~~~
    19/01/02 15:07:51 WARN DomainSocketFactory: The short-circuit local reads feature cannot be used because libhadoop cannot be loaded.
Exception in thread "main" java.lang.NoClassDefFoundError: com/sun/jersey/api/client/config/ClientConfig
	at org.apache.hadoop.yarn.client.api.TimelineClient.createTimelineClient(TimelineClient.java:55)
	at
    ~~~

### solutions I tried

1. [TIMELINE SERVICE](https://issues.apache.org/jira/browse/SPARK-15343)  Andis ka muu klassi puudumise errori ka pärast relevantse settingu muutmist.
2. [No env variable worked ](https://stackoverflow.com/questions/45703235/when-running-with-master-yarn-either-hadoop-conf-dir-or-yarn-conf-dir-must-be)

### WHAT WORKED

1. @ susanna.estpak.ee Tested out with clush the env variables

~~~
clush -l root -w bryht.estpak.ee,brica.estpak.ee "env" | sed 's/.*.estpak.ee: //' | sort -h
~~~

2. The only difference was

~~~
SPARK_CONF_DIR=/usr/hdp/current/spark2-client/conf
SPARK_CONF_DIR=/usr/hdp/current/spark2-historyserver/conf
~~~

3. Then in bradus.estpak.ee I tried

~~~
export PYSPARK_PYTHON=python3.6
export SPARK_HOME=/usr/hdp/current/spark2-client
export HADOOP_HOME=/usr/hdp/current/hadoop-client
export HADOOP_CONF_DIR=/usr/hdp/current/hadoop-client/conf
~~~
    + this worked
    + Actully only export SPARK_HOME=/usr/hdp/current/spark2-client is needed

### FURTHER RESEARCH AFTER FINDING OUT SOLUTION

+ **TURNS OUT spark-submit scripts in different machines are different**

+ spark-submit where it worked, caradyn, caraw, bryht
~~~
CURRENT_DIR="$(cd "`dirname "$0"`"; pwd)"

. "${CURRENT_DIR}"/spark-script-wrapper.sh

EXECUTABLE=$(find_script $0)

exec "${EXECUTABLE}" "$@"
~~~

+ spark-submit where it dit not work brica and[spark@bradus SparkConfAndDebugging]$ cat /usr/bin/spark-submit

~~~
if [ -z "${SPARK_HOME}" ]; then
  source "$(dirname "$0")"/find-spark-home
fi

export PYTHONHASHSEED=0
exec "${SPARK_HOME}"/bin/spark-class org.apache.spark.deploy.SparkSubmit "$@"
~~~

+ Seems like these things have different times for login.
