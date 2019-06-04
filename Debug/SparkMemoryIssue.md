---
title: "DEBUG Spark 2 on Yarn"
---


# THE ISSUE I HAD

## SYSTEM

+ Spark 2.4.0 built for Hadoop 2.7.3
+ Hadoop 2.7.7
+ Spark and Hadoop in pseudo distributed mode installed manually without any cluster
+ 4.15.0-43-generic
+ 4.15.0-43-generic

## DESCRIPTION


**General issue: Running Spark jobs on yarn failed in client and in cluster mode**

+ cluster mode setting (--driver-memory 512m)
    ~~~
    18/12/21 16:53:58 ERROR Client: Application diagnostics message: Shutdown hook called before final status was reported.
    Exception in thread "main" org.apache.spark.SparkException: Application application_1545388712996_0019 finished with failed status
    	at org.apache.spark.deploy.yarn.Client.run(Client.scala:1149)
    	at org.apache.spark.deploy.yarn.YarnClusterApplication.start(Client.scala:1526)
    	at org.apache.spark.deploy.sparkDebug.org$apache$spark$deploy$sparkDebug$$runMain(sparkDebug.scala:849)
    	at org.apache.spark.deploy.sparkDebug.doRunMain$1(sparkDebug.scala:167)
    	at org.apache.spark.deploy.sparkDebug.submit(sparkDebug.scala:195)
    	at org.apache.spark.deploy.sparkDebug.doSubmit(sparkDebug.scala:86)
    	at org.apache.spark.deploy.sparkDebug$$anon$2.doSubmit(sparkDebug.scala:924)
    	at org.apache.spark.deploy.sparkDebug$.main(sparkDebug.scala:933)
    	at org.apache.spark.deploy.sparkDebug.main(sparkDebug.scala)
    18/12/21 16:53:58 INFO ShutdownHookManager: Shutdown hook called
    ~~~
+ client mode
    ~~~
    java.io.IOException: Failed to send RPC RPC 5774007918916349212 to /192.168.0.39:55308: java.nio.channels.ClosedChannelException
    	at org.apache.spark.network.client.TransportClient$RpcChannelListener.handleFailure(TransportClient.java:357)
    	at org.apache.spark.network.client.TransportClient$StdChannelListener.operationComplete(TransportClient.java:334)
    	at io.netty.util.concurrent.DefaultPromise.notifyListener0(DefaultPromise.java:507)
    	at io.netty.util.concurrent.DefaultPromise.notifyListenersNow(DefaultPromise.java:481)
    	at io.netty.util.concurrent.DefaultPromise.notifyListeners(DefaultPromise.java:420)
    	at io.netty.util.concurrent.DefaultPromise.tryFailure(DefaultPromise.java:122)
    	at io.netty.channel.AbstractChannel$AbstractUnsafe.safeSetFailure(AbstractChannel.java:987)
    	at io.netty.channel.AbstractChannel$AbstractUnsafe.write(AbstractChannel.java:869)
    	at io.netty.channel.DefaultChannelPipeline$HeadContext.write(DefaultChannelPipeline.java:1316)
    	at io.netty.channel.AbstractChannelHandlerContext.invokeWrite0(AbstractChannelHandlerContext.java:738)
    	at io.netty.channel.AbstractChannelHandlerContext.invokeWrite(AbstractChannelHandlerContext.java:730)
    	at io.netty.channel.AbstractChannelHandlerContext.access$1900(AbstractChannelHandlerContext.java:38)
    	at io.netty.channel.AbstractChannelHandlerContext$AbstractWriteTask.write(AbstractChannelHandlerContext.java:1081)
    ~~~

+ First, submiting spark sample Pi application (Java) failed with default parameters in client mode but not in cluster mode.
+ In cluster mode it failed when I specified **Driver Memory** --driver-memory to be 512m. (The default setting requested 2GB of am resources (This consists of driver memory + Overhead requested for Application Master) which was enough)
+ In client mode the setting that mattered was spark.yarn.am.memory as by default this requested only 1024m for the AM which is too little as Java 8 requires a lot of virtual memory. > 1024m seemed to be working.
What also worked
1.  Changing Virtual Memory ratio SETTING (BELOW)

**LOOK BELOW FOR MORE SPECIFIC EXPLANATIONS OF THE ISSUE**


# NOTES FOR DEBUGGING

+ SPARK SESSION WHICH RUNS IN JVM INSIDE SPARK DRIVER CAN COMMUNICATE VIA SPARK API WITH USER CODES.
+ SPARK SESSION IS LIKE AN ENTRANCE POINT FOR RUNNINC SPARK CODE
+ SPARK DRIVER CAN RUN IN LOCAL AND IN CLUSTER MODE. LOCAL MODE MEANS DRIVER IS INSIDE CLIENT. CLUSTER MODES MEANS DRIVER IS INSIDE CLUSTER
    + IN YARN CLUSTER MODE MEANS, THAT SPARK RUNS INSIDE AM
