require 'pathname'

Puppet::Type.newtype(:dsc_cmc_gpoextendedright) do
  require Pathname.new(__FILE__).dirname + '../../' + 'puppet/type/base_dsc'
  require Pathname.new(__FILE__).dirname + '../../puppet_x/puppetlabs/dsc_type_helpers'


  @doc = %q{
    The DSC CMC_GpoExtendedRight resource type.
    Automatically generated from
    'CMC_Gpo/DSCResources/CMC_GpoExtendedRight/CMC_GpoExtendedRight.schema.mof'

    To learn more about PowerShell Desired State Configuration, please
    visit https://technet.microsoft.com/en-us/library/dn249912.aspx.

    For more information about built-in DSC Resources, please visit
    https://technet.microsoft.com/en-us/library/dn249921.aspx.

    For more information about xDsc Resources, please visit
    https://github.com/PowerShell/DscResources.
  }

  validate do
      fail('dsc_gponame is a required attribute') if self[:dsc_gponame].nil?
      fail('dsc_extendedright is a required attribute') if self[:dsc_extendedright].nil?
      fail('dsc_controltype is a required attribute') if self[:dsc_controltype].nil?
    end

  def dscmeta_resource_friendly_name; 'CMC_GpoExtendedRight' end
  def dscmeta_resource_name; 'CMC_GpoExtendedRight' end
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

  # Name:         GpoName
  # Type:         string
  # IsMandatory:  True
  # Values:       None
  newparam(:dsc_gponame) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "GpoName"
    isrequired
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         ExtendedRight
  # Type:         string
  # IsMandatory:  True
  # Values:       None
  newparam(:dsc_extendedright) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "ExtendedRight"
    isrequired
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         ControlType
  # Type:         string
  # IsMandatory:  True
  # Values:       ["Allow", "Deny"]
  newparam(:dsc_controltype) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "ControlType - Valid values are Allow, Deny."
    isrequired
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
      unless ['Allow', 'allow', 'Deny', 'deny'].include?(value)
        fail("Invalid value '#{value}'. Valid values are Allow, Deny")
      end
    end
  end

  # Name:         Users
  # Type:         string[]
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_users, :array_matching => :all) do
    def mof_type; 'string[]' end
    def mof_is_embedded?; false end
    desc "Users"
    validate do |value|
      unless value.kind_of?(Array) || value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string or an array of strings")
      end
    end
    munge do |value|
      Array(value)
    end
  end

  # Name:         Domain
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_domain) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "Domain"
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

Puppet::Type.type(:dsc_cmc_gpoextendedright).provide :powershell, :parent => Puppet::Type.type(:base_dsc).provider(:powershell) do
  confine :true => (Gem::Version.new(Facter.value(:powershell_version)) >= Gem::Version.new('5.0.10240.16384'))
  defaultfor :operatingsystem => :windows

  mk_resource_methods
end
