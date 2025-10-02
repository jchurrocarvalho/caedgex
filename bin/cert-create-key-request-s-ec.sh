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
    echo "Cert create key and request for certificate with no input already supplying subject and subjectAltName (use ec for key)"
    echo "Usage: cert-create-key-request-s-ec.sh <ca name> <name> <EC parameters curve to use (ex: P-384)>"
    echo "       <req section (ex: req_client)> <extension section (ex: req_client_ext)>"
    echo "       <emailAddress>"
    echo "       <subjectAltName (ex: DNS:host.domain ex: email:move) [optional]> ..."
}

if [ "$7" = "" ]; then
    usage
    exit 1
fi

CANAME="$1"
NAME="$2"
ECPARAMCURVE="$3"
REQSECNAME="$4"
EXTSECNAME="$5"
EMAILADDRESS="$6"

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

KEYFILENAME="$NAME".key
REQFILENAME="$NAME".csr

subject_alt_name_args=""

i=0

for arg in "$@"
do
    if [ $i -ge 6 ]; then
        if [ "$subject_alt_name_args" != "" ]; then
            subject_alt_name_args+=", "
        fi
        #subject_alt_name_args+="DNS:"
        subject_alt_name_args+="$arg"
    fi
    i=$((i+1))
done

#    -addext "authorityKeyIdentifier = keyid, issuer" \
#    -addext "basicConstraints = CA:false" \
#    -addext "keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment" \

openssl genpkey \
    -algorithm EC -pkeyopt ec_paramgen_curve:"$ECPARAMCURVE" -pkeyopt ec_param_enc:named_curve \
    -out "$BASEPATH"/"$CANAME"/data/private/"$KEYFILENAME"
retvalue=$?

if [ "$retvalue" != "0" ]; then
    echo "openssl genpkey for ec curve returned an error: $retvalue"
    exit $retvalue
fi

chmod 400 "$BASEPATH"/"$CANAME"/data/private/"$KEYFILENAME"
openssl req -config "$BASEPATH"/"$CANAME"/conf/"$CACONFFILENAME" \
    -new \
    -section "$REQSECNAME" \
    -extensions "$EXTSECNAME" \
    -subj "/C="PT"/ST="Lisbon"/L="Lisbon"/O="IT"/OU="IT"/CN=$NAME/emailAddress=$EMAILADDRESS" \
    -addext "subjectAltName = $subject_alt_name_args" \
    -key "$BASEPATH"/"$CANAME"/data/private/"$KEYFILENAME" \
    -out "$BASEPATH"/"$CANAME"/data/csr/"$REQFILENAME"
retvalue=$?
chmod 640 "$BASEPATH"/"$CANAME"/data/csr/"$REQFILENAME"

exit $retvalue

