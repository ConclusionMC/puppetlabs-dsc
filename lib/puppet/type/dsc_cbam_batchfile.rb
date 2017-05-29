require 'pathname'

Puppet::Type.newtype(:dsc_cbam_batchfile) do
  require Pathname.new(__FILE__).dirname + '../../' + 'puppet/type/base_dsc'
  require Pathname.new(__FILE__).dirname + '../../puppet_x/puppetlabs/dsc_type_helpers'


  @doc = %q{
    The DSC cBAM_BatchFile resource type.
    Automatically generated from
    'cBAM/DSCResources/cBAM_BatchFile/cBAM_BatchFile.schema.mof'

    To learn more about PowerShell Desired State Configuration, please
    visit https://technet.microsoft.com/en-us/library/dn249912.aspx.

    For more information about built-in DSC Resources, please visit
    https://technet.microsoft.com/en-us/library/dn249921.aspx.

    For more information about xDsc Resources, please visit
    https://github.com/PowerShell/DscResources.
  }

  validate do
      fail('dsc_batchfile is a required attribute') if self[:dsc_batchfile].nil?
    end

  def dscmeta_resource_friendly_name; 'cBAM_BatchFile' end
  def dscmeta_resource_name; 'cBAM_BatchFile' end
  def dscmeta_module_name; 'cBAM' end
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

  # Name:         BatchFile
  # Type:         string
  # IsMandatory:  True
  # Values:       None
  newparam(:dsc_batchfile) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "BatchFile"
    isrequired
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         Template
  # Type:         string[]
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_template, :array_matching => :all) do
    def mof_type; 'string[]' end
    def mof_is_embedded?; false end
    desc "Template"
    validate do |value|
      unless value.kind_of?(Array) || value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string or an array of strings")
      end
    end
    munge do |value|
      Array(value)
    end
  end

  # Name:         StartCommand
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_startcommand) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "StartCommand"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         Auth_Server
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_auth_server) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "Auth_Server"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         Defect_Server
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_defect_server) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "Defect_Server"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         Conflict_Server
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_conflict_server) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "Conflict_Server"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         Plan_Server
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_plan_server) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "Plan_Server"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         Main_Server
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_main_server) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "Main_Server"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         JMS_Address
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_jms_address) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "JMS_Address"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         JRE_Home
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_jre_home) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "JRE_Home"
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

Puppet::Type.type(:dsc_cbam_batchfile).provide :powershell, :parent => Puppet::Type.type(:base_dsc).provider(:powershell) do
  confine :true => (Gem::Version.new(Facter.value(:powershell_version)) >= Gem::Version.new('5.0.10240.16384'))
  defaultfor :operatingsystem => :windows

  mk_resource_methods
end
