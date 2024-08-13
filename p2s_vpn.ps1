# Step 1: Generate the Root Certificate Authority (CA)
$rootKeyPath = "root.key"
$rootCrtPath = "root.crt"

openssl genrsa -out $rootKeyPath 4096
openssl req -x509 -new -nodes -key $rootKeyPath -sha256 -days 3650 -out $rootCrtPath

# Step 2: Generate the Client Certificate and Key
$clientKeyPath = "client.key"
$clientCsrPath = "client.csr"
$clientCrtPath = "client.crt"

openssl genrsa -out $clientKeyPath 2048
openssl req -new -key $clientKeyPath -out $clientCsrPath
openssl x509 -req -in $clientCsrPath -CA $rootCrtPath -CAkey $rootKeyPath -CAcreateserial -out $clientCrtPath -days 365

# Step 3: Upload the Root Certificate to Azure
$rootCertName = "RootCertificate"
$rootCertData = Get-Content -Raw -Path $rootCrtPath

New-AzVpnClientRootCertificate -Name $rootCertName -PublicCertData $rootCertData
