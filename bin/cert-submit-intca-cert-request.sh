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
    echo "Submit request to parent CA for intermediate CA certificate creation"
    echo "Usage: cert-submit-intca-cert-request.sh <ca name> <intca name> <extension section (ex: ca_ext, int_ca_ext, int_ca_issuer_ext)>"
}

if [ "$3" = "" ]; then
    usage
    exit 1
fi

CANAME="$1"
CAINTNAME="$2"
EXTSECNAME="$3"

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

CERTFILENAME=ca_"$CAINTNAME".crt
REQFILENAME=ca_"$CAINTNAME".csr

echo "Submiting request to parent CA for intermediate CA certificate creation ... ($CANAME and $CAINTNAME)"
openssl ca -config "$BASEPATH"/"$CANAME"/conf/"$CACONFFILENAME" \
    -notext \
    -extensions "$EXTSECNAME" \
    -in "$BASEPATH"/"$CAINTNAME"/data/csr/"$REQFILENAME" \
    -out "$BASEPATH"/"$CAINTNAME"/data/certs/"$CERTFILENAME"
retvalue=$?
chmod 644 "$BASEPATH"/"$CAINTNAME"/data/certs/"$CERTFILENAME"

exit $retvalue

