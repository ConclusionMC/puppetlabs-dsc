require 'pathname'

Puppet::Type.newtype(:dsc_cwds_transportnetworkconfig) do
  require Pathname.new(__FILE__).dirname + '../../' + 'puppet/type/base_dsc'
  require Pathname.new(__FILE__).dirname + '../../puppet_x/puppetlabs/dsc_type_helpers'


  @doc = %q{
    The DSC cWDS_TransportNetworkConfig resource type.
    Automatically generated from
    'cWDS/DSCResources/cWDS_TransportNetworkConfig/cWDS_TransportNetworkConfig.schema.mof'

    To learn more about PowerShell Desired State Configuration, please
    visit https://technet.microsoft.com/en-us/library/dn249912.aspx.

    For more information about built-in DSC Resources, please visit
    https://technet.microsoft.com/en-us/library/dn249921.aspx.

    For more information about xDsc Resources, please visit
    https://github.com/PowerShell/DscResources.
  }

  validate do
      fail('dsc_ipv4source is a required attribute') if self[:dsc_ipv4source].nil?
    end

  def dscmeta_resource_friendly_name; 'cWDS_TransportNetworkConfig' end
  def dscmeta_resource_name; 'cWDS_TransportNetworkConfig' end
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

  # Name:         IPv4Source
  # Type:         string
  # IsMandatory:  True
  # Values:       ["Dhcp", "Range"]
  newparam(:dsc_ipv4source) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "IPv4Source - Valid values are Dhcp, Range."
    isrequired
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
      unless ['Dhcp', 'dhcp', 'Range', 'range'].include?(value)
        fail("Invalid value '#{value}'. Valid values are Dhcp, Range")
      end
    end
  end

  # Name:         IPv4RangeStart
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_ipv4rangestart) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "IPv4RangeStart"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         IPv4RangeEnd
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_ipv4rangeend) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "IPv4RangeEnd"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         IPv6RangeStart
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_ipv6rangestart) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "IPv6RangeStart"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         IPv6RangeEnd
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_ipv6rangeend) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "IPv6RangeEnd"
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

Puppet::Type.type(:dsc_cwds_transportnetworkconfig).provide :powershell, :parent => Puppet::Type.type(:base_dsc).provider(:powershell) do
  confine :true => (Gem::Version.new(Facter.value(:powershell_version)) >= Gem::Version.new('5.0.10240.16384'))
  defaultfor :operatingsystem => :windows

  mk_resource_methods
end
