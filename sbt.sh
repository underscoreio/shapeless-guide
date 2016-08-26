#!/usr/bin/env bash

export JAVA_OPTS="-Xmx3g -XX:+TieredCompilation -XX:ReservedCodeCacheSize=256m -XX:+UseNUMA -XX:+UseParallelGC -XX:+CMSClassUnloadingEnabled"

sbt "$@"
