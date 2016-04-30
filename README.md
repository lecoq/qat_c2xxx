qat_c2xxx
=======

This version currently works only for the Intel Atom C2000 (Rangeley) Platform, using Ubuntu 16.04 (Xenial).

Derived from Intel QAT1.5 Reference Driver, available at: https://01.org/packet-processing/intel%C2%AE-quickassist-technology-drivers-and-patches

## Build

Requires gcc, libssl-dev, zlib1g-dev, linux-headers, systemd
Optional: dkms

Basic install
```
$ git clone https://github.com/lecoq/qat_c2xxx
$ cd qat_c2xxx
$ make
```

## Installation

To install the kernel modules and API:

```
$ sudo make install
```

## DKMS Automatic kmod updates

If you would like to automatically rebuild this kernel module each time you install or update your local kernel, using DKMS will allow you
to automate the process so the module will be rebuilt on boot if the kernel version changes.

``
$ cd qat_c2xxx
$ sudo dkms add .
$ sudo dkms build qat_c2xxx/1.11.0-36
```

Verify that quickassist service is operational:

```
$ systemctl status quickassist
```
