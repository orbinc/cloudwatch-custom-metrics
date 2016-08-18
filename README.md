# CloudWatch Custom Metrics

This repo is a collection of Amazon CloudWatch Custom Scripts. Target OS is [Amazon Linux](https://aws.amazon.com/amazon-linux-ami/).

* `listening-port-count.sh` - Check if a given port number is listening on the server
* `process-countsh` - Check how many processes of a given name are running on the server

## Install

### Prerequisites

Following software is needed to deploy custom scripts to EC2.

* Ansible 2.0.0.2
* SSH Client (+ `ssh-agent`)

### Preparation

* Copy following templates:
  * `secrets.yml.tpl` to `secrets.yml`
  * `ssh.cfg.tpl` to `ssh.cfg`

Modify configuration parameters in both `secrets.yml` and `ssh.cfg`.

Run following commands:

```
$ eval $(ssh-agent)
$ ssh-add ~/.ssh/your_id_rsa
```

### Install with Ansible

Just type following command (`xxx.xxx.xxx.xxx` is an IP address to provision):

```
$ ansible-playbook cloudwatch-custom-metrics.yml -i xxx.xxx.xxx.xxx,
```
