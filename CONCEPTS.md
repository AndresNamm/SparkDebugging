

# SPARK PARALLELIZATION GENERAL CONCEPTS

+ Concept Summary - taken directly from references
  + Spark RDD/DF 
  + Spark spawns a single Task for a single partition, which will run inside the executor JVM.
  + Spark single partition is located in a single machine 
  + A Stage is a combination of transformations which does not cause any shuffling, pipelining as many narrow transformations (eg: map, filter etc) as possible.
  + Each stage contains as many tasks as partitions of the RDD 
    + [Based on other resource this seems to refer that 1 spark task can have multiple transfomations in it filter->map](https://stackoverflow.com/questions/37528047/how-are-stages-split-into-tasks-in-spark)
    + [Spark book author stackoverflow](https://stackoverflow.com/questions/28843591/spark-filter-within-map) Says If you use ...filter().map(), they will be executed in the same task for each partition, analogous to chaining "mappers" in MapReduce. 
  + RDDs are not mapped to executors. Multiple partitions from an RDD may be served by multiple tasks which may belong to multiple executors.
+ [My draw.io scheme on How Dataframes and RDDs comprise of partitions which is the parallelization unit in Spark](https://drive.google.com/file/d/14k8NNpXD-LfoAddbX9SpkNPyJEHWh9jL/view?usp=sharing)
+ References 
  + [Spark partitioning explanation](https://medium.com/@thejasbabu/spark-under-the-hood-partition-d386aaaa26b7#:~:text=Spark%20spawns%20a%20single%20Task,etc)%20pipelined%20in%20the%20stage.)
  + [Spark partitioning QA format](https://stackoverflow.com/questions/39324807/spark-executors-tasks#:~:text=Number%20of%20executors%20is%20managed,coalesce%2Frepartition%20functions%20in%20spark.)
  + [How spark internatlly executes a protram]


# SPARK JOINS 


## Concepts  

+ From my understanding it seems that both sort merge join and shuffle hash join 1. partition the data but in 2. step the shuffle join creates an hash table (For 1 partition) where shuffle join relies on sorted lists and merging the data. **Mostly sorts merge join is preferred** 


## References 

+ [Databricks video explanation on Spark join optimization](https://databricks.com/session/optimizing-apache-spark-sql-joins)
+ Medium articles about Spark joins
  + [Spark join examples 1](https://medium.com/@achilleus/https-medium-com-joins-in-apache-spark-part-1-dabbf3475690)
  + [Spark join examples 2](https://medium.com/@achilleus/https-medium-com-joins-in-apache-spark-part-2-5b038bc7455b)
  + [Spark join optimization](https://medium.com/@achilleus/https-medium-com-joins-in-apache-spark-part-3-1d40c1e51e1c)
    + Sort merge join [More thorough explantaion](https://www.waitingforcode.com/apache-spark-sql/sort-merge-join-spark-sql/read)
    + Shuffle Hash join, [More thorough explanation](https://www.waitingforcode.com/apache-spark-sql/shuffle-join-spark-sql/read) 
    + Broadcast Hash join
  + [Different join stategies](https://towardsdatascience.com/strategies-of-spark-join-c0e7b4572bcf)

