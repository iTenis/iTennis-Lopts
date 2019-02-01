#!/bin/bash

v=`git rev-list HEAD | wc -l`
sed -i "s/VERSION.*$/VERSION=3.$v/g" conf/itennis.conf
git pull
git status
