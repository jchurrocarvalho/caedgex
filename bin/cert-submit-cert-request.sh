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
    echo "Submit request for certificate creation with extension section"
    echo "Usage: cert-submit-cert-request.sh <ca name> <name> <extension filename [optional]>"
    echo ""
    echo "Without extension filename server_cert configuration from CA will be used."
    echo "If you want to supply extension file, create one with content similar:"
    echo ""
    echo "authorityKeyIdentifier = keyid, issuer"
    echo "basicConstraints = CA:false"
    echo "keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment"
    echo "subjectAltName = @alt_names"
    echo ""
    echo "[alt_names]"
    echo "DNS.1 = www.domain.com"
    echo "DNS.2 = www2.domain.com"
    echo ""
}

if [ "$3" = "" ]; then
    usage
    exit 1
fi

CANAME="$1"
NAME="$2"

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

CACONFFILENAME=ca.conf

CERTFILENAME="$NAME".crt
REQFILENAME="$NAME".csr

if [ "$4" = "" ]; then
    EXTFILENAME=""
else
    EXTFILENAME="$4"
fi

# -extensions server_cert
if [ "$EXTFILENAME" = "" ]; then
    openssl ca -config "$BASEPATH"/"$CANAME"/conf/"$CACONFFILENAME" \
        -notext \
        -extensions server_cert_ext \
        -in "$BASEPATH"/"$CANAME"/data/csr/"$REQFILENAME" \
        -out "$BASEPATH"/"$CANAME"/data/certs/"$CERTFILENAME"
else
    openssl ca -config "$BASEPATH"/"$CANAME"/conf/"$CACONFFILENAME" \
        -notext \
        -extfile "$EXTFILENAME" \
        -in "$BASEPATH"/"$CANAME"/data/csr/"$REQFILENAME" \
        -out "$BASEPATH"/"$CANAME"/data/certs/"$CERTFILENAME"
fi
retvalue=$?
chmod 644 "$BASEPATH"/"$CANAME"/data/certs/"$CERTFILENAME"

exit $retvalue

