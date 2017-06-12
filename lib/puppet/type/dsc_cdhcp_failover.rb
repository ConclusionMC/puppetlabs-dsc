require 'pathname'

Puppet::Type.newtype(:dsc_cdhcp_failover) do
  require Pathname.new(__FILE__).dirname + '../../' + 'puppet/type/base_dsc'
  require Pathname.new(__FILE__).dirname + '../../puppet_x/puppetlabs/dsc_type_helpers'


  @doc = %q{
    The DSC cDHCP_Failover resource type.
    Automatically generated from
    'cDHCP/DSCResources/cDHCP_Failover/cDHCP_Failover.schema.mof'

    To learn more about PowerShell Desired State Configuration, please
    visit https://technet.microsoft.com/en-us/library/dn249912.aspx.

    For more information about built-in DSC Resources, please visit
    https://technet.microsoft.com/en-us/library/dn249921.aspx.

    For more information about xDsc Resources, please visit
    https://github.com/PowerShell/DscResources.
  }

  validate do
      fail('dsc_name is a required attribute') if self[:dsc_name].nil?
    end

  def dscmeta_resource_friendly_name; 'cDHCP_Failover' end
  def dscmeta_resource_name; 'cDHCP_Failover' end
  def dscmeta_module_name; 'cDHCP' end
  def dscmeta_module_version; '1.1' end

  newparam(:name, :namevar => true ) do
  end

  ensurable do
    newvalue(:exists?) { provider.exists? }
    newvalue(:present) { provider.create }
    newvalue(:absent)  { provider.destroy }
    defaultto { :present }
  end

  # Name:         PsDscRunAsCredential
  # Type:         MSFT_Credential
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_psdscrunascredential) do
    def mof_type; 'MSFT_Credential' end
    def mof_is_embedded?; true end
    desc "PsDscRunAsCredential"
    validate do |value|
      unless value.kind_of?(Hash)
        fail("Invalid value '#{value}'. Should be a hash")
      end
      PuppetX::Dsc::TypeHelpers.validate_MSFT_Credential("Credential", value)
    end
  end

  # Name:         Name
  # Type:         string
  # IsMandatory:  True
  # Values:       None
  newparam(:dsc_name) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "Name"
    isrequired
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         PartnerServer
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_partnerserver) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "PartnerServer"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         Mode
  # Type:         string
  # IsMandatory:  False
  # Values:       ["HotStandby", "LoadBalance"]
  newparam(:dsc_mode) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "Mode - Valid values are HotStandby, LoadBalance."
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
      unless ['HotStandby', 'hotstandby', 'LoadBalance', 'loadbalance'].include?(value)
        fail("Invalid value '#{value}'. Valid values are HotStandby, LoadBalance")
      end
    end
  end

  # Name:         Ensure
  # Type:         string
  # IsMandatory:  False
  # Values:       ["Present", "Absent"]
  newparam(:dsc_ensure) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "Ensure - Valid values are Present, Absent."
    validate do |value|
      resource[:ensure] = value.downcase
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
      unless ['Present', 'present', 'Absent', 'absent'].include?(value)
        fail("Invalid value '#{value}'. Valid values are Present, Absent")
      end
    end
  end

  # Name:         Scopes
  # Type:         string[]
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_scopes, :array_matching => :all) do
    def mof_type; 'string[]' end
    def mof_is_embedded?; false end
    desc "Scopes"
    validate do |value|
      unless value.kind_of?(Array) || value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string or an array of strings")
      end
    end
    munge do |value|
      Array(value)
    end
  end

  # Name:         LoadBalancePercent
  # Type:         uint32
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_loadbalancepercent) do
    def mof_type; 'uint32' end
    def mof_is_embedded?; false end
    desc "LoadBalancePercent"
    validate do |value|
      unless (value.kind_of?(Numeric) && value >= 0) || (value.to_i.to_s == value && value.to_i >= 0)
          fail("Invalid value #{value}. Should be a unsigned Integer")
      end
    end
    munge do |value|
      PuppetX::Dsc::TypeHelpers.munge_integer(value)
    end
  end

  # Name:         ReservePercent
  # Type:         uint32
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_reservepercent) do
    def mof_type; 'uint32' end
    def mof_is_embedded?; false end
    desc "ReservePercent"
    validate do |value|
      unless (value.kind_of?(Numeric) && value >= 0) || (value.to_i.to_s == value && value.to_i >= 0)
          fail("Invalid value #{value}. Should be a unsigned Integer")
      end
    end
    munge do |value|
      PuppetX::Dsc::TypeHelpers.munge_integer(value)
    end
  end

  # Name:         SharedSecret
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_sharedsecret) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "SharedSecret"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         MaxClientLeadTime
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_maxclientleadtime) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "MaxClientLeadTime"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         StateSwitchInterval
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_stateswitchinterval) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "StateSwitchInterval"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         AutoStateTransition
  # Type:         boolean
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_autostatetransition) do
    def mof_type; 'boolean' end
    def mof_is_embedded?; false end
    desc "AutoStateTransition"
    validate do |value|
    end
    newvalues(true, false)
    munge do |value|
      PuppetX::Dsc::TypeHelpers.munge_boolean(value.to_s)
    end
  end

  # Name:         DesiredState
  # Type:         boolean
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_desiredstate) do
    def mof_type; 'boolean' end
    def mof_is_embedded?; false end
    desc "DesiredState"
    validate do |value|
    end
    newvalues(true, false)
    munge do |value|
      PuppetX::Dsc::TypeHelpers.munge_boolean(value.to_s)
    end
  end


  def builddepends
    pending_relations = super()
    PuppetX::Dsc::TypeHelpers.ensure_reboot_relationship(self, pending_relations)
  end
end

Puppet::Type.type(:dsc_cdhcp_failover).provide :powershell, :parent => Puppet::Type.type(:base_dsc).provider(:powershell) do
  confine :true => (Gem::Version.new(Facter.value(:powershell_version)) >= Gem::Version.new('5.0.10240.16384'))
  defaultfor :operatingsystem => :windows

  mk_resource_methods
end
