require 'pathname'

Puppet::Type.newtype(:dsc_cmisc_crewsadaptor) do
  require Pathname.new(__FILE__).dirname + '../../' + 'puppet/type/base_dsc'
  require Pathname.new(__FILE__).dirname + '../../puppet_x/puppetlabs/dsc_type_helpers'


  @doc = %q{
    The DSC cMisc_CrewsAdaptor resource type.
    Automatically generated from
    'cMisc/DSCResources/cMisc_CrewsAdaptor/cMisc_CrewsAdaptor.schema.mof'

    To learn more about PowerShell Desired State Configuration, please
    visit https://technet.microsoft.com/en-us/library/dn249912.aspx.

    For more information about built-in DSC Resources, please visit
    https://technet.microsoft.com/en-us/library/dn249921.aspx.

    For more information about xDsc Resources, please visit
    https://github.com/PowerShell/DscResources.
  }

  validate do
      fail('dsc_groupname is a required attribute') if self[:dsc_groupname].nil?
    end

  def dscmeta_resource_friendly_name; 'cMisc_CrewsAdaptor' end
  def dscmeta_resource_name; 'cMisc_CrewsAdaptor' end
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

  # Name:         GroupName
  # Type:         string
  # IsMandatory:  True
  # Values:       None
  newparam(:dsc_groupname) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "GroupName"
    isrequired
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         ClusterDisk
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_clusterdisk) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "ClusterDisk"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         JavaPath
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_javapath) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "JavaPath"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         OraHomeName
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_orahomename) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "OraHomeName"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         DBHost
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_dbhost) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "DBHost"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         DBPort
  # Type:         uint32
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_dbport) do
    def mof_type; 'uint32' end
    def mof_is_embedded?; false end
    desc "DBPort"
    validate do |value|
      unless (value.kind_of?(Numeric) && value >= 0) || (value.to_i.to_s == value && value.to_i >= 0)
          fail("Invalid value #{value}. Should be a unsigned Integer")
      end
    end
    munge do |value|
      PuppetX::Dsc::TypeHelpers.munge_integer(value)
    end
  end

  # Name:         ServiceName
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_servicename) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "ServiceName"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         DataSets
  # Type:         string[]
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_datasets, :array_matching => :all) do
    def mof_type; 'string[]' end
    def mof_is_embedded?; false end
    desc "DataSets"
    validate do |value|
      unless value.kind_of?(Array) || value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string or an array of strings")
      end
    end
    munge do |value|
      Array(value)
    end
  end

  # Name:         JMSHost
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_jmshost) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "JMSHost"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         JMSPort
  # Type:         uint32
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_jmsport) do
    def mof_type; 'uint32' end
    def mof_is_embedded?; false end
    desc "JMSPort"
    validate do |value|
      unless (value.kind_of?(Numeric) && value >= 0) || (value.to_i.to_s == value && value.to_i >= 0)
          fail("Invalid value #{value}. Should be a unsigned Integer")
      end
    end
    munge do |value|
      PuppetX::Dsc::TypeHelpers.munge_integer(value)
    end
  end

  # Name:         JMSQManager
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_jmsqmanager) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "JMSQManager"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         JMSTransportType
  # Type:         uint32
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_jmstransporttype) do
    def mof_type; 'uint32' end
    def mof_is_embedded?; false end
    desc "JMSTransportType"
    validate do |value|
      unless (value.kind_of?(Numeric) && value >= 0) || (value.to_i.to_s == value && value.to_i >= 0)
          fail("Invalid value #{value}. Should be a unsigned Integer")
      end
    end
    munge do |value|
      PuppetX::Dsc::TypeHelpers.munge_integer(value)
    end
  end

  # Name:         JMSQName
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_jmsqname) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "JMSQName"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         JMSUsername
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_jmsusername) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "JMSUsername"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         JMSPassword
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_jmspassword) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "JMSPassword"
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

Puppet::Type.type(:dsc_cmisc_crewsadaptor).provide :powershell, :parent => Puppet::Type.type(:base_dsc).provider(:powershell) do
  confine :true => (Gem::Version.new(Facter.value(:powershell_version)) >= Gem::Version.new('5.0.10240.16384'))
  defaultfor :operatingsystem => :windows

  mk_resource_methods
end
