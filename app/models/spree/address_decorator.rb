module Spree
  Address.class_eval do

    @@us_50_states = %w[AL AK AZ AR CA CO CT DE FL GA HI ID IL IN IA KS KY LA ME MD MA MI MN MS MO MT NE NV NH NJ NM NY NC ND OH OK OR PA RI SC SD TN TX UT VT VA WA WV WI WY]

    @ups_response = nil
    @ups_suggestions = nil

    def ups_response
      @ups_response ||= get_ups_response
    end

    def ups_suggestions
      return [] if empty?
      return [] if ups_response.no_candidates?
      # Strip out any suggestions which match our current address
      @ups_suggestions ||= ups_response.suggestions.reject do |s|
        s.street1 == address1.gsub('.', '') \
        && (s.street2.blank? && address2.blank? || prepare_address2(s.street2) == prepare_address2(address2)) \
        && s.city == city \
        && s.state == state_text \
        && s.zip == zipcode
      end
      @ups_suggestions
    end

    def is_us_50?
      # return true if it's one of the US 50 states. otherwise, UPS Address Validation won't cover it
      state.country.iso3 == "USA" && @@us_50_states.include?(state.abbr)
    end

    private
      def get_ups_response
        address = AddressValidator::Address.new(
          name: full_name,
          street1: address1,
          street2: address2,
          city: city,
          state: state_text,
          zip: zipcode,
          country: country.try(:iso),
        )
        validator = AddressValidator::Validator.new
        validator.validate(address)
      end

      def prepare_address2(address2)
        if address2.present?
          result = address2
          result.gsub('APT', '').gsub('APARTMENT', '').gsub('#', '').gsub(' ', '')
        end
      end
  end
end
