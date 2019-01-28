# Creating an Amazon AMI from scratch (ISO + kickstart)
=======

### Standard AWS Warning
This is a paid service, so be prepared to cough up a few bucks for hosting & instance time. That being said, if you still have the free tier available, this may not cost you any money, but no guarantees.


### Environment
Fedora 29 Host
Packer 1.3.3
Centos ISO CentOS-7-x86_64-DVD-1810.iso
ISO Hash (sha256): 6d44331cc4f6c506c7bbe9feb8468fad6c51a88ca1393ca6b8b486ea04bec3c1
AWS CLI Version: aws-cli/1.16.96 Python/2.7.15 Linux/4.20.3-200.fc29.x86_64 botocore/1.12.86
vboxmanage (VirtualBox) Version: 6.0.2r128162
Jinja Version: Jinja2-2.10 MarkupSafe-1.1.0
Python Version: Python 2.7.15

### Documentation Used
+ http://work.haufegroup.io/automate-ami-with-packer/
+ https://docs.aws.amazon.com/vm-import/latest/userguide/vmimport-image-import.html

tldr first, more explanation later

### Prereqs
1. Install Packer
https://www.packer.io/intro/getting-started/install.html#precompiled-binaries
2. Download a centos 7 ISO
http://isoredirect.centos.org/centos/7/isos/x86_64/CentOS-7-x86_64-DVD-1810.iso
3. Clone this repo
https://github.com/pthomison/packer-kickstart-to-ami.git
4. Install the aws cli tool
https://docs.aws.amazon.com/cli/latest/userguide/install-linux.html
5. Configure the aws cli tool
`$ aws configure`
6. Install VirtualBox
https://www.virtualbox.org/wiki/Linux_Downloads
7. Configure your system for VirtualBox
Given that its playing with kernel modules, I reboot a decent amount. Might not be necessary
```
$ yum install kernel-devel -y
$ (potentially) sudo systemctl reboot
$ sudo /sbin/vboxconfig
$ sudo systemctl reboot
```
8. Install Jinja2
http://jinja.pocoo.org/docs/2.10/intro/#installation
9. Create an S3 Bucket & Expose it publicly
(Note: If anyone knows an easy way to not expose it & have the import work, please hmu with a PR or github issue)
https://docs.aws.amazon.com/AmazonS3/latest/gsg/CreatingABucket.html


### Steps
1. Execute a build from project directory
`packer build packer-template.json`
2. Wait for this to complete the installation & build the image
3. Upload the image to your S3 Bucket
`aws s3 cp ./builds/centos-7-docker-machine.ova s3://<S3_BUCKET>/centos-7-docker-machine.ova`
4. Template necessary AWS objects
```
python2 template.py --s3-bucket <IMAGE_BUCKET> --image-file centos-7-docker-machine.ova
```
5. Create necessary AWS objects
```
aws iam create-role --role-name vmimport --assume-role-policy-document file://aws_config/trust-policy.json
aws iam put-role-policy --role-name vmimport --policy-name vmimport --policy-document file://aws_config/role-policy.json
```
6. Import the image
`aws ec2 import-image --description "centos-7-docker-machine.ova" --license-type BYOL --disk-containers file://aws_config/containers.json`
7. Monitor the import
`aws ec2 describe-import-image-tasks`
