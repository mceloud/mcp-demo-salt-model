#!/bin/bash

TEST="False"

# Control
# 

salt 'cfg01.mirantis_demo.local' state.sls salt.master,reclass test=$TEST
salt 'cfg01.mirantis_demo.local' state.sls salt.minion test=$TEST

salt 'ctl*.mirantis_demo.local' test.ping
salt 'ctl*.mirantis_demo.local' state.sls linux,openssh,ntp,salt.minion test=$TEST

## Install keepalived
salt 'ctl*.mirantis_demo.local' --batch-size 1 state.sls keepalived.cluster test=$TEST

## Install haproxy
salt 'ctl*.mirantis_demo.local' state.sls haproxy test=$TEST
salt 'ctl*.mirantis_demo.local' service.status haproxy

## Install docker
salt 'ctl*.mirantis_demo.local' state.sls docker.host test=$TEST
salt 'ctl*.mirantis_demo.local' cmd.run "docker ps"

## Install etcd
salt 'ctl*.mirantis_demo.local' state.sls etcd.server.service test=$TEST
salt 'ctl*.mirantis_demo.local' cmd.run "etcdctl cluster-health"

## Install Kubernetes and Calico
salt 'ctl*.mirantis_demo.local' state.sls kubernetes.master.kube-addons test=$TEST
salt 'ctl*.mirantis_demo.local' state.sls kubernetes.pool test=$TEST
salt 'ctl*.mirantis_demo.local' cmd.run "calicoctl node status"

## Setup NAT for Calico
salt 'ctl01.mirantis_demo.local' --subset 1 state.sls etcd.server.setup test=$TEST

## Run whole master to check consistency
salt 'ctl*.mirantis_demo.local' state.sls kubernetes exclude=kubernetes.master.setup test=$TEST

## Register addons
salt 'ctl*.mirantis_demo.local' --subset 1 state.sls kubernetes.master.setup test=$TEST

# Compute
#
