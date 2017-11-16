require 'pathname'

Puppet::Type.newtype(:dsc_cmisc_configureora) do
  require Pathname.new(__FILE__).dirname + '../../' + 'puppet/type/base_dsc'
  require Pathname.new(__FILE__).dirname + '../../puppet_x/puppetlabs/dsc_type_helpers'


  @doc = %q{
    The DSC cMisc_ConfigureORA resource type.
    Automatically generated from
    'cMisc/DSCResources/cMisc_ConfigureORA/cMisc_ConfigureORA.schema.mof'

    To learn more about PowerShell Desired State Configuration, please
    visit https://technet.microsoft.com/en-us/library/dn249912.aspx.

    For more information about built-in DSC Resources, please visit
    https://technet.microsoft.com/en-us/library/dn249921.aspx.

    For more information about xDsc Resources, please visit
    https://github.com/PowerShell/DscResources.
  }

  validate do
      fail('dsc_connectionname is a required attribute') if self[:dsc_connectionname].nil?
      fail('dsc_homename is a required attribute') if self[:dsc_homename].nil?
    end

  def dscmeta_resource_friendly_name; 'cMisc_ConfigureORA' end
  def dscmeta_resource_name; 'cMisc_ConfigureORA' end
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

  # Name:         ConnectionName
  # Type:         string
  # IsMandatory:  True
  # Values:       None
  newparam(:dsc_connectionname) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "ConnectionName"
    isrequired
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         HomeName
  # Type:         string
  # IsMandatory:  True
  # Values:       None
  newparam(:dsc_homename) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "HomeName"
    isrequired
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

  # Name:         DisableRULEHint
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_disablerulehint) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "DisableRULEHint"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         Attributes
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_attributes) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "Attributes"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         SQLTranslateErrors
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_sqltranslateerrors) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "SQLTranslateErrors"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         MaxTokenSize
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_maxtokensize) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "MaxTokenSize"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         FetchBufferSize
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_fetchbuffersize) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "FetchBufferSize"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         NumericSetting
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_numericsetting) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "NumericSetting"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         ForceWCHAR
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_forcewchar) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "ForceWCHAR"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         FailoverDelay
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_failoverdelay) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "FailoverDelay"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         FailoverRetryCount
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_failoverretrycount) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "FailoverRetryCount"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         MetadataIdDefault
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_metadataiddefault) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "MetadataIdDefault"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         BindAsFLOAT
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_bindasfloat) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "BindAsFLOAT"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         BindAsDATE
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_bindasdate) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "BindAsDATE"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         CloseCursor
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_closecursor) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "CloseCursor"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         EXECSchemaOpt
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_execschemaopt) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "EXECSchemaOpt"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         EXECSyntax
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_execsyntax) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "EXECSyntax"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         Application_Attributes
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_application_attributes) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "Application_Attributes"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         QueryTimeout
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_querytimeout) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "QueryTimeout"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         CacheBufferSize
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_cachebuffersize) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "CacheBufferSize"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         StatementCache
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_statementcache) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "StatementCache"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         ResultSets
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_resultsets) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "ResultSets"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         MaxLargeData
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_maxlargedata) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "MaxLargeData"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         UseOCIDescribeAny
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_useocidescribeany) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "UseOCIDescribeAny"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         Failover
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_failover) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "Failover"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         Lobs
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_lobs) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "Lobs"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         DisableMTS
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_disablemts) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "DisableMTS"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         DisableDPM
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_disabledpm) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "DisableDPM"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         BatchAutocommitMode
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_batchautocommitmode) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "BatchAutocommitMode"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         Description
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_description) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "Description"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         ServerName
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_servername) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "ServerName"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         Password
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_password) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "Password"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         UserID
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_userid) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "UserID"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         DSN
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_dsn) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "DSN"
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

Puppet::Type.type(:dsc_cmisc_configureora).provide :powershell, :parent => Puppet::Type.type(:base_dsc).provider(:powershell) do
  confine :true => (Gem::Version.new(Facter.value(:powershell_version)) >= Gem::Version.new('5.0.10240.16384'))
  defaultfor :operatingsystem => :windows

  mk_resource_methods
end
