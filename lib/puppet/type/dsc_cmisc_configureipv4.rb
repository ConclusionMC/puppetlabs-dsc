require 'pathname'

Puppet::Type.newtype(:dsc_cmisc_configureipv4) do
  require Pathname.new(__FILE__).dirname + '../../' + 'puppet/type/base_dsc'
  require Pathname.new(__FILE__).dirname + '../../puppet_x/puppetlabs/dsc_type_helpers'


  @doc = %q{
    The DSC cMisc_ConfigureIPv4 resource type.
    Automatically generated from
    'cMisc/DSCResources/cMisc_ConfigureIPv4/cMisc_ConfigureIPv4.schema.mof'

    To learn more about PowerShell Desired State Configuration, please
    visit https://technet.microsoft.com/en-us/library/dn249912.aspx.

    For more information about built-in DSC Resources, please visit
    https://technet.microsoft.com/en-us/library/dn249921.aspx.

    For more information about xDsc Resources, please visit
    https://github.com/PowerShell/DscResources.
  }

  validate do
      fail('dsc_macaddress is a required attribute') if self[:dsc_macaddress].nil?
    end

  def dscmeta_resource_friendly_name; 'cMisc_ConfigureIPv4' end
  def dscmeta_resource_name; 'cMisc_ConfigureIPv4' end
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

  # Name:         MacAddress
  # Type:         string
  # IsMandatory:  True
  # Values:       None
  newparam(:dsc_macaddress) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "MacAddress"
    isrequired
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

  # Name:         IP
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_ip) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "IP"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         PrefixLength
  # Type:         uint32
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_prefixlength) do
    def mof_type; 'uint32' end
    def mof_is_embedded?; false end
    desc "PrefixLength"
    validate do |value|
      unless (value.kind_of?(Numeric) && value >= 0) || (value.to_i.to_s == value && value.to_i >= 0)
          fail("Invalid value #{value}. Should be a unsigned Integer")
      end
    end
    munge do |value|
      PuppetX::Dsc::TypeHelpers.munge_integer(value)
    end
  end

  # Name:         Gateway
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_gateway) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "Gateway"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         DnsServers
  # Type:         string[]
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_dnsservers, :array_matching => :all) do
    def mof_type; 'string[]' end
    def mof_is_embedded?; false end
    desc "DnsServers"
    validate do |value|
      unless value.kind_of?(Array) || value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string or an array of strings")
      end
    end
    munge do |value|
      Array(value)
    end
  end

  # Name:         DisableIPv6
  # Type:         boolean
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_disableipv6) do
    def mof_type; 'boolean' end
    def mof_is_embedded?; false end
    desc "DisableIPv6"
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

Puppet::Type.type(:dsc_cmisc_configureipv4).provide :powershell, :parent => Puppet::Type.type(:base_dsc).provider(:powershell) do
  confine :true => (Gem::Version.new(Facter.value(:powershell_version)) >= Gem::Version.new('5.0.10240.16384'))
  defaultfor :operatingsystem => :windows

  mk_resource_methods
end
