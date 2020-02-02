# frozen_string_literal: true

module Greed
  module Cookie
    module DomainHandlerTest
      RSpec.describe DomainHandler do
        let(:domain_a) do
          subject.determine_domain('a.example.com', nil)
        end
        it 'should use the current domain as a default when no domain supplied with cookies' do
          expect { domain_a }.not_to raise_error
          expect(domain_a).to eq(
            domain: 'a.example.com',
            include_subdomains: false,
          )
        end

        let(:domain_b) do
          subject.determine_domain('127.0.0.1', '0.1')
        end
        it 'should handles IP addresses and domain names differently' do
          expect { domain_b }.to raise_error(CrossDomainViolation)
        end

        let(:domain_c) do
          subject.determine_domain('127.0.0.1', '127.0.0.1')
        end
        it 'should not include subdomain matching for an IP address' do
          expect(domain_c).to include(
            include_subdomains: false,
          )
        end

        let(:domain_d) do
          subject.determine_domain('a.example.com', '...example.com')
        end
        it 'should rejects weird domain set by cookies' do
          expect { domain_d }.to raise_error(MalformedCookieDomain)
        end

        let(:domain_e) do
          subject.determine_domain('localhost', 'localhost')
        end
        it 'should allow localhost domain' do
          expect(domain_e).to eq(
            domain: 'localhost',
            include_subdomains: true,
          )
        end

        let(:domain_f) do
          subject.determine_domain('workplace.facebookcorewwwi.onion', 'onion')
        end
        it 'should not allow setting cookies on known public suffixes' do
          expect { domain_f }.to raise_error(CrossDomainViolation)
        end

        let(:domain_g) do
          subject.determine_domain('workplace.facebookcorewwwi.onion', 'facebookcorewwwi.onion')
        end
        it 'should allow setting cookies on parent domains' do
          expect(domain_g).to eq(
            domain: 'facebookcorewwwi.onion',
            include_subdomains: true,
          )
        end
      end
    end
  end
end
