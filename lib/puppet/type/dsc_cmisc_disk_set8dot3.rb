require 'pathname'

Puppet::Type.newtype(:dsc_cmisc_disk_set8dot3) do
  require Pathname.new(__FILE__).dirname + '../../' + 'puppet/type/base_dsc'
  require Pathname.new(__FILE__).dirname + '../../puppet_x/puppetlabs/dsc_type_helpers'


  @doc = %q{
    The DSC cMisc_Disk_Set8dot3 resource type.
    Automatically generated from
    'cMisc/DSCResources/cMisc_Disk_Set8dot3/cMisc_Disk_Set8dot3.schema.mof'

    To learn more about PowerShell Desired State Configuration, please
    visit https://technet.microsoft.com/en-us/library/dn249912.aspx.

    For more information about built-in DSC Resources, please visit
    https://technet.microsoft.com/en-us/library/dn249921.aspx.

    For more information about xDsc Resources, please visit
    https://github.com/PowerShell/DscResources.
  }

  validate do
      fail('dsc_disk is a required attribute') if self[:dsc_disk].nil?
    end

  def dscmeta_resource_friendly_name; 'cMisc_Disk_Set8dot3' end
  def dscmeta_resource_name; 'cMisc_Disk_Set8dot3' end
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

  # Name:         Disk
  # Type:         string
  # IsMandatory:  True
  # Values:       None
  newparam(:dsc_disk) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "Disk"
    isrequired
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         VolumeState
  # Type:         string
  # IsMandatory:  False
  # Values:       ["0", "1"]
  newparam(:dsc_volumestate) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "VolumeState - Valid values are 0, 1."
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
      unless ['0', '0', '1', '1'].include?(value)
        fail("Invalid value '#{value}'. Valid values are 0, 1")
      end
    end
  end


  def builddepends
    pending_relations = super()
    PuppetX::Dsc::TypeHelpers.ensure_reboot_relationship(self, pending_relations)
  end
end

Puppet::Type.type(:dsc_cmisc_disk_set8dot3).provide :powershell, :parent => Puppet::Type.type(:base_dsc).provider(:powershell) do
  confine :true => (Gem::Version.new(Facter.value(:powershell_version)) >= Gem::Version.new('5.0.10240.16384'))
  defaultfor :operatingsystem => :windows

  mk_resource_methods
end
