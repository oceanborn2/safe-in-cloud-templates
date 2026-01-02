#!/bin/bash

yq --xml-content-name database --xml-skip-directives  --xml-skip-proc-inst '.database.[] |to_yaml()' in.xml > in.yaml
