require 'pathname'

Puppet::Type.newtype(:dsc_cmc_gpo) do
  require Pathname.new(__FILE__).dirname + '../../' + 'puppet/type/base_dsc'
  require Pathname.new(__FILE__).dirname + '../../puppet_x/puppetlabs/dsc_type_helpers'


  @doc = %q{
    The DSC CMC_Gpo resource type.
    Automatically generated from
    'CMC_Gpo/DSCResources/CMC_Gpo/CMC_Gpo.schema.mof'

    To learn more about PowerShell Desired State Configuration, please
    visit https://technet.microsoft.com/en-us/library/dn249912.aspx.

    For more information about built-in DSC Resources, please visit
    https://technet.microsoft.com/en-us/library/dn249921.aspx.

    For more information about xDsc Resources, please visit
    https://github.com/PowerShell/DscResources.
  }

  validate do
      fail('dsc_gponame is a required attribute') if self[:dsc_gponame].nil?
      fail('dsc_backupguid is a required attribute') if self[:dsc_backupguid].nil?
    end

  def dscmeta_resource_friendly_name; 'CMC_Gpo' end
  def dscmeta_resource_name; 'CMC_Gpo' end
  def dscmeta_module_name; 'CMC_Gpo' end
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

  # Name:         GPOName
  # Type:         string
  # IsMandatory:  True
  # Values:       None
  newparam(:dsc_gponame) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "GPOName"
    isrequired
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         BackupGUID
  # Type:         string
  # IsMandatory:  True
  # Values:       None
  newparam(:dsc_backupguid) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "BackupGUID"
    isrequired
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         BackupPath
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_backuppath) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "BackupPath"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         WorkDir
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_workdir) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "WorkDir"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         CreateGPO
  # Type:         boolean
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_creategpo) do
    def mof_type; 'boolean' end
    def mof_is_embedded?; false end
    desc "CreateGPO"
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

Puppet::Type.type(:dsc_cmc_gpo).provide :powershell, :parent => Puppet::Type.type(:base_dsc).provider(:powershell) do
  confine :true => (Gem::Version.new(Facter.value(:powershell_version)) >= Gem::Version.new('5.0.10240.16384'))
  defaultfor :operatingsystem => :windows

  mk_resource_methods
end
