---
title: Configuration Specification of Spark
---

# SPARK ON YARN  - based on Spark version 2.4 but links reference latest which will soon change

+ This documentation is rather good
    + [Spark on yarn specifics](https://spark.apache.org/docs/latest/running-on-yarn.html)
    + [Spark general configuration](https://spark.apache.org/docs/latest/configuration.html)    

## SPARK CLUSTER VS CLIENT MODE

+ However keep in mind when specifying memory, there is a difference when running on cluster mode and client mode with Yarn at least

+ **Cluster mode** Spark requested driver memory size regulates AM requested memory
    + --driver-memory  has to be bigger than 512m otherwise job fails because of Java 8 virtual memory usage. The default value is  2GB so its okay
+ **Client mode**
    + spark.yarn.am.memory You have to manually specify this as bigger than 512m (1024 should be fine at least for Spark Pi ) Again Java 8 virtual memory usage issue.


## GENERAL SPECIFICATIONS

+ Spark 2.4  does not have settings spark.yarn.executor.memoryOverhead & spark.yarn.driver.memoryOverhead anymore (Unlike Spark 2.2).
You can specify this by spark.executor.memoryOverhead spark.driver.memoryOverhead
