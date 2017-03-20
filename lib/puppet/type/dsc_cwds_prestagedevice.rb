require 'pathname'

Puppet::Type.newtype(:dsc_cwds_prestagedevice) do
  require Pathname.new(__FILE__).dirname + '../../' + 'puppet/type/base_dsc'
  require Pathname.new(__FILE__).dirname + '../../puppet_x/puppetlabs/dsc_type_helpers'


  @doc = %q{
    The DSC cWDS_PrestageDevice resource type.
    Automatically generated from
    'cWDS/DSCResources/cWDS_PrestageDevice/cWDS_PrestageDevice.schema.mof'

    To learn more about PowerShell Desired State Configuration, please
    visit https://technet.microsoft.com/en-us/library/dn249912.aspx.

    For more information about built-in DSC Resources, please visit
    https://technet.microsoft.com/en-us/library/dn249921.aspx.

    For more information about xDsc Resources, please visit
    https://github.com/PowerShell/DscResources.
  }

  validate do
      fail('dsc_devicename is a required attribute') if self[:dsc_devicename].nil?
      fail('dsc_ensure is a required attribute') if self[:dsc_ensure].nil?
    end

  def dscmeta_resource_friendly_name; 'cWDS_PrestageDevice' end
  def dscmeta_resource_name; 'cWDS_PrestageDevice' end
  def dscmeta_module_name; 'cWDS' end
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

  # Name:         DeviceName
  # Type:         string
  # IsMandatory:  True
  # Values:       None
  newparam(:dsc_devicename) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "DeviceName"
    isrequired
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         DeviceID
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_deviceid) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "DeviceID"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         Ensure
  # Type:         string
  # IsMandatory:  True
  # Values:       ["Present", "Absent"]
  newparam(:dsc_ensure) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "Ensure - Valid values are Present, Absent."
    isrequired
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

  # Name:         JoinDomain
  # Type:         boolean
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_joindomain) do
    def mof_type; 'boolean' end
    def mof_is_embedded?; false end
    desc "JoinDomain"
    validate do |value|
    end
    newvalues(true, false)
    munge do |value|
      PuppetX::Dsc::TypeHelpers.munge_boolean(value.to_s)
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

  # Name:         PxePromptPolicy
  # Type:         string
  # IsMandatory:  False
  # Values:       ["OptIn", "OptOut", "NoPrompt", "Abort"]
  newparam(:dsc_pxepromptpolicy) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "PxePromptPolicy - Valid values are OptIn, OptOut, NoPrompt, Abort."
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
      unless ['OptIn', 'optin', 'OptOut', 'optout', 'NoPrompt', 'noprompt', 'Abort', 'abort'].include?(value)
        fail("Invalid value '#{value}'. Valid values are OptIn, OptOut, NoPrompt, Abort")
      end
    end
  end

  # Name:         WdsClientUnattend
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_wdsclientunattend) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "WdsClientUnattend"
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

Puppet::Type.type(:dsc_cwds_prestagedevice).provide :powershell, :parent => Puppet::Type.type(:base_dsc).provider(:powershell) do
  confine :true => (Gem::Version.new(Facter.value(:powershell_version)) >= Gem::Version.new('5.0.10240.16384'))
  defaultfor :operatingsystem => :windows

  mk_resource_methods
end
