require 'pathname'

Puppet::Type.newtype(:dsc_xcmcaddgpo) do
  require Pathname.new(__FILE__).dirname + '../../' + 'puppet/type/base_dsc'
  require Pathname.new(__FILE__).dirname + '../../puppet_x/puppetlabs/dsc_type_helpers'


  @doc = %q{
    The DSC xCMCAddGPO resource type.
    Automatically generated from
    'xCMCAD/DSCResources/xCMCAddGPO/xCMCAddGPO.schema.mof'

    To learn more about PowerShell Desired State Configuration, please
    visit https://technet.microsoft.com/en-us/library/dn249912.aspx.

    For more information about built-in DSC Resources, please visit
    https://technet.microsoft.com/en-us/library/dn249921.aspx.

    For more information about xDsc Resources, please visit
    https://github.com/PowerShell/DscResources.
  }

  validate do
      fail('dsc_gponame is a required attribute') if self[:dsc_gponame].nil?
      fail('dsc_ou is a required attribute') if self[:dsc_ou].nil?
    end

  def dscmeta_resource_friendly_name; 'xCMCAddGPO' end
  def dscmeta_resource_name; 'xCMCAddGPO' end
  def dscmeta_module_name; 'xCMCAD' end
  def dscmeta_module_version; '1.0.0' end

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

  # Name:         OU
  # Type:         string
  # IsMandatory:  True
  # Values:       None
  newparam(:dsc_ou) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "OU"
    isrequired
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
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

  # Name:         LinkEnabled
  # Type:         string
  # IsMandatory:  False
  # Values:       ["Yes", "No", "Unspecified"]
  newparam(:dsc_linkenabled) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "LinkEnabled - Valid values are Yes, No, Unspecified."
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
      unless ['Yes', 'yes', 'No', 'no', 'Unspecified', 'unspecified'].include?(value)
        fail("Invalid value '#{value}'. Valid values are Yes, No, Unspecified")
      end
    end
  end

  # Name:         GPOBackup_Name
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_gpobackup_name) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "GPOBackup_Name"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         GPOBackup_Path
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_gpobackup_path) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "GPOBackup_Path"
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

Puppet::Type.type(:dsc_xcmcaddgpo).provide :powershell, :parent => Puppet::Type.type(:base_dsc).provider(:powershell) do
  confine :true => (Gem::Version.new(Facter.value(:powershell_version)) >= Gem::Version.new('5.0.10240.16384'))
  defaultfor :operatingsystem => :windows

  mk_resource_methods
end
