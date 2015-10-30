module Spree
  Order.class_eval do

    attr_accessor :skip_ups_validation

    validate :shipping_address_is_valid_via_ups, if: :should_perform_ups_validation

    private

      def shipping_address_is_valid_via_ups
        prepare_address
        if ship_address.ups_response.no_candidates?
          errors.add(:base, Spree.t(:ups_address_invalid))
        elsif ship_address.ups_response.ambiguous?
          errors.add(:base, Spree.t(:ups_address_ambiguous))
        elsif ship_address.ups_suggestions.any?
          suggested = ship_address.ups_suggestions.first
          error_message = 'We found some errors in your information. Please check the following fields: <br>'
          error_message << "Address1: Did you mean #{suggested.street1}<br>" unless ship_address.address1.gsub('.','') == suggested.street1
          error_message << "Address2: Did you mean #{suggested.street2}<br>" if ship_address.address2.present? && prepare_address2(ship_address.address2) != prepare_address2(suggested.street2)
          error_message << "City: Did you mean #{suggested.city}<br>" unless ship_address.city == suggested.city
          error_message << "State: Did you mean #{suggested.state}<br>" unless ship_address.state.abbr == suggested.state
          error_message << "Zip: Did you mean #{suggested.zip}<br>" unless ship_address.zipcode == suggested.zip
          errors.add(:base, error_message)
        end
      end

      def should_perform_ups_validation
        skip_ups_validation == "0" && ship_address.is_us_50?
      end

      def prepare_address2(address2)
        result = address2
        result.gsub('APT', '').gsub('APARTMENT', '').gsub('#', '').gsub(' ', '')
      end

      def prepare_address
        ship_address.address1 = ship_address.address1.gsub(' WEST ', ' W ').gsub(' EAST ', ' E ')
        ship_address.zipcode = ship_address.zipcode.gsub(' ', '')
      end
  end
end
