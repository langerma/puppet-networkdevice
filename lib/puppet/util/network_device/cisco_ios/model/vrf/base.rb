require 'puppet/util/network_device/cisco_ios/model'
require 'puppet/util/network_device/cisco_ios/model/vrf'

module Puppet::Util::NetworkDevice::Cisco_ios::Model::Vrf::Base
  def self.register(base)
    vrf_scope = /\n(ip vrf (\w+)\s+([^!]*))\n!/m
    base.register_scoped :ensure, vrf_scope do
      match do |txt|
        unless txt.nil?
          txt.match(/\S+/) ? :present : :absent
        else
          :absent
        end
      end
      cmd 'sh run'
      default :absent
      add { |*_| }
      remove { |*_| }
    end
    base.register_scoped :desc, vrf_scope do
      match /^\s*description (.*?)\s*$/
      cmd 'sh run'
      add do |transport, value|
        transport.command("description #{value}", :prompt => /\(config-vrf\)#\s?\z/n)
      end
      remove do |transport, value|
        transport.command("no description", :prompt => /\(config-vrf\)#\s?\z/n)
      end
    end
    base.register_scoped :rd, vrf_scope do
      match /^\s*rd (.*?)\s*$/
      cmd 'sh run'
      add do |transport, value|
        transport.command("rd #{value}", :prompt => /\(config-vrf\)#\s?\z/n)
      end
      remove do |transport, value|
        transport.command("no rd #{value}", :prompt => /\(config-vrf\)#\s?\z/n)
      end
    end
  end
end