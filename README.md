qat_c2xxx
=======

This version currently works only for the Intel Atom C2000 (Rangeley) Platform. It has been tested on Ubuntu 16.04 (Xenial).

Derived from Intel QAT1.5 Reference Driver, available at: https://01.org/packet-processing/intel%C2%AE-quickassist-technology-drivers-and-patches

This driver provides the QAT API, and can be used via OpenSSL ( https://github.com/01org/QAT_Engine) or via DPDK's cryptodev functionality.

## Installation

Requires dkms, gcc, libssl-dev, zlib1g-dev, linux-headers, systemd

```
$ git clone https://github.com/lecoq/qat_c2xxx
$ cd qat_c2xxx
$ sudo make install
```
## 
Verify that quickassist service is operational:

```
$ systemctl status quickassist
$ sudo cat /proc/icp_c2xxx_dev0/qat0
```
