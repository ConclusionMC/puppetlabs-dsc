require 'pathname'

Puppet::Type.newtype(:dsc_cwds_adddrivergroup) do
  require Pathname.new(__FILE__).dirname + '../../' + 'puppet/type/base_dsc'
  require Pathname.new(__FILE__).dirname + '../../puppet_x/puppetlabs/dsc_type_helpers'


  @doc = %q{
    The DSC cWDS_AddDriverGroup resource type.
    Automatically generated from
    'cWDS/DSCResources/cWDS_AddDriverGroup/cWDS_AddDriverGroup.schema.mof'

    To learn more about PowerShell Desired State Configuration, please
    visit https://technet.microsoft.com/en-us/library/dn249912.aspx.

    For more information about built-in DSC Resources, please visit
    https://technet.microsoft.com/en-us/library/dn249921.aspx.

    For more information about xDsc Resources, please visit
    https://github.com/PowerShell/DscResources.
  }

  validate do
      fail('dsc_drivergroup is a required attribute') if self[:dsc_drivergroup].nil?
    end

  def dscmeta_resource_friendly_name; 'cWDS_AddDriverGroup' end
  def dscmeta_resource_name; 'cWDS_AddDriverGroup' end
  def dscmeta_module_name; 'cWDS' end
  def dscmeta_module_version; '1.0' end

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

  # Name:         DriverGroup
  # Type:         string
  # IsMandatory:  True
  # Values:       None
  newparam(:dsc_drivergroup) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "DriverGroup"
    isrequired
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         Applicability
  # Type:         string
  # IsMandatory:  False
  # Values:       ["Matched", "All"]
  newparam(:dsc_applicability) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "Applicability - Valid values are Matched, All."
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
      unless ['Matched', 'matched', 'All', 'all'].include?(value)
        fail("Invalid value '#{value}'. Valid values are Matched, All")
      end
    end
  end

  # Name:         Enabled
  # Type:         string
  # IsMandatory:  False
  # Values:       ["Yes", "No"]
  newparam(:dsc_enabled) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "Enabled - Valid values are Yes, No."
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
      unless ['Yes', 'yes', 'No', 'no'].include?(value)
        fail("Invalid value '#{value}'. Valid values are Yes, No")
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

Puppet::Type.type(:dsc_cwds_adddrivergroup).provide :powershell, :parent => Puppet::Type.type(:base_dsc).provider(:powershell) do
  confine :true => (Gem::Version.new(Facter.value(:powershell_version)) >= Gem::Version.new('5.0.10240.16384'))
  defaultfor :operatingsystem => :windows

  mk_resource_methods
end
