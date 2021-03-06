#!/bin/bash

# Copyright 2017 The Openstack-Helm Authors.
#
#    Licensed under the Apache License, Version 2.0 (the "License"); you may
#    not use this file except in compliance with the License. You may obtain
#    a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#    License for the specific language governing permissions and limitations
#    under the License.

set -xe

#NOTE: Deploy global ingress
helm install ./ingress \
  --namespace=kube-system \
  --name=ingress-kube-system \
  --set pod.replicas.error_page=2 \
  --set deployment.mode=cluster \
  --set deployment.type=DaemonSet \
  --set network.host_namespace=true \
  --set conf.services.udp.53='kube-system/kube-dns:53'

#NOTE: Deploy namespace ingress
helm install ./ingress \
  --namespace=openstack \
  --name=ingress-openstack \
  --set pod.replicas.ingress=2 \
  --set pod.replicas.error_page=2

#NOTE: Wait for deploy
./tools/deployment/common/wait-for-pods.sh kube-system
./tools/deployment/common/wait-for-pods.sh openstack

#NOTE: Display info
helm status ingress-kube-system
helm status ingress-openstack
