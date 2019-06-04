# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
	. "$HOME/.bashrc"
    fi
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi
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
export PYSPARK_DRIVER_PYTHON=ipython3
export PYSPARK_DRIVER_PYTHON_OPTS='notebook'

