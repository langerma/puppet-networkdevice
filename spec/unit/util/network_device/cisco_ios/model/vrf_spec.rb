#! /usr/bin/env ruby
require 'spec_helper'
require 'puppet/util/network_device'
require 'puppet/util/network_device/cisco_ios/model/vrf'

describe Puppet::Util::NetworkDevice::Cisco_ios::Model::Vrf do
  before(:each) do
    @transport = stub_everything "transport"
    @vrf = Puppet::Util::NetworkDevice::Cisco_ios::Model::Vrf.new(@transport, {}, { :name => 'TESTVRF12', :desc => 'TEST VRF 12', :ensure => :present })
  end

  describe 'when working with vrf params' do
    before do
      @vrf_config = <<END
!
ip vrf TEST1
 description TEST 1
 rd 10.11.12.13:123
 route-target export 123:128
 route-target import 123:128
!
ip vrf TESTVRF12
 description TEST VRF 12
 rd 10.11.12.15:555
 route-target export 555:128
 route-target import 555:128
!
ip vrf TEST3
!
END
  end

    it 'should initialize various base params' do
      @vrf.params.should_not == be_empty
    end

    it 'should set the name from the options' do
      @vrf.name.should == 'TESTVRF12'
    end

    it 'should set the scope_name on the desc param' do
      @vrf.params[:desc].scope_name.should == 'TESTVRF12'
    end

    it 'should parse description of the desc param' do
      @transport.expects(:command).with('sh run', {:cache => true, :noop => false}).returns(@vrf_config).twice
      @vrf.evaluate_new_params
      @vrf.params[:desc].value.should == "TEST VRF 12"
    end

    it 'should add a vrf with default description' do
      @transport.expects(:command).with('ip vrf TESTVRF12', :prompt => /\(config-vrf\)#\s?\z/n)
      @transport.expects(:command).with('exit')
      @transport.stubs(:command).with("sh run", {:cache => true, :noop => false}).returns(@vrf_config)
      @vrf = Puppet::Util::NetworkDevice::Cisco_ios::Model::Vrf.new(@transport, {}, { :name => 'TESTVRF12', :ensure => :present })
      @vrf.evaluate_new_params
      @vrf.update({:ensure => :absent}, {:ensure => :present})
    end

    it 'should update a vrf description' do
      @transport.expects(:command).with('ip vrf TESTVRF12', :prompt => /\(config-vrf\)#\s?\z/n)
      @transport.expects(:command).with('description TEST VRF 42')
      @transport.expects(:command).with('exit')
      @transport.stubs(:command).with("sh run", {:cache => true, :noop => false}).returns(@vrf_config)
      @vrf.evaluate_new_params
      @vrf.update({:ensure => :present, :desc => 'TEST VRF 12'}, {:ensure => :present, :desc => 'TEST VRF 42'})
    end

    it 'should remove a vrf' do
      @transport.expects(:command).with('no ip vrf TESTVRF12')
      @transport.stubs(:command).with("sh run", {:cache => true, :noop => false}).returns(@vrf_config)
      @vrf.evaluate_new_params
      @vrf.update({:ensure => :present}, {:ensure => :absent})
    end
  end
end
