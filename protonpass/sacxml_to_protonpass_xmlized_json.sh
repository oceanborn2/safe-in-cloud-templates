#!/bin/bash

#shred -u -x -n 20 printable.fo printable.pdf
saxon in.xml -xsl:convert.xsl -o:output_data.json


