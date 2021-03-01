import pyspark


def find_closest(nr):
    arr = [512*i for i in range(1,10)]
    min_val=1000000
    min_index=1
    for i in range(len(arr)):
        el=arr[i]
        if(math.fabs(el-nr)<min_val ):
            min_index = i
            min_val = math.fabs(el-nr)
    return arr[min_index]

find_closest(900)

def get_spark_conf_performance(spark_executor_instances=6,spark_executor_memory_gb=6,spark_executor_cores=2):
    g1=1024
    spark_executor_memory=spark_executor_memory_gb
    core_parallelism=1
    spark_driver_memory= int((spark_executor_memory*0.75)) # IN MY SETUP THESE 2 ARE EQUAL
    spark_executor_memoryOverhead=find_closest(spark_executor_memory*g1*0.1)
    spark_driver_memoryOverhead= find_closest(spark_driver_memory*g1*0.1)
    total_memory =  spark_executor_instances * (spark_executor_memory*g1 + spark_executor_memoryOverhead) + (spark_driver_memory*g1 + spark_driver_memoryOverhead)
    print("Total memory used:")
    print(total_memory)
    print("Total nr of CPU used")
    print(str(spark_executor_instances*spark_executor_cores))
    find_closest(spark_executor_memory*g1*0.1)
    mode="client" # BECAUSE WE ARE DEPLOYING THIS THROUGH JUPYTER
    sei = ('spark.executor.instances', spark_executor_instances)
    sem = ('spark.executor.memory', str(spark_executor_memory)+'g')
    sec = ('spark.executor.cores', spark_executor_cores)
    semo = ('spark.executor.memoryOverhead',spark_executor_memoryOverhead)
    sdm = ('spark.driver.memory',str(spark_driver_memory)+'g')
    sdmo = ('spark.driver.memoryOverhead',spark_driver_memoryOverhead)
    syam =  ('spark.yarn.am.memory',str(spark_driver_memory)+'g')
    syamo = ('spark.yarn.am.memoryOverhead',spark_driver_memoryOverhead)
    sdc = ('spark.driver.cores','1')
    sdp = ('spark.default.parallelism', spark_executor_cores*spark_executor_instances*core_parallelism) # PARALLELISM = nr_executors * nr_cores_in_executor * parallelism_in_core 
    conf = ""
    confs = [sei,sem,sec,semo,sdm,sdmo,syam,syamo,sdc,sdp] 
    print(confs)
    return confs

def get_spark_speculating_confs():
    spec1 = ('spark.speculation','true')
    #spec2 = ('spark.speculation.interval', '10')
    spec2 = ('spark.speculation.multiplier',2)
    spec3 = ('spark.speculation.quantile', 0.5)
    return [spec1,spec2,spec3]

def get_hive_confs():
    # FROM BEELINE 
    #https://stackoverflow.com/questions/60054700/spark-2-3-to-spark-2-4-upgrade-problems-reading-hive-partitioned-tables
    confs =[("spark.hadoop.metastore.catalog.default","hive")]
    return confs

def get_hwc_confs():
    jar = ('spark.jars','/usr/hdp/current/hive_warehouse_connector/hive-warehouse-connector-assembly-1.0.0.3.1.0.127-1.jar')
    py_files = ('spark.submit.pyFiles','/usr/hdp/current/hive_warehouse_connector/pyspark_hwc-1.0.0.3.1.0.127-1.zip')
    return [jar,py_files]


san = ('spark.app.name', 'spark_demo_app')
all_confs = [san] 

## Add optimization configurations

optimization_confs = get_spark_conf_performance(14,8,4)
all_confs = all_confs + optimization_confs 
all_confs = all_confs + get_spark_speculating_confs()

## Add HWC confs

hwc_confs = get_hwc_confs()
all_confs = all_confs + hwc_confs
all_confs = all_confs + get_hive_confs()

## Set the confs array to be included to the SparkConf

spark_conf = pyspark.SparkConf()
spark_conf.setAll(all_confs)
spark_conf.getAll()