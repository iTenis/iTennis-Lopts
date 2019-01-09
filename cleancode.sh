#!/bin/bash
for i in `find . -name *.log`; do rm -rf $i; done
rm -rf from_iso/*.iso
rm -rf to_iso/*.iso
rm -rf datas/*
