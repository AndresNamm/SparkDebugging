
# RUNNING examples

+ sparkDebug.sh (logs std and stderr? into sparkRunLogs) submits spark jar with specified parameters

~~~
./sparkDebug.sh -ec 1 -ne 1 -em 512m -dm 1024m -emo 1536m -dmo 2048m  # 2> sparkRunLogs 1> sparkRunLogs
~~~

+ hadoop.sh - starts all hadoop components
~~~
hadoop.sh start
hadoop.sh stop
~~~



# SPECIFICATIONS

For sparkDebug there are some predefined statically written variables that you cannot change via cli. This has been made to ease testing as multiple runs of same application are usually done.
**Examples**
+ applicationWithParameters=
    + applicationWithParameters="--class org.apache.spark.examples.SparkPi     /opt/spark/examples/jars/spark-examples_2.11-2.4.0.jar 10"
    + applicationWithParameters=
+ sparkAPI=
    + sparkAPI="pyspark"
    + sparkAPI="spark-submit"
    + sparkAPI="spark-shell"