+ SPARK REQUESTED MEMORY TRANSLATES TO PHYSICAL MEMORY
    + BASED ON OBSERVATION THAT WHEN I REQUEST 1 GB ON VM FOR AM, I WILL SEE THAT IT HAS 1 GB OF PHYSICAL MEMORY FOR AM AND 2.2 GB OF VIRTUAL MEMORY FOR AM


# EXPERIMENTING WITH DIFFERENT SETTINGS - SOLUTION

+ The overall issue likely is Java 8 requesting too much virtual memory.  

## CHANGING THE VIRTUAL MEMORY RATIO SETTINGS IN YARN

+ The problem has been referenced as java 8 having very high virtual memory usage.
+ [Correct not dangerous solution is here by hi-zir (not first solution provided in stackoverflow)](https://stackoverflow.com/questions/39467761/how-to-know-what-is-the-reason-for-closedchannelexceptions-with-spark-shell-in-y)
    + yarn-site.xml - [DEFAULT VALUE FOR THIS I 2.1 ](https://hadoop.apache.org/docs/r2.7.5/hadoop-yarn/hadoop-yarn-common/yarn-default.xml)
    ~~~
    <property>
    <name>yarn.nodemanager.vmem-pmem-ratio</name>
    <value>5</value>
    </property>
    ~~~
    + [Virtual memory and Physical memory -Best answer ](https://stackoverflow.com/questions/14347206/what-are-the-differences-between-virtual-memory-and-physical-memory)


## GIVING SPARK MORE spark.yarn.am.memoryOverhead, spark.yarn.am.memory when in client mode

+ [In client mode, spark.yarn.am.memoryOverhead, spark.yarn.am.memory settings are important. In cluster mode use spark.driver.memory and spark.driver.memory.memoryOverhead settings instead ](https://stackoverflow.com/questions/50402020/spark-driver-memory-and-application-master-memory)
    + You can find the specific settings  [here](http://spark.apache.org/docs/2.2.0/running-on-yarn.html#spark-properties)
+ The problem is still likely related to the first solution

+ In client mode adding memory yam  solved the issue (spark.yarn.am.memory when in client mode) here, also look at the setting spark.yarn.am.memoryOverhead, but it was not vital in the specific case
+ spark.yarn.am.memory=512m is not enough

~~~
yarn-hduser2-resourcemanager-udu.log:19240:2018-12-21 13:25:17,807 INFO org.apache.hadoop.yarn.server.resourcemanager.scheduler.SchedulerNode: Released container container_1545388712996_0006_01_000001 of capacity <memory:3072, vCores:1> on host udu:37475, which currently has 0 containers, <memory:0, vCores:0> used and <memory:8192, vCores:8> available, release resources=true
~~~


# USE CASE - RUNNING IN STANDALONE YARN ON MY COMPUTER TRYING TO FIGURE OUT EACH APPLICATIONS CONTAINER MEMORY USAGE WITH FAILED APPLICATION

+ I executed
~~~
spark-submit --executor-cores 1 --num-executors 1 --executor-memory 512m --driver-memory 512m --conf spark.yarn.driver.memoryOverhead=4096m --conf spark.yarn.driver.memoryOverhead=4096 --conf spark.executor.memoryOverhead=4096m --conf spark.driver.memoryOverhead=4096m --master yarn --deploy-mode client --class org.apache.spark.examples.SparkPi /opt/spark/examples/jars/spark-examples_2.11-2.4.0.jar 10  2> sparkRunLogs 1> sparkRunLogs
~~~

+ Searched the application name and the command from "sparkRunLogs"
~~~
cat sparkRunLogs | grep "spark-submit\|Submitting application application_"
~~~
    + output
    ~~~
    spark-submit --executor-cores 1 --num-executors 1 --executor-memory 512m --driver-memory 512m --conf spark.yarn.driver.memoryOverhead=4096m --conf spark.yarn.driver.memoryOverhead=4096 --conf spark.executor.memoryOverhead=4096m --conf spark.driver.memoryOverhead=4096m --master yarn --deploy-mode client --class org.apache.spark.examples.SparkPi /opt/spark/examples/jars/spark-examples_2.11-2.4.0.jar 10
    18/12/21 10:38:28 INFO Client: Submitting application application_1545324657561_0006 to ResourceManager
    ~~~

+ in $HADOOP_HOME/logs/ I searched for the found application name and the associated yarn CONTAINERIDs
~~~
grep -rnw application_1545324657561_0006
grep -rnw application_1545324657561_0006 | grep CONTAINERID
grep -rnw application_1545324657561_0006 | grep trackingUrl # Actually its much better to just look at the RM at 8088 , Not historyserver as it only keeps mapred logs
grep -rnw application_1545324657561_0006 | sed -n "s/.*\(container_[0-9][0-9_]*\).*/\1/p" | sort | uniq
grep -rnw application_1545324657561_0006 | sed -n 's/.*APPATTEMPTID=\(appattempt_[0-9_]*\).*/\1/p'
app=application_1545324657561_0006
~~~
~~~
grep -rnw $app
grep -rnw $app | grep CONTAINERID
grep -rnw $app | grep trackingUrl # Actually its much better to just look at the RM at 8088 , Not historyserver as it only keeps mapred logs
grep -rnw $app | sed -n "s/.*\(container_[0-9][0-9_]*\).*/\1/p" | sort | uniq
grep -rnw $app | sed -n 's/.*APPATTEMPTID=\(appattempt_[0-9_]*\).*/\1/p'
~~~
    + output - there 2 appattempts. Each has 2 matching containers according to logs
    ~~~
    # appattempt_1545324657561_0006_000001
    container_1545324657561_0006_01_000001
    container_1545324657561_0006_01_000002
    # appattempt_1545324657561_0006_000002
    container_1545324657561_0006_02_000002
    container_1545324657561_0006_02_000001
    ~~~

+ searched for the occurence of "container_1545324657561_0006_01_000001" and "container_1545324657561_0006_01_000002" in $HADOOP_HOME/logs    
+ command
~~~
grep -rnw container_1545324657561_0006_01_000001 | grep kill
grep -rnw $cont1 | grep -i kill
~~~
+ output **yarn-hduser2-nodemanager-udu.log** Container errors given by nodemanager
~~~
yarn-hduser2-nodemanager-udu.log:16178:2018-12-21 10:38:33,274 WARN org.apache.hadoop.yarn.server.nodemanager.containermanager.monitor.ContainersMonitorImpl: Container [pid=1991,containerID=container_1545324657561_0006_01_000001] is running beyond virtual memory limits. Current usage: 352.2 MB of 1 GB physical memory used; 2.2 GB of 2.1 GB virtual memory used. Killing container.
yarn-hduser2-nodemanager-udu.log:16185:2018-12-21 10:38:33,274 INFO org.apache.hadoop.yarn.server.nodemanager.containermanager.container.ContainerImpl: Container container_1545324657561_0006_01_000001 transitioned from RUNNING to KILLING
~~~

+ command
~~~
grep -rnw container_1545324657561_0006_01_000002
grep -rnw $cont1 | grep kill

~~~
+ Output - here we have requested 4096m overhead and 512 m of executor memory.   yarn-hduser2-resourcemanager-udu.log has information about container requsets
~~~
yarn-hduser2-resourcemanager-udu.log:18186:2018-12-21 10:38:33,306 INFO org.apache.hadoop.yarn.server.resourcemanager.scheduler.capacity.LeafQueue: completedContainer container=Container: [ContainerId: container_1545324657561_0006_01_000002, NodeId: udu:40695, NodeHttpAddress: udu:8042, Resource: <memory:5120, vCores:1>, Priority: 1, Token: null, ] queue=default: capacity=1.0, absoluteCapacity=1.0, usedResources=<memory:0, vCores:0>, usedCapacity=0.0, absoluteUsedCapacity=0.0, numApps=1, numContainers=0 cluster=<memory:8192, vCores:8>
yarn-hduser2-resourcemanager-udu.log:18181:2018-12-21 10:38:33,306 INFO org.apache.hadoop.yarn.server.resourcemanager.rmcontainer.RMContainerImpl: container_1545324657561_0006_01_000002 Container Transitioned from ALLOCATED to KILLED
yarn-hduser2-resourcemanager-udu.log:18182:2018-12-21 10:38:33,306 INFO org.apache.hadoop.yarn.server.resourcemanager.scheduler.common.fica.FiCaSchedulerApp: Completed container: container_1545324657561_0006_01_000002 in state: KILLED event:KILL
yarn-hduser2-resourcemanager-udu.log:18189:2018-12-21 10:38:33,306 INFO org.apache.hadoop.yarn.server.resourcemanager.scheduler.capacity.CapacityScheduler: Application attempt appattempt_1545324657561_0006_000001 released container container_1545324657561_0006_01_000002 on node: host: udu:40695 #containers=0 available=<memory:8192, vCores:8> used=<memory:0, vCores:0> with event: KILL
~~~

+
~~~
grep -rnw $cont1 | grep memory
~~~
+ Output
    + logs/yarn-hduser2-nodemanager-udu.log
    ~~~
    logs/yarn-hduser2-nodemanager-udu.log:19499:2018-12-21 17:13:28,197 INFO org.apache.hadoop.yarn.server.nodemanager.containermanager.monitor.ContainersMonitorImpl: Memory usage of ProcessTree 20897 for container-id container_1545388712996_0021_01_000001: 284.6 MB of 2 GB physical memory used; 2.7 GB of 4.2 GB virtual memory used
    ~~~
    + logs/yarn-hduser2-resourcemanager-udu.log
    ~~~
    logs/yarn-hduser2-resourcemanager-udu.log:21546:2018-12-21 17:13:25,592 INFO org.apache.hadoop.yarn.server.resourcemanager.scheduler.SchedulerNode: Assigned container container_1545388712996_0021_01_000001 of capacity <memory:2048, vCores:1> on host udu:37475, which has 1 containers, <memory:2048, vCores:1> used and <memory:6144, vCores:7> available after allocation
    ~~~
