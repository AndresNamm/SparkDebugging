# Spark Environment/Application related parameters, not modifiable by cli

master=yarn
deployMode=client
applicationWithParameters=
sparkCommand=spark-shell

# Performance related parameters

ec=1
ne=1
em=512m
dm=512m
yamm=512m
ydmo=1500m
yemo=1500m
emo=1500m
dmo=1500m
settings=

while [ "$1" != "" ]; do
    case $1 in
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
        -yamm )          shift
                        settings="$settings --conf spark.yarn.am.memory=$1"
                                ;;

        -ydmo )         shift
                        settings="$settings --conf spark.yarn.driver.memoryOverhead=$1"
                                ;;
        -ydmo )         shift
                        settings="$settings --conf spark.yarn.driver.memoryOverhead=$1"
                                ;;
        -yemo )         shift
                        settings="$settings --conf spark.yarn.driver.memoryOverhead=$1"
                                ;;
        -emo )          shift
                        settings="$settings --conf spark.executor.memoryOverhead=$1"
                                ;;
        -dmo )          shift
                        settings="$settings --conf spark.driver.memoryOverhead=$1"
                                ;;
        -all )          shift
                        settings="--driver-memory $dm --num-executors $ne --executor-memory $em --executor-cores $ec --conf \"spark.yarn.driver.memoryOverhead=$ydmo\" --conf \"spark.yarn.executor.memoryOverhead=$yemo\" --conf \"spark.executor.memoryOverhead=$emo\" --conf \"spark.driver.memoryOverhead=$dmo\" --conf spark.yarn.am.memory=$yamm"
                                ;;
    esac
    shift
done

execSpark="$sparkCommand $settings --master $master --deploy-mode $deployMode $applicationWithParameters"
$execSpark
echo $execSpark
