# frozen_string_literal: true
require 'active_support/core_ext/object/blank'
require 'ipaddr'
require 'public_suffix'

module Greed
  module Cookie
    class DomainError < Error
    end
    class CrossDomainViolation < DomainError
    end
    class MalformedCookieDomain < DomainError
    end

    class DomainHandler
      def determine_domain(document_domain, cookie_domain)
        unless cookie_domain.present?
          return {
            domain: document_domain, # cookie domain not present
            include_subdomains: false
          }
        end
        document_ip_address = begin
          ::IPAddr.new(document_domain)
        rescue ::IPAddr::Error
          nil
        end
        if document_ip_address
          # handles IP Addresses
          cookie_ip_address = begin
            ::IPAddr.new(cookie_domain)
          rescue ::IPAddr::Error
            raise CrossDomainViolation
          end
          raise CrossDomainViolation unless cookie_ip_address == document_ip_address
          return {
            domain: cookie_ip_address.to_s, # normalized
            include_subdomains: false
          }
        end
        # ignore leading dot
        matched_data = /\A\s*\.?(?!\.)(\S+)\s*\z/.match(cookie_domain)
        raise MalformedCookieDomain unless matched_data
        cookie_domain = matched_data[1]
        if document_domain == cookie_domain
          # exact domain matched
          return {
            domain: document_domain,
            include_subdomains: true
          }
        end
        # prevent setting cookie on a top level domain
        # "localhost" use cases should already ruled out with the exact domain match condition
        raise CrossDomainViolation unless ::PublicSuffix.valid?(cookie_domain, ignore_private: true)
        # prevent parent domain from setting cookie of a subdomain
        raise CrossDomainViolation unless (document_domain[
          document_domain.size - cookie_domain.size,
          cookie_domain.size
        ] == cookie_domain) && \
        (document_domain[
          document_domain.size - cookie_domain.size - 1
        ] == '.')
        {
          domain: cookie_domain, # set cookie for its parent domain
          include_subdomains: true
        }
      end
    end
  end
end
