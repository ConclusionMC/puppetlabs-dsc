require 'pathname'

Puppet::Type.newtype(:dsc_cdhcp_scope) do
  require Pathname.new(__FILE__).dirname + '../../' + 'puppet/type/base_dsc'
  require Pathname.new(__FILE__).dirname + '../../puppet_x/puppetlabs/dsc_type_helpers'


  @doc = %q{
    The DSC cDHCP_Scope resource type.
    Automatically generated from
    'cDHCP/DSCResources/cDHCP_Scope/cDHCP_Scope.schema.mof'

    To learn more about PowerShell Desired State Configuration, please
    visit https://technet.microsoft.com/en-us/library/dn249912.aspx.

    For more information about built-in DSC Resources, please visit
    https://technet.microsoft.com/en-us/library/dn249921.aspx.

    For more information about xDsc Resources, please visit
    https://github.com/PowerShell/DscResources.
  }

  validate do
      fail('dsc_scopename is a required attribute') if self[:dsc_scopename].nil?
    end

  def dscmeta_resource_friendly_name; 'cDHCP_Scope' end
  def dscmeta_resource_name; 'cDHCP_Scope' end
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

  # Name:         ScopeName
  # Type:         string
  # IsMandatory:  True
  # Values:       None
  newparam(:dsc_scopename) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "ScopeName"
    isrequired
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         Ensure
  # Type:         string
  # IsMandatory:  False
  # Values:       ["Absent", "Present"]
  newparam(:dsc_ensure) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "Ensure - Valid values are Absent, Present."
    validate do |value|
      resource[:ensure] = value.downcase
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
      unless ['Absent', 'absent', 'Present', 'present'].include?(value)
        fail("Invalid value '#{value}'. Valid values are Absent, Present")
      end
    end
  end

  # Name:         State
  # Type:         string
  # IsMandatory:  False
  # Values:       ["Inactive", "Active"]
  newparam(:dsc_state) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "State - Valid values are Inactive, Active."
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
      unless ['Inactive', 'inactive', 'Active', 'active'].include?(value)
        fail("Invalid value '#{value}'. Valid values are Inactive, Active")
      end
    end
  end

  # Name:         StartRange
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_startrange) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "StartRange"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         EndRange
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_endrange) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "EndRange"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         SubnetMask
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_subnetmask) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "SubnetMask"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         LeaseDuration
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_leaseduration) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "LeaseDuration"
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

Puppet::Type.type(:dsc_cdhcp_scope).provide :powershell, :parent => Puppet::Type.type(:base_dsc).provider(:powershell) do
  confine :true => (Gem::Version.new(Facter.value(:powershell_version)) >= Gem::Version.new('5.0.10240.16384'))
  defaultfor :operatingsystem => :windows

  mk_resource_methods
end
