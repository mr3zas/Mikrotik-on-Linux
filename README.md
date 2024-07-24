# Mikrotik on Linux VPS - Mirotik CHR Installer


# Introduction: 
Cloud Hosted Router (CHR) is a RouterOS version intended for running as a virtual machine. It supports the x86 64-bit architecture and can be used on most of the popular hypervisors such as VMWare, Hyper-V, VirtualBox, KVM, and others. CHR has full RouterOS features enabled by default but has a different licensing model than other RouterOS versions.


# How it works
CHR Licensing
- The CHR has 4 license levels:

1. Free	1Mbit
2. P1	1Gbit
3. P10	10Gbit
4. P-Unlimited	Unlimited
- The 60-day free trial license is available for all paid license levels. To get the free trial license, you have to have an account on MikroTik.com as all license management is done there.

Perpetual is a lifetime license (buy once, use forever). It is possible to transfer a perpetual license to another CHR instance. A running CHR instance will indicate the time when it has to access the account server to renew its license. If the CHR instance will not be able to renew the license it will behave as if the trial period has run out and will not allow an upgrade of RouterOS to a newer version.

After licensing a running trial system, you must manually run the /system license renew function from the CHR to make it active. Otherwise, the system will not know you have licensed it in your account. If you do not do this before the system deadline time, the trial will end and you will have to do a complete fresh CHR installation, request a new trial, and then license it with the license you had obtained.

# Requerments
- Ubuntu 20.04
- Ubuntu 22.04

# Installation Instructions

With this script, you can automatically install Mikrotik CHR on your VPS by inserting a download link: [Mikrotik Download Page](https://mikrotik.com/download/archive/) OR leave the link request empty to install version 7.8 by default.
# 

Note that, you have to choose the correct *.sh file based on your VPS provider. (for example: if you purchase the VPS from Hetzner then you have to copy Hetzner.sh file content to the server)

#

Copy the content of the attached ( *.sh ) file based on your VPS host and run the below commands
- Step 1 
```
chmod +x specific VPS file.sh
```
- Step 2
```
./specific VPS file.sh
```
- Example:
```
1- nano Hetzner.sh ----> copy attached Hetzner.sh file content to server
2- chmod +x Hetzner.sh
3- ./Hetzner.sh
```
Server will restart after the installation is done, then connect to server via Winbox
# 
- Username: admin
- Password: (leave it blank)
# 

Winbox Downlod links [64bit](https://mt.lv/winbox64) [32bit](https://mt.lv/winbox)






