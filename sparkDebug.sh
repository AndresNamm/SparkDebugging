# Spark Environment/Application related parameters, not modifiable by cli

master=yarn
deployMode=client
#applicationWithParameters="--class org.apache.spark.examples.SparkPi     /opt/spark/examples/jars/spark-examples_2.11-2.4.0.jar 10"
#applicationWithParameters=
#applicationWithParameters=piExample.py
#sparkAPI="spark-submit" # ested with spark-submit, pyspark, spark-shell
sparkAPI=pyspark
# Performance related parameters

ec=1
ne=1
em=512m
dm=512m
ydmo=1500m
yemo=1500m
emo=1500m
dmo=1500m
settings=

while [ "$1" != "" ]; do
    case $1 in
        -D )            shift
                        deployMode=$1
                                ;;
        -ec )           shift
                        settings="$settings  --executor-cores $1"
                                ;;
        -ne )           shift
                        settings="$settings  --num-executors $1"
                                ;;
        -dm )           shift
                        settings="$settings  --driver-memory $1"
                                ;;
        -em )           shift
                        settings="$settings --executor-memory $1"
                                ;;
        -yam )          shift
                        settings="$settings --conf spark.yarn.am.memory=$1"
                                ;;
        -yamo )         shift
                        settings="$settings --conf spark.yarn.am.memoryOverhead=$1"
                                ;;
        -emo )          shift
                        settings="$settings --conf spark.executor.memoryOverhead=$1"
                                ;;
        -dmo )          shift
                        settings="$settings --conf spark.driver.memoryOverhead=$1"
                                ;;
        -all )          shift
                        settings="--driver-memory $dm --num-executors $ne --executor-memory $em --executor-cores $ec --conf \"spark.executor.memoryOverhead=$emo\" --conf \"spark.driver.memoryOverhead=$dmo\""
                                ;;
        -set )          shift
                        settings="$settings $1"
                                ;;

    esac
    shift
done

execSpark="$sparkAPI $settings --master $master --deploy-mode $deployMode $applicationWithParameters"
$execSpark
echo $execSpark
