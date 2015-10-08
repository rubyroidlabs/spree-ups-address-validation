module Spree
  Order.class_eval do

    attr_accessor :skip_ups_validation

    validate :shipping_address_is_valid_via_ups, if: :should_perform_ups_validation

    private

      def shipping_address_is_valid_via_ups
        if ship_address.ups_response.no_candidates?
          errors.add(:base, Spree.t(:ups_address_invalid))
        elsif ship_address.ups_response.ambiguous?
          errors.add(:base, Spree.t(:ups_address_ambiguous))
        elsif ship_address.ups_suggestions.any?
          suggested = ship_address.ups_suggestions.first
          error_message = 'Looks like you did some misspellings. Check the folowing fields: <br>'
          error_message << "check address1-field, maybe you mean #{suggested.street1}<br>" unless ship_address.address1 == suggested.street1
          error_message << "check city-field, maybe you mean #{suggested.city}<br>" unless ship_address.city == suggested.city
          error_message << "check state-field, maybe you mean #{suggested.state}<br>" unless ship_address.state.abbr == suggested.state
          error_message << "check zip-field, maybe you mean #{suggested.zip}<br>" unless ship_address.zipcode == suggested.zip || ship_address.zipcode == [suggested.zip, suggested.zip_extended].join('-')
          errors.add(:base, error_message)
        end
      end

      def should_perform_ups_validation
        skip_ups_validation == "0" && ship_address.is_us_50?
      end
  end
end
