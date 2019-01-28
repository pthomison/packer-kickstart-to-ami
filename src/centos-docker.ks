#version=DEVEL
# System authorization information
auth --enableshadow --passalgo=sha512
# Use CDROM installation media
cdrom
# Use text install
text
# Run the Setup Agent on first boot
firstboot --enable
ignoredisk --only-use=sda
# Keyboard layouts
keyboard --vckeymap=us --xlayouts='us'
# System language
lang en_US.UTF-8
# agree to the eula
eula --agreed
reboot

# Network information
network  --bootproto=dhcp --device=eth0 --ipv6=auto --activate
network  --hostname=centos-docker-machine.tardis.kvm

# Root password
rootpw --iscrypted $6$Kk10Oar8YG8u9RRG$BX1SVhHtegDTTCuX.J.jEQavPlWfhOxn30QDiGYsXaTE659K9dhtC71CwHZBQIk4ewsRmvvlhUwyU2Gs6V3qn0
# System services
services --enabled="chronyd"
# System timezone
timezone America/New_York --isUtc
user --groups=wheel,docker --name=user --password=$6$e0.gCJPMrbLEpLgM$KFYiJm72EcbcJWUwmiBwwNXUYG234tTpGLvsil2.QNBgTMq6.nmqMGo67M4ovrwXuE0BP6eYxFBW1LZ2WDvGr/ --iscrypted --gecos="user"
# System bootloader configuration
bootloader --append=" crashkernel=auto" --location=mbr --boot-drive=sda
autopart --type=lvm
# Partition clearing information
clearpart --all --initlabel --drives=sda

repo --name="Base"    --baseurl="http://mirror.centos.org/centos/7/os/x86_64/"
repo --name="Extras"  --baseurl="http://mirror.centos.org/centos/7/extras/x86_64/"
repo --name="Updates" --baseurl="http://mirror.centos.org/centos/7/updates/x86_64/"

# repo --name="Base" --baseurl="http://127.0.0.1/repos/centos/7/base/"
# repo --name="Extras" --baseurl="http://127.0.0.1/repos/centos/7/extras/"
# repo --name="Updates" --baseurl="http://127.0.0.1/repos/centos/7/updates/"


%packages
@^minimal
@core
chrony
kexec-tools
docker

%end

%post

# Uses overlay2 by default
systemctl start docker
systemctl enable docker

%end

%addon com_redhat_kdump --enable --reserve-mb='auto'

%end

%anaconda
pwpolicy root --minlen=6 --minquality=1 --notstrict --nochanges --notempty
pwpolicy user --minlen=6 --minquality=1 --notstrict --nochanges --emptyok
pwpolicy luks --minlen=6 --minquality=1 --notstrict --nochanges --notempty

%end
