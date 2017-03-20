require 'pathname'

Puppet::Type.newtype(:dsc_cwds_pendingdevicesettings) do
  require Pathname.new(__FILE__).dirname + '../../' + 'puppet/type/base_dsc'
  require Pathname.new(__FILE__).dirname + '../../puppet_x/puppetlabs/dsc_type_helpers'


  @doc = %q{
    The DSC cWDS_PendingDeviceSettings resource type.
    Automatically generated from
    'custom_dsc_modules/cWDS/DSCResources/cWDS_PendingDeviceSettings/cWDS_PendingDeviceSettings.schema.mof'

    To learn more about PowerShell Desired State Configuration, please
    visit https://technet.microsoft.com/en-us/library/dn249912.aspx.

    For more information about built-in DSC Resources, please visit
    https://technet.microsoft.com/en-us/library/dn249921.aspx.

    For more information about xDsc Resources, please visit
    https://github.com/PowerShell/DscResources.
  }

  validate do
      fail('dsc_architecture is a required attribute') if self[:dsc_architecture].nil?
    end

  def dscmeta_resource_friendly_name; 'cWDS_PendingDeviceSettings' end
  def dscmeta_resource_name; 'cWDS_PendingDeviceSettings' end
  def dscmeta_module_name; 'cWDS' end
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

  # Name:         Architecture
  # Type:         string
  # IsMandatory:  True
  # Values:       ["x64", "x86", "ia64"]
  newparam(:dsc_architecture) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "Architecture - Valid values are x64, x86, ia64."
    isrequired
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
      unless ['x64', 'x64', 'x86', 'x86', 'ia64', 'ia64'].include?(value)
        fail("Invalid value '#{value}'. Valid values are x64, x86, ia64")
      end
    end
  end

  # Name:         BootProgram
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_bootprogram) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "BootProgram"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         UnattendFile
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_unattendfile) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "UnattendFile"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         BootImage
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_bootimage) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "BootImage"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         ReferralServer
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_referralserver) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "ReferralServer"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         User
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_user) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "User"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         JoinRights
  # Type:         string
  # IsMandatory:  False
  # Values:       ["JoinOnly", "Full"]
  newparam(:dsc_joinrights) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "JoinRights - Valid values are JoinOnly, Full."
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
      unless ['JoinOnly', 'joinonly', 'Full', 'full'].include?(value)
        fail("Invalid value '#{value}'. Valid values are JoinOnly, Full")
      end
    end
  end

  # Name:         JoinDomain
  # Type:         string
  # IsMandatory:  False
  # Values:       ["Yes", "No"]
  newparam(:dsc_joindomain) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "JoinDomain - Valid values are Yes, No."
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
      unless ['Yes', 'yes', 'No', 'no'].include?(value)
        fail("Invalid value '#{value}'. Valid values are Yes, No")
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

Puppet::Type.type(:dsc_cwds_pendingdevicesettings).provide :powershell, :parent => Puppet::Type.type(:base_dsc).provider(:powershell) do
  confine :true => (Gem::Version.new(Facter.value(:powershell_version)) >= Gem::Version.new('5.0.10240.16384'))
  defaultfor :operatingsystem => :windows

  mk_resource_methods
end
