---
title: "README"
---
# Purpose

The scripts in this repos are made to make spark Debugging as easy as possible. 


# ExecutorSizing 

This piece of code is a simplistic helper to size your spark executors correctly based on certain limits. Its based on this wonderful [article](https://www.c2fo.io/c2fo/spark/aws/emr/2016/07/06/apache-spark-config-cheatsheet/)
# Ipython 

Gives certain guidance on how to setup Ipython notebook with Spark and Yarn 
# MemoryTesting 

When running Spark on yarn i faced many times spark executors dying while performing certain computations. The overall issue likely is Java 8 requesting too much virtual memory and in this folder im debugging this issue more thoroughly.  