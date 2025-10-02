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
    echo "Verify certificate"
    echo "Usage: cert-verify.sh <ca name> <name> <chain ? (0/1)>"
}

if [ "$3" = "" ]; then
    usage
    exit 1
fi

CANAME="$1"
NAME="$2"
USECACERTCHAIN="$3"

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
CACERTCHAINFILENAME=ca_"$CANAME"_chain.crt
CERTFILENAME="$NAME".crt

echo "Verifying certificate ..."
openssl x509 -noout -text -in "$BASEPATH"/"$CANAME"/data/certs/"$CERTFILENAME"

echo "Verifying certificate against CA ..."
if [ "$USECACERTCHAIN" = "1" ]; then
    openssl verify -CAfile "$BASEPATH"/"$CANAME"/data/certs/"$CACERTCHAINFILENAME" "$BASEPATH"/"$CANAME"/data/certs/"$CERTFILENAME"
else
    openssl verify -CAfile "$BASEPATH"/"$CANAME"/data/certs/"$CACERTFILENAME" "$BASEPATH"/"$CANAME"/data/certs/"$CERTFILENAME"
fi
retvalue=$?

exit $retvalue

