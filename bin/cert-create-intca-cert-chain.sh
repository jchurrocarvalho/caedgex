#!/bin/bash

#
# Released under MIT License
# Copyright (c) 2019-2023 Jose Manuel Churro Carvalho
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software 
# and associated documentation files (the "Software"), to deal in the Software without restriction, 
# including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, 
# and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, 
# INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, 
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#

usage()
{
    echo "Create intermediate CA certificates chain"
    echo "Usage: cert-create-intca-cert-chain.sh <ca name> <intca name 1> <int ...> (until root CA))"
}

if [ "$2" = "" ]; then
    usage
    exit 1
fi

CANAME="$1"

BASEPATH=""

#
if [ -z "$PKICA_CA_HOME" ]; then
    echo "Environment variable PKICA_CA_HOME can not be empty or undefined."
    exit 1
else
    BASEPATH="$PKICA_CA_HOME"
fi

# double check ...
if [ -z "$BASEPATH" ]; then
    echo "Error! BASEPATH can not be empty!"
    exit 1
fi

echo "Working in: $BASEPATH ..."
#

CACERTFILENAME=ca_"$CANAME".crt
CACERTPATHFILENAME="$BASEPATH"/"$CANAME"/data/certs/"$CACERTFILENAME"
CACERTCHAINFILENAME=ca_"$CANAME"_chain.crt
CACERTCHAINPATHFILENAME="$BASEPATH"/"$CANAME"/data/certs/"$CACERTCHAINFILENAME"

intca_pathfilename=""

echo "cat from $CACERTPATHFILENAME to $CACERTCHAINPATHFILENAME"
echo "# $CANAME" > "$CACERTCHAINPATHFILENAME"
cat "$CACERTPATHFILENAME" >> "$CACERTCHAINPATHFILENAME"

retvalue=0
i=0

for arg in "$@"
do
    if [ $i -ge 1 ]; then
        intca_pathfilename="$BASEPATH"/"$arg"/data/certs/ca_"$arg".crt
        echo "cat append from $intca_pathfilename to $CACERTCHAINPATHFILENAME"
        echo "# $arg" >> "$CACERTCHAINPATHFILENAME"
        cat "$intca_pathfilename" >> "$CACERTCHAINPATHFILENAME"
        retvalue=$?
        if [ "$retvalue" != "0" ]; then
            break
        fi
    fi
    i=$((i+1))
done
chmod 644 "$CACERTCHAINPATHFILENAME"

exit $retvalue

