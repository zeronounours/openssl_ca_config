Root CA Certificate
===================

This section explains how to manage a root CA certificate.


Generate the certificate
------------------------

### Configuration

All the need configuration is located in the file [root_ca.cnf][root_ca]. Make
sure you have adapted the configuration to your needs. Here are some fields
which must be changed:
```bash
[rdn]
countryName = XX
localityName = city
organizationName = organization
organizationalUnitName = CA origanization unit
commonName = organization Root CA
emailAddress = admin@example.com
```

All fields in `rnd` section identified the certificate and the organisation
which issues it. Be sure of your `organizationName` because further
configuration will force all signed certificate to have the same
`organizationName`.


### Preparation

Before creating the root CA certificate, you must created some files used by
openSSL. Be sure to be in `rootCA/` directory first.
```bash
touch ca_files/index.txt
```

You also need to configure the openSSL. Take a look at `openssl.cnf` and
modify at least the following in both sections `x509_exts` and `v3_root_ca`:
```bash
crlDistributionPoints           = URI:http://crl.example.com/root_ca.crl
authorityInfoAccess             = OCSP;URI:http://ocsp.example.com:82/
```


### Generation

We are now ready to generate the root CA certificate:
```bash
openssl req -config root_ca.cnf -new -out requests/root_ca.csr
mv private/root_ca.key.new private/root_ca.key
chmod 400 private/root_ca.key
openssl ca -create_serial -config openssl.cnf -out certs/root_ca.crt -days 3650 -batch -keyfile private/root_ca.key -selfsign -extensions v3_root_ca -infiles requests/root_ca.csr
```


Issue CA certificates
---------------------

Everything is now ready to issue a CA certificate.


### Generate a Certificate Signing Request (CSR)

We first need to generate the request that will be signed later. Be sure you
have modified the configuration file for this CA: [web_ca.cnf][web_ca]. Like
the root CA certificate the whole section `rdn` must be changed. Remember that
`countryName` and `organizationName` must be the same as ones of the root CA.

When you're ready enter:
```bash
openssl req -config web_ca.cnf -new -out requests/web_ca.csr
chmod 400 private/web_ca.key.new
```

You can verify that that CSR has successfully been issued in `requests/`.


### Revoke a previously issued certificate

__It is very important to revoke previously issued certificates. If not the
certificate signing may fail leaving your openSSL configuration in an unstable
state from which it may be difficult to recover.__

If there is a certificate with the same commonName as the requested one, you
must revoke it. To do so, execute:
```bash
openssl ca -config openssl.cnf -revoke certs/web_ca.crt
```

You may want to keep a trace of this certificate intead of removing it. In that
case, you should copy it in a separate directory (such as `certs/revoked/`)
using this filename format: `web_ca.crt.YYYY.MM.DD` where `YYYY` is the year,
`MM` is the month and `DD` is the day.


### Issue the certificate

Everything is now ready to generate the certificate.

First thing to do is to check the request you're about to sign:
```bash
openssl req -in requests/web_ca.csr -noout -text
```

If everything is normal and the request has not been altered, you can issue the
certificate:
```bash
openssl ca -config openssl.cnf -in requests/web_ca.csr -out certs/web_ca.crt
```

You have now a brand new CA certificate located in `certs/`. Don't forget to
rename the private key from `web_ca.key.new` to `web_ca.key`.


### Renew the Certificate Revocation List (CRL)

You may regenerate the CRL. This must be done for the first issued certificate
and whenever you rekove a certificate.
```bash
openssl ca -config openssl.cnf -gencrl -out ca_files/crl/crl.pem
```

Then provide the generated CRL to your CRL distribution point.


_Note_: You have generated here a certificate called web_ca, but the name
doesn't matter. You could have issued any other certificate.


Generate OCSP certificate
-------------------------

Follow the instructions of [the previous part](#issue-ca-certificates), but
instead of using `web_ca.cnf` configuration, use `ocsp.cnf`.

In the step _[Issue the certificate](#issue-the-certificate)_ use instead the
command:
```bash
openssl ca -config openssl.cnf -in requests/ocsp.csr -out certs/ocsp.crt -extensions v3_ocsp -days 365
```


Useful commands
---------------

Here is a list of useful commands to get information about a certificate. In
this example we get information about `web_ca.crt`

- Get details:
```bash
openssl x509 -in certs/web_ca.crt -noout -text
```

- Get the sha1 fingerprints:
```bash
openssl x509 -in certs/web_ca.crt -noout -fingerprint -sha1
```
`sha1` may be replaced by `md5` to get th md5 fingerprint.

- Remove the passphrase of the key:
```bash
cp private/web_ca.key private/wab_ca.key.orig
openssl rsa -in private/web_ca.key -out private/web_ca.key
```
The copy of the key is for security reason, in case the next command fails.


Understand index.txt
--------------------

The file `ca_config/index.txt` contains the list of all certificates issued by
the root CA. It's composed of 6 columns separated by tabulations ("\t").

**/!\ This file is important, don't break it! If you're not sure, make a copy
/!\**

- column 1 :
  * __V__ for _valid_
  * __R__ for _revoked_
  * ( __E__ for _expired_, not used)

- column 2 :
Date of expiration of the certificat formatted as such: `yymmddhhmmssZ`.
The time is UTC.

- column 3 :
Date of revocation of the certificat, if applicable, formatted as such:
 `yymmddhhmmssZ`.
The time is UTC.

- column 4 :
Serial number of the certificate (hexadecimal number)

- column 5 :
"unknown", depreciated field

- column 6 :
Subject of the certificate


[root_ca]: root_ca.cnf
[web_ca]: web_ca.cnf
