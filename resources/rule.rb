#
# Cookbook Name:: windows_firewall
# Resource:: rule
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

property :rule_name, String, name_property: true
property :description, String, default: 'Firewall rule'
property :localip, String
property :localport, String
property :remoteip, String
property :remoteport, String
property :dir, Symbol, default: :in, equal_to: [:in, :out]
property :protocol, String, default: 'TCP'
property :firewall_action, Symbol, default: :allow, equal_to: [:allow, :block, :bypass]
property :profile, Symbol, default: :any, equal_to: [:public, :private, :domain, :any]
property :program, String
property :service, String
property :interfacetype, Symbol, default: :any, equal_to: [:any, :wireless, :lan, :ras]

action :create do
  begin
    # netsh advfirewall firewall set rule name="SSH" dir=in action=allow protocol=TCP localport=22
    args = {}

    name = new_resource.rule_name
    desc = new_resource.description
    program = new_resource.program
    args['name'] = "\"#{name}\""
    args['description'] = "\"#{desc}\""
    args['localip'] = new_resource.localip
    args['localport'] = new_resource.localport
    args['remoteip'] = new_resource.remoteip
    args['remoteport'] = new_resource.remoteport
    args['dir'] = new_resource.dir
    args['protocol'] = new_resource.protocol
    args['action'] = new_resource.firewall_action
    args['profile'] = new_resource.profile
    args['program'] = "\"#{program}\""
    args['service'] = new_resource.service
    args['interfacetype'] = new_resource.interfacetype

    # cmdargs = args.map { |k, v| "#{k}=#{v}" }.join(' ')

    current_rule = shell_out("netsh advfirewall firewall show rule name=\"#{name}\"")

    if current_rule.stdout.strip == 'No rules match the specified criteria.'
      # cmd = "netsh advfirewall firewall add rule #{cmdargs}"
      cmd = 'netsh advfirewall firewall add rule '
      args.each do |attribute, value|
        cmd += "#{attribute}=#{value} " unless empty(value)
      end

      Chef::Log.debug("Running firewall command: #{cmd}")

      batch cmd do
        code cmd
      end
    else
      Chef::Log.info("Firewall rule \"#{name}\" already exists.")
    end
  end
end

def empty(value)
  !value || value == '' || value == '""'
end
