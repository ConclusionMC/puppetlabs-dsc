require 'pathname'

Puppet::Type.newtype(:dsc_cmisc_setlocale) do
  require Pathname.new(__FILE__).dirname + '../../' + 'puppet/type/base_dsc'
  require Pathname.new(__FILE__).dirname + '../../puppet_x/puppetlabs/dsc_type_helpers'


  @doc = %q{
    The DSC cMisc_SetLocale resource type.
    Automatically generated from
    'cMisc/DSCResources/cMisc_SetLocale/cMisc_SetLocale.schema.mof'

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

  def dscmeta_resource_friendly_name; 'cMisc_SetLocale' end
  def dscmeta_resource_name; 'cMisc_SetLocale' end
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

  # Name:         Locale
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_locale) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "Locale"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         LocaleName
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_localename) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "LocaleName"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         s1159
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_s1159) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "s1159"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         s2359
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_s2359) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "s2359"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         sCountry
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_scountry) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "sCountry"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         sCurrency
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_scurrency) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "sCurrency"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         sDate
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_sdate) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "sDate"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         sDecimal
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_sdecimal) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "sDecimal"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         sGrouping
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_sgrouping) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "sGrouping"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         sLanguage
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_slanguage) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "sLanguage"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         sList
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_slist) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "sList"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         sLongDate
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_slongdate) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "sLongDate"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         sMonDecimalSep
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_smondecimalsep) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "sMonDecimalSep"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         sMonGrouping
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_smongrouping) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "sMonGrouping"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         sMonThousandSep
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_smonthousandsep) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "sMonThousandSep"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         sNativeDigits
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_snativedigits) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "sNativeDigits"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         sNegativeSign
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_snegativesign) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "sNegativeSign"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         sPositiveSign
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_spositivesign) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "sPositiveSign"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         sShortDate
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_sshortdate) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "sShortDate"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         sThousand
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_sthousand) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "sThousand"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         sTime
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_stime) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "sTime"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         sTimeFormat
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_stimeformat) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "sTimeFormat"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         sShortTime
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_sshorttime) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "sShortTime"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         sYearMonth
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_syearmonth) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "sYearMonth"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         iCalendarType
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_icalendartype) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "iCalendarType"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         iCountry
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_icountry) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "iCountry"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         iCurrDigits
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_icurrdigits) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "iCurrDigits"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         iCurrency
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_icurrency) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "iCurrency"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         iDate
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_idate) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "iDate"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         iDigits
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_idigits) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "iDigits"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         NumShape
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_numshape) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "NumShape"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         iFirstDayOfWeek
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_ifirstdayofweek) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "iFirstDayOfWeek"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         iFirstWeekOfYear
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_ifirstweekofyear) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "iFirstWeekOfYear"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         iLZero
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_ilzero) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "iLZero"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         iMeasure
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_imeasure) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "iMeasure"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         iNegCurr
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_inegcurr) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "iNegCurr"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         iNegNumber
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_inegnumber) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "iNegNumber"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         iPaperSize
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_ipapersize) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "iPaperSize"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         iTime
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_itime) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "iTime"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         iTimePrefix
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_itimeprefix) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "iTimePrefix"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         iTLZero
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_itlzero) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "iTLZero"
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

Puppet::Type.type(:dsc_cmisc_setlocale).provide :powershell, :parent => Puppet::Type.type(:base_dsc).provider(:powershell) do
  confine :true => (Gem::Version.new(Facter.value(:powershell_version)) >= Gem::Version.new('5.0.10240.16384'))
  defaultfor :operatingsystem => :windows

  mk_resource_methods
end
