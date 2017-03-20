require 'pathname'

Puppet::Type.newtype(:dsc_cwds_unattendfile) do
  require Pathname.new(__FILE__).dirname + '../../' + 'puppet/type/base_dsc'
  require Pathname.new(__FILE__).dirname + '../../puppet_x/puppetlabs/dsc_type_helpers'


  @doc = %q{
    The DSC cWDS_UnattendFile resource type.
    Automatically generated from
    'custom_dsc_modules/cWDS/DSCResources/cWDS_UnattendFile/cWDS_UnattendFile.schema.mof'

    To learn more about PowerShell Desired State Configuration, please
    visit https://technet.microsoft.com/en-us/library/dn249912.aspx.

    For more information about built-in DSC Resources, please visit
    https://technet.microsoft.com/en-us/library/dn249921.aspx.

    For more information about xDsc Resources, please visit
    https://github.com/PowerShell/DscResources.
  }

  validate do
      fail('dsc_unattendfile is a required attribute') if self[:dsc_unattendfile].nil?
    end

  def dscmeta_resource_friendly_name; 'cWDS_UnattendFile' end
  def dscmeta_resource_name; 'cWDS_UnattendFile' end
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

  # Name:         UnattendFile
  # Type:         string
  # IsMandatory:  True
  # Values:       None
  newparam(:dsc_unattendfile) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "UnattendFile"
    isrequired
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         Template
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_template) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "Template"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         Architecture
  # Type:         string
  # IsMandatory:  False
  # Values:       ["x86", "amd64"]
  newparam(:dsc_architecture) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "Architecture - Valid values are x86, amd64."
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
      unless ['x86', 'x86', 'amd64', 'amd64'].include?(value)
        fail("Invalid value '#{value}'. Valid values are x86, amd64")
      end
    end
  end

  # Name:         WDS_Username
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_wds_username) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "WDS_Username"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         WDS_Domain
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_wds_domain) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "WDS_Domain"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         WDS_Password
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_wds_password) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "WDS_Password"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         Join_Domain
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_join_domain) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "Join_Domain"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         Domain_User
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_domain_user) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "Domain_User"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         DomainUser_Password
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_domainuser_password) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "DomainUser_Password"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         DomainUser_Domain
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_domainuser_domain) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "DomainUser_Domain"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         Administrator_Password
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_administrator_password) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "Administrator_Password"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         InstallImage
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_installimage) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "InstallImage"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         ImageGroup
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_imagegroup) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "ImageGroup"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         InstallImageFile
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_installimagefile) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "InstallImageFile"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         DriveLabel
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_drivelabel) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "DriveLabel"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         ProductKey
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_productkey) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "ProductKey"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         FirstLogonCommands
  # Type:         string[]
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_firstlogoncommands, :array_matching => :all) do
    def mof_type; 'string[]' end
    def mof_is_embedded?; false end
    desc "FirstLogonCommands"
    validate do |value|
      unless value.kind_of?(Array) || value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string or an array of strings")
      end
    end
    munge do |value|
      Array(value)
    end
  end

  # Name:         CheckContent
  # Type:         boolean
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_checkcontent) do
    def mof_type; 'boolean' end
    def mof_is_embedded?; false end
    desc "CheckContent"
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

Puppet::Type.type(:dsc_cwds_unattendfile).provide :powershell, :parent => Puppet::Type.type(:base_dsc).provider(:powershell) do
  confine :true => (Gem::Version.new(Facter.value(:powershell_version)) >= Gem::Version.new('5.0.10240.16384'))
  defaultfor :operatingsystem => :windows

  mk_resource_methods
end
