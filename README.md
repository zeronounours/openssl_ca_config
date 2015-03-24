OpenSSL Config
==============

This project is a basic configuration for openSSL to handle a your domains 
through CA certificates.

This configuration allow you to create a root CA certificate which can then sign
sub CA certificate that can be trusted due to domains restriction. It still
allows you to sign any domain thanks to the root CA which isn't restricted.

__/!\ As the root CA isn't restricted to a domain, it may not be distributed
to people for them to trust it. It's better to distribute sub CA which are 
restricted. /!\__


Root CA Certificate
-------------------

Root CA certificate management need to be done in the folder `rootCA/`.

To know how to manage it, please refer to the [dedicated README][root_ca]. You
can also get this informations in the wiki.


Sub CA Certificate
------------------

An example of sub CA certificate management is given in the folder `webCA/`.

To know how to manage it, please refer to the [dedicated README][web_ca]. You
can also get this informations in the wiki.

_Note_: This sub CA certificate has been first issue in using the Root CA
certificate. See [Root CA Certificate](#root-ca-certificate) to learn how to do.


OCSP server
-----------

In order to distribute information about valid certificates, you may want to 
use an OCSP server.

An example is given for both [root CA][root_ca_ocsp] and [sub CA][web_ca_ocsp]
to know how to issue OCSP certificate needed for the server.

Then you need to install the script which will take care that OCSP servers stay
on and the init script to launch it.
```bash
sudo cp install/ocsp.sh /root/
sudo cp install/ocsp /etc/init.d/
sudo insserv ocsp
```

You can now start the server:
```bash
sudo service ocsp start
```


[root_ca]: rootCA/README.md
[web_ca]: webCA/README.md
[root_ca_ocsp]: rootCA/README.md#generate-ocsp-certificate
[web_ca_ocsp]: webCA/README.md#generate-ocsp-certificate
