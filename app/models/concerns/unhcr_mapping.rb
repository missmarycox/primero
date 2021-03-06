module UNHCRMapping
  extend ActiveSupport::Concern

  included do
    property :unhcr_needs_codes

    before_save :map_protection_concerns_to_unhcr_codes
  end

  def map_protection_concerns_to_unhcr_codes
    if self.is_a? Child
      unhcr_mapping = SystemSettings.current.unhcr_needs_codes_mapping if SystemSettings.current.present?

      if unhcr_mapping.present?
        concerns = self.protection_concerns

        if unhcr_mapping.autocalculate == true && unhcr_mapping.mapping.present? && concerns.present?
          mapping = unhcr_mapping.mapping

          self.unhcr_needs_codes = concerns.map{ |concern| mapping[concern] }.compact.uniq
        else
          self.unhcr_needs_codes = nil
        end
      end
    end
  end

end
