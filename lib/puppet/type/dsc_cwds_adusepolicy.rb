require 'pathname'

Puppet::Type.newtype(:dsc_cwds_adusepolicy) do
  require Pathname.new(__FILE__).dirname + '../../' + 'puppet/type/base_dsc'
  require Pathname.new(__FILE__).dirname + '../../puppet_x/puppetlabs/dsc_type_helpers'


  @doc = %q{
    The DSC cWDS_ADUsePolicy resource type.
    Automatically generated from
    'cWDS/DSCResources/cWDS_ADUsePolicy/cWDS_ADUsePolicy.schema.mof'

    To learn more about PowerShell Desired State Configuration, please
    visit https://technet.microsoft.com/en-us/library/dn249912.aspx.

    For more information about built-in DSC Resources, please visit
    https://technet.microsoft.com/en-us/library/dn249921.aspx.

    For more information about xDsc Resources, please visit
    https://github.com/PowerShell/DscResources.
  }

  validate do
      fail('dsc_newmachinedomainjoin is a required attribute') if self[:dsc_newmachinedomainjoin].nil?
    end

  def dscmeta_resource_friendly_name; 'cWDS_ADUsePolicy' end
  def dscmeta_resource_name; 'cWDS_ADUsePolicy' end
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

  # Name:         NewMachineDomainJoin
  # Type:         string
  # IsMandatory:  True
  # Values:       ["Yes", "No"]
  newparam(:dsc_newmachinedomainjoin) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "NewMachineDomainJoin - Valid values are Yes, No."
    isrequired
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
      unless ['Yes', 'yes', 'No', 'no'].include?(value)
        fail("Invalid value '#{value}'. Valid values are Yes, No")
      end
    end
  end

  # Name:         PrestageUsingMAC
  # Type:         string
  # IsMandatory:  False
  # Values:       ["Yes", "No"]
  newparam(:dsc_prestageusingmac) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "PrestageUsingMAC - Valid values are Yes, No."
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
      unless ['Yes', 'yes', 'No', 'no'].include?(value)
        fail("Invalid value '#{value}'. Valid values are Yes, No")
      end
    end
  end

  # Name:         DomainSearchOrder
  # Type:         string
  # IsMandatory:  False
  # Values:       ["GCOnly", "DCFirst"]
  newparam(:dsc_domainsearchorder) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "DomainSearchOrder - Valid values are GCOnly, DCFirst."
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
      unless ['GCOnly', 'gconly', 'DCFirst', 'dcfirst'].include?(value)
        fail("Invalid value '#{value}'. Valid values are GCOnly, DCFirst")
      end
    end
  end

  # Name:         NewMachineOUType
  # Type:         string
  # IsMandatory:  False
  # Values:       ["ServerDomain", "UserDomain", "UserOU", "Custom"]
  newparam(:dsc_newmachineoutype) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "NewMachineOUType - Valid values are ServerDomain, UserDomain, UserOU, Custom."
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
      unless ['ServerDomain', 'serverdomain', 'UserDomain', 'userdomain', 'UserOU', 'userou', 'Custom', 'custom'].include?(value)
        fail("Invalid value '#{value}'. Valid values are ServerDomain, UserDomain, UserOU, Custom")
      end
    end
  end

  # Name:         PreferredDC
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_preferreddc) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "PreferredDC"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         PreferredGC
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_preferredgc) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "PreferredGC"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         MachineNamingPolicy
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_machinenamingpolicy) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "MachineNamingPolicy"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         NewMachineOU
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_newmachineou) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "NewMachineOU"
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

Puppet::Type.type(:dsc_cwds_adusepolicy).provide :powershell, :parent => Puppet::Type.type(:base_dsc).provider(:powershell) do
  confine :true => (Gem::Version.new(Facter.value(:powershell_version)) >= Gem::Version.new('5.0.10240.16384'))
  defaultfor :operatingsystem => :windows

  mk_resource_methods
end
