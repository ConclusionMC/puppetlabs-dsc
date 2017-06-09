require 'pathname'

Puppet::Type.newtype(:dsc_cdhcp_options2) do
  require Pathname.new(__FILE__).dirname + '../../' + 'puppet/type/base_dsc'
  require Pathname.new(__FILE__).dirname + '../../puppet_x/puppetlabs/dsc_type_helpers'


  @doc = %q{
    The DSC cDHCP_Options2 resource type.
    Automatically generated from
    'cDHCP/DSCResources/cDHCP_Options2/cDHCP_Options2.schema.mof'

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

  def dscmeta_resource_friendly_name; 'cDHCP_Options2' end
  def dscmeta_resource_name; 'cDHCP_Options2' end
  def dscmeta_module_name; 'cDHCP' end
  def dscmeta_module_version; '1.1' end

  newparam(:name, :namevar => true ) do
  end

  ensurable do
    newvalue(:exists?) { provider.exists? }
    newvalue(:present) { provider.create }
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

  # Name:         Level
  # Type:         string
  # IsMandatory:  False
  # Values:       ["Server", "Scope", "Reservation"]
  newparam(:dsc_level) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "Level - Valid values are Server, Scope, Reservation."
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
      unless ['Server', 'server', 'Scope', 'scope', 'Reservation', 'reservation'].include?(value)
        fail("Invalid value '#{value}'. Valid values are Server, Scope, Reservation")
      end
    end
  end

  # Name:         Purge
  # Type:         boolean
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_purge) do
    def mof_type; 'boolean' end
    def mof_is_embedded?; false end
    desc "Purge"
    validate do |value|
    end
    newvalues(true, false)
    munge do |value|
      PuppetX::Dsc::TypeHelpers.munge_boolean(value.to_s)
    end
  end

  # Name:         Option_3
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_option_3) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "Option_3"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         Option_6
  # Type:         string[]
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_option_6, :array_matching => :all) do
    def mof_type; 'string[]' end
    def mof_is_embedded?; false end
    desc "Option_6"
    validate do |value|
      unless value.kind_of?(Array) || value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string or an array of strings")
      end
    end
    munge do |value|
      Array(value)
    end
  end

  # Name:         Option_12
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_option_12) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "Option_12"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         Option_15
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_option_15) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "Option_15"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         Option_66
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_option_66) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "Option_66"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         Option_67
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_option_67) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "Option_67"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         ScopeName
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_scopename) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "ScopeName"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         ReservedIP
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_reservedip) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "ReservedIP"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
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

Puppet::Type.type(:dsc_cdhcp_options2).provide :powershell, :parent => Puppet::Type.type(:base_dsc).provider(:powershell) do
  confine :true => (Gem::Version.new(Facter.value(:powershell_version)) >= Gem::Version.new('5.0.10240.16384'))
  defaultfor :operatingsystem => :windows

  mk_resource_methods
end
