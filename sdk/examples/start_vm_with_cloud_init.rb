#!/usr/bin/ruby

#
# Copyright (c) 2016 Red Hat, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'logger'
require 'ovirtsdk4'

# This example will connect to the server and start a virtual machine
# with cloud-init, in order to automatically configure the network and
# the password of the `root` user.

# Create the connection to the server:
connection = OvirtSDK4::Connection.new(
  url: 'https://engine40.example.com/ovirt-engine/api',
  username: 'admin@internal',
  password: 'redhat123',
  ca_file: 'ca.pem',
  debug: true,
  log: Logger.new('example.log')
)

# Find the virtual machine:
vms_service = connection.system_service.vms_service
vm = vms_service.list(search: 'name=myvm')[0]

# Find the service that manages the virtual machine:
vm_service = vms_service.vm_service(vm.id)

# Start the virtual machine enabling cloud-init and providing the
# password for the `root` user and the network configuration:
vm_service.start(
  use_cloud_init: true,
  vm: {
    initialization: {
      user_name: 'root',
      root_password: 'redhat123',
      host_name: 'myvm.example.com',
      nic_configurations: [
        {
          name: 'eth0',
          on_boot: true,
          boot_protocol: OvirtSDK4::BootProtocol::STATIC,
          ip: {
            version: OvirtSDK4::IpVersion::V4,
            address: '192.168.0.100',
            netmask: '255.255.255.0',
            gateway: '192.168.0.1'
          }
        }
      ],
      dns_servers: '192.168.0.1 192.168.0.2 192.168.0.3',
      dns_search: 'example.com'
    }
  }
)

# Close the connection to the server:
connection.close
