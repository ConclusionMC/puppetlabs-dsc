require 'pathname'

Puppet::Type.newtype(:dsc_cmisc_setwsus) do
  require Pathname.new(__FILE__).dirname + '../../' + 'puppet/type/base_dsc'
  require Pathname.new(__FILE__).dirname + '../../puppet_x/puppetlabs/dsc_type_helpers'


  @doc = %q{
    The DSC cMisc_SetWSUS resource type.
    Automatically generated from
    'cMisc/DSCResources/cMisc_SetWSUS/cMisc_SetWSUS.schema.mof'

    To learn more about PowerShell Desired State Configuration, please
    visit https://technet.microsoft.com/en-us/library/dn249912.aspx.

    For more information about built-in DSC Resources, please visit
    https://technet.microsoft.com/en-us/library/dn249921.aspx.

    For more information about xDsc Resources, please visit
    https://github.com/PowerShell/DscResources.
  }

  validate do
      fail('dsc_issingleinstance is a required attribute') if self[:dsc_issingleinstance].nil?
    end

  def dscmeta_resource_friendly_name; 'cMisc_SetWSUS' end
  def dscmeta_resource_name; 'cMisc_SetWSUS' end
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

  # Name:         IsSingleInstance
  # Type:         string
  # IsMandatory:  True
  # Values:       ["Yes"]
  newparam(:dsc_issingleinstance) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "IsSingleInstance - Valid values are Yes."
    isrequired
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
      unless ['Yes', 'yes'].include?(value)
        fail("Invalid value '#{value}'. Valid values are Yes")
      end
    end
  end

  # Name:         AcceptTrustedPublisherCerts
  # Type:         boolean
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_accepttrustedpublishercerts) do
    def mof_type; 'boolean' end
    def mof_is_embedded?; false end
    desc "AcceptTrustedPublisherCerts"
    validate do |value|
    end
    newvalues(true, false)
    munge do |value|
      PuppetX::Dsc::TypeHelpers.munge_boolean(value.to_s)
    end
  end

  # Name:         DisableWindowsUpdateAccess
  # Type:         boolean
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_disablewindowsupdateaccess) do
    def mof_type; 'boolean' end
    def mof_is_embedded?; false end
    desc "DisableWindowsUpdateAccess"
    validate do |value|
    end
    newvalues(true, false)
    munge do |value|
      PuppetX::Dsc::TypeHelpers.munge_boolean(value.to_s)
    end
  end

  # Name:         ElevateNonAdmins
  # Type:         boolean
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_elevatenonadmins) do
    def mof_type; 'boolean' end
    def mof_is_embedded?; false end
    desc "ElevateNonAdmins"
    validate do |value|
    end
    newvalues(true, false)
    munge do |value|
      PuppetX::Dsc::TypeHelpers.munge_boolean(value.to_s)
    end
  end

  # Name:         TargetGroup
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_targetgroup) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "TargetGroup"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         TargetGroupEnabled
  # Type:         boolean
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_targetgroupenabled) do
    def mof_type; 'boolean' end
    def mof_is_embedded?; false end
    desc "TargetGroupEnabled"
    validate do |value|
    end
    newvalues(true, false)
    munge do |value|
      PuppetX::Dsc::TypeHelpers.munge_boolean(value.to_s)
    end
  end

  # Name:         WUServer
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_wuserver) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "WUServer"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         WUStatusServer
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_wustatusserver) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "WUStatusServer"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         AUOptions
  # Type:         uint32
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_auoptions) do
    def mof_type; 'uint32' end
    def mof_is_embedded?; false end
    desc "AUOptions"
    validate do |value|
      unless (value.kind_of?(Numeric) && value >= 0) || (value.to_i.to_s == value && value.to_i >= 0)
          fail("Invalid value #{value}. Should be a unsigned Integer")
      end
    end
    munge do |value|
      PuppetX::Dsc::TypeHelpers.munge_integer(value)
    end
  end

  # Name:         AutoInstallMinorUpdates
  # Type:         boolean
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_autoinstallminorupdates) do
    def mof_type; 'boolean' end
    def mof_is_embedded?; false end
    desc "AutoInstallMinorUpdates"
    validate do |value|
    end
    newvalues(true, false)
    munge do |value|
      PuppetX::Dsc::TypeHelpers.munge_boolean(value.to_s)
    end
  end

  # Name:         DetectionFrequency
  # Type:         uint32
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_detectionfrequency) do
    def mof_type; 'uint32' end
    def mof_is_embedded?; false end
    desc "DetectionFrequency"
    validate do |value|
      unless (value.kind_of?(Numeric) && value >= 0) || (value.to_i.to_s == value && value.to_i >= 0)
          fail("Invalid value #{value}. Should be a unsigned Integer")
      end
    end
    munge do |value|
      PuppetX::Dsc::TypeHelpers.munge_integer(value)
    end
  end

  # Name:         DetectionFrequencyEnabled
  # Type:         boolean
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_detectionfrequencyenabled) do
    def mof_type; 'boolean' end
    def mof_is_embedded?; false end
    desc "DetectionFrequencyEnabled"
    validate do |value|
    end
    newvalues(true, false)
    munge do |value|
      PuppetX::Dsc::TypeHelpers.munge_boolean(value.to_s)
    end
  end

  # Name:         NoAutoRebootWithLoggedOnUsers
  # Type:         boolean
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_noautorebootwithloggedonusers) do
    def mof_type; 'boolean' end
    def mof_is_embedded?; false end
    desc "NoAutoRebootWithLoggedOnUsers"
    validate do |value|
    end
    newvalues(true, false)
    munge do |value|
      PuppetX::Dsc::TypeHelpers.munge_boolean(value.to_s)
    end
  end

  # Name:         NoAutoUpdate
  # Type:         boolean
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_noautoupdate) do
    def mof_type; 'boolean' end
    def mof_is_embedded?; false end
    desc "NoAutoUpdate"
    validate do |value|
    end
    newvalues(true, false)
    munge do |value|
      PuppetX::Dsc::TypeHelpers.munge_boolean(value.to_s)
    end
  end

  # Name:         RebootRelaunchTimeout
  # Type:         uint32
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_rebootrelaunchtimeout) do
    def mof_type; 'uint32' end
    def mof_is_embedded?; false end
    desc "RebootRelaunchTimeout"
    validate do |value|
      unless (value.kind_of?(Numeric) && value >= 0) || (value.to_i.to_s == value && value.to_i >= 0)
          fail("Invalid value #{value}. Should be a unsigned Integer")
      end
    end
    munge do |value|
      PuppetX::Dsc::TypeHelpers.munge_integer(value)
    end
  end

  # Name:         RebootRelaunchTimeoutEnabled
  # Type:         boolean
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_rebootrelaunchtimeoutenabled) do
    def mof_type; 'boolean' end
    def mof_is_embedded?; false end
    desc "RebootRelaunchTimeoutEnabled"
    validate do |value|
    end
    newvalues(true, false)
    munge do |value|
      PuppetX::Dsc::TypeHelpers.munge_boolean(value.to_s)
    end
  end

  # Name:         RebootWarningTimeout
  # Type:         uint32
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_rebootwarningtimeout) do
    def mof_type; 'uint32' end
    def mof_is_embedded?; false end
    desc "RebootWarningTimeout"
    validate do |value|
      unless (value.kind_of?(Numeric) && value >= 0) || (value.to_i.to_s == value && value.to_i >= 0)
          fail("Invalid value #{value}. Should be a unsigned Integer")
      end
    end
    munge do |value|
      PuppetX::Dsc::TypeHelpers.munge_integer(value)
    end
  end

  # Name:         RebootWarningTimeoutEnabled
  # Type:         boolean
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_rebootwarningtimeoutenabled) do
    def mof_type; 'boolean' end
    def mof_is_embedded?; false end
    desc "RebootWarningTimeoutEnabled"
    validate do |value|
    end
    newvalues(true, false)
    munge do |value|
      PuppetX::Dsc::TypeHelpers.munge_boolean(value.to_s)
    end
  end

  # Name:         RescheduleWaitTime
  # Type:         uint32
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_reschedulewaittime) do
    def mof_type; 'uint32' end
    def mof_is_embedded?; false end
    desc "RescheduleWaitTime"
    validate do |value|
      unless (value.kind_of?(Numeric) && value >= 0) || (value.to_i.to_s == value && value.to_i >= 0)
          fail("Invalid value #{value}. Should be a unsigned Integer")
      end
    end
    munge do |value|
      PuppetX::Dsc::TypeHelpers.munge_integer(value)
    end
  end

  # Name:         RescheduleWaitTimeEnabled
  # Type:         boolean
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_reschedulewaittimeenabled) do
    def mof_type; 'boolean' end
    def mof_is_embedded?; false end
    desc "RescheduleWaitTimeEnabled"
    validate do |value|
    end
    newvalues(true, false)
    munge do |value|
      PuppetX::Dsc::TypeHelpers.munge_boolean(value.to_s)
    end
  end

  # Name:         ScheduledInstallDay
  # Type:         uint32
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_scheduledinstallday) do
    def mof_type; 'uint32' end
    def mof_is_embedded?; false end
    desc "ScheduledInstallDay"
    validate do |value|
      unless (value.kind_of?(Numeric) && value >= 0) || (value.to_i.to_s == value && value.to_i >= 0)
          fail("Invalid value #{value}. Should be a unsigned Integer")
      end
    end
    munge do |value|
      PuppetX::Dsc::TypeHelpers.munge_integer(value)
    end
  end

  # Name:         ScheduledInstallTime
  # Type:         uint32
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_scheduledinstalltime) do
    def mof_type; 'uint32' end
    def mof_is_embedded?; false end
    desc "ScheduledInstallTime"
    validate do |value|
      unless (value.kind_of?(Numeric) && value >= 0) || (value.to_i.to_s == value && value.to_i >= 0)
          fail("Invalid value #{value}. Should be a unsigned Integer")
      end
    end
    munge do |value|
      PuppetX::Dsc::TypeHelpers.munge_integer(value)
    end
  end

  # Name:         UseWUServer
  # Type:         boolean
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_usewuserver) do
    def mof_type; 'boolean' end
    def mof_is_embedded?; false end
    desc "UseWUServer"
    validate do |value|
    end
    newvalues(true, false)
    munge do |value|
      PuppetX::Dsc::TypeHelpers.munge_boolean(value.to_s)
    end
  end

  # Name:         EnableFeaturedSoftware
  # Type:         boolean
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_enablefeaturedsoftware) do
    def mof_type; 'boolean' end
    def mof_is_embedded?; false end
    desc "EnableFeaturedSoftware"
    validate do |value|
    end
    newvalues(true, false)
    munge do |value|
      PuppetX::Dsc::TypeHelpers.munge_boolean(value.to_s)
    end
  end

  # Name:         IncludeRecommendedUpdates
  # Type:         boolean
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_includerecommendedupdates) do
    def mof_type; 'boolean' end
    def mof_is_embedded?; false end
    desc "IncludeRecommendedUpdates"
    validate do |value|
    end
    newvalues(true, false)
    munge do |value|
      PuppetX::Dsc::TypeHelpers.munge_boolean(value.to_s)
    end
  end

  # Name:         AUPowerManagement
  # Type:         boolean
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_aupowermanagement) do
    def mof_type; 'boolean' end
    def mof_is_embedded?; false end
    desc "AUPowerManagement"
    validate do |value|
    end
    newvalues(true, false)
    munge do |value|
      PuppetX::Dsc::TypeHelpers.munge_boolean(value.to_s)
    end
  end

  # Name:         NoAUAsDefaultShutdownOption
  # Type:         boolean
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_noauasdefaultshutdownoption) do
    def mof_type; 'boolean' end
    def mof_is_embedded?; false end
    desc "NoAUAsDefaultShutdownOption"
    validate do |value|
    end
    newvalues(true, false)
    munge do |value|
      PuppetX::Dsc::TypeHelpers.munge_boolean(value.to_s)
    end
  end

  # Name:         NoAUShutdownOption
  # Type:         boolean
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_noaushutdownoption) do
    def mof_type; 'boolean' end
    def mof_is_embedded?; false end
    desc "NoAUShutdownOption"
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

Puppet::Type.type(:dsc_cmisc_setwsus).provide :powershell, :parent => Puppet::Type.type(:base_dsc).provider(:powershell) do
  confine :true => (Gem::Version.new(Facter.value(:powershell_version)) >= Gem::Version.new('5.0.10240.16384'))
  defaultfor :operatingsystem => :windows

  mk_resource_methods
end
