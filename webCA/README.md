CA Certificate
==============

This section explains how to manage a CA certificate to sign final certificates


Generate the certificate
------------------------

To generate the CA certificate to use, please refer to the dedicated section in
[Root CA Certificate README](../rootCA/README.md#issue_ca_certificate).


Issue a certificates
---------------------

Once you have the CA certificate, you're ready to issue a certificate. The steps
are very similar the steps you followed to generate your CA certificate.

For the first time, you may change the configuration of `openssl.cnf`, and
create the file `index.txt`.

### Generate a Certificate Signing Request (CSR)

We first need to generate the request that will be signed later. Be sure you
have modified the configuration file for this certificate: [example.cnf][example].
The whole section `rdn` must be changed. Remember that `countryName` and
 `organizationName` must be the same as ones of your CA.

When you're ready enter:
```bash
openssl req -config example.cnf -new -out requests/example.csr
chmod 400 private/example.key.new
```

You can verify that that CSR has successfully been issued in `requests/`.


### Revoke a previously issued certificate

__It is very important to revoke previously issued certificates. If not the
certificate signing may fail leaving your openSSL configuration in an unstable
state from which it may be difficult to recover.__

If there is a certificate with the same commonName as the requested one, you
must revoke it. To do so, execute:
```bash
openssl ca -config openssl.cnf -revoke certs/example.crt
```

You may want to keep a trace of this certificate intead of removing it. In that
case, you should copy it in a separate directory (such as `certs/revoked/`)
using this filename format: `example.crt.YYYY.MM.DD` where `YYYY` is the year,
`MM` is the month and `DD` is the day.


### Issue the certificate

Everything is now ready to generate the certificate.

First thing to do is to check the request you're about to sign:
```bash
openssl req -in requests/example.csr -noout -text
```

If everything is normal and the request has not been altered, you can issue the
certificate:
```bash
openssl ca -config openssl.cnf -in requests/example.csr -out certs/example.crt
```

_Note_: For the first certificate, you also need to create the serial by adding
 `-create_serial` to the previous command. If you don't do so, you'll end up 
 with an error.

You have now a brand new CA certificate located in `certs/`. Don't forget to
rename the private key from `example.key.new` to `example.key`.


### Renew the Certificate Revocation List (CRL)

You may regenerate the CRL. This must be done for the first issued certificate
and whenever you rekove a certificate.
```bash
openssl ca -config openssl.cnf -gencrl -out ca_files/crl/crl.pem
```

Then provide the generated CRL to your CRL distribution point.


_Note_: You have generated here a certificate called example, but the name
doesn't matter. You could have issued any other certificate.


Useful commands
---------------

Here is a list of useful commands to get information about a certificate. In
this example we get information about `example.crt`

- Get details:
```bash
openssl x509 -in certs/example.crt -noout -text
```

- Get the sha1 fingerprints:
```bash
openssl x509 -in certs/example.crt -noout -fingerprint -sha1
```
`sha1` may be replaced by `md5` to get th md5 fingerprint.

- Remove the passphrase of the key:
```bash
cp private/example.key private/example.key.orig
openssl rsa -in private/example.key -out private/example.key
```
The copy of the key is for security reason, in case the next command fails.


[example]: example.cnf
