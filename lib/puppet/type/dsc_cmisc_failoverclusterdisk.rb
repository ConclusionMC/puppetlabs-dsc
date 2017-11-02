require 'pathname'

Puppet::Type.newtype(:dsc_cmisc_failoverclusterdisk) do
  require Pathname.new(__FILE__).dirname + '../../' + 'puppet/type/base_dsc'
  require Pathname.new(__FILE__).dirname + '../../puppet_x/puppetlabs/dsc_type_helpers'


  @doc = %q{
    The DSC cMisc_FailoverClusterDisk resource type.
    Automatically generated from
    'cMisc/DSCResources/cMisc_FailoverClusterDisk/cMisc_FailoverClusterDisk.schema.mof'

    To learn more about PowerShell Desired State Configuration, please
    visit https://technet.microsoft.com/en-us/library/dn249912.aspx.

    For more information about built-in DSC Resources, please visit
    https://technet.microsoft.com/en-us/library/dn249921.aspx.

    For more information about xDsc Resources, please visit
    https://github.com/PowerShell/DscResources.
  }

  validate do
      fail('dsc_number is a required attribute') if self[:dsc_number].nil?
    end

  def dscmeta_resource_friendly_name; 'cMisc_FailoverClusterDisk' end
  def dscmeta_resource_name; 'cMisc_FailoverClusterDisk' end
  def dscmeta_module_name; 'cMisc' end
  def dscmeta_module_version; '1.0' end

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

  # Name:         Number
  # Type:         uint32
  # IsMandatory:  True
  # Values:       None
  newparam(:dsc_number) do
    def mof_type; 'uint32' end
    def mof_is_embedded?; false end
    desc "Number"
    isrequired
    validate do |value|
      unless (value.kind_of?(Numeric) && value >= 0) || (value.to_i.to_s == value && value.to_i >= 0)
          fail("Invalid value #{value}. Should be a unsigned Integer")
      end
    end
    munge do |value|
      PuppetX::Dsc::TypeHelpers.munge_integer(value)
    end
  end

  # Name:         DriveLetter
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_driveletter) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "DriveLetter"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         PartitionStyle
  # Type:         string
  # IsMandatory:  False
  # Values:       ["GPT", "MBR"]
  newparam(:dsc_partitionstyle) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "PartitionStyle - Valid values are GPT, MBR."
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
      unless ['GPT', 'gpt', 'MBR', 'mbr'].include?(value)
        fail("Invalid value '#{value}'. Valid values are GPT, MBR")
      end
    end
  end

  # Name:         FileSystem
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_filesystem) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "FileSystem"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         Label
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_label) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "Label"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         Name
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_name) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "Name"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end


  def builddepends
    pending_relations = super()
    PuppetX::Dsc::TypeHelpers.ensure_reboot_relationship(self, pending_relations)
  end
end

Puppet::Type.type(:dsc_cmisc_failoverclusterdisk).provide :powershell, :parent => Puppet::Type.type(:base_dsc).provider(:powershell) do
  confine :true => (Gem::Version.new(Facter.value(:powershell_version)) >= Gem::Version.new('5.0.10240.16384'))
  defaultfor :operatingsystem => :windows

  mk_resource_methods
end
