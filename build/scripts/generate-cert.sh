#! /bin/bash
CERTS_DIR="./src/_cert"
CERT_NAME="dev.genguid.com"
HOST="dev.genguid.com"

mkdir -p $CERTS_DIR

rm -f "$CERTS_DIR/$CERT_NAME.key" "$CERTS_DIR/$CERT_NAME.crt"

cat > "$CERTS_DIR/$CERT_NAME.conf" <<EOF
[req]
x509_extensions = v3_req
distinguished_name = dn
[dn]
countryName                 = New Zealand
countryName_default         = NZ
stateOrProvinceName         = Wellington
stateOrProvinceName_default = WEL
localityName                = Business
localityName_default        = Jobot Software
commonName                  = Common Name
commonName_default          = $HOST
[v3_req]
subjectAltName = @alt_names
[alt_names]
DNS.1 = localhost
DNS.2 = *.localhost
DNS.3 = $HOST
DNS.4 = *.$HOST
EOF

openssl req \
    -new \
    -x509 \
    -sha256 \
    -newkey rsa:2048 \
    -nodes \
    -keyout "$CERTS_DIR/$CERT_NAME.key" \
    -days 3650 \
    -out "$CERTS_DIR/$CERT_NAME.crt" \
    -config "$CERTS_DIR/$CERT_NAME.conf"

rm -f "$CERTS_DIR/$CERT_NAME.conf"

powershell ./build/scripts/install-cert.ps1
