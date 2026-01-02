#!/usr/bin/env bash

saxon -s:in/sac-sample.xml -xsl:xsl/to-keepass.xsl -o:out/to-keepass.xml "dbname=sac-sample" "dbdesc=some description"

keepassxc-cli db-create 