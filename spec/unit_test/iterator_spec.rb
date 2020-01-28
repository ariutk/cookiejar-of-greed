# frozen_string_literal: true

module Greed
  module Cookie
    module IteratorTest
      class Proxy
        include Iterator

        def iterate_cookie_domain(*args)
          super(*args)
        end

        def iterate_cookie_path(*args)
          super(*args)
        end
      end

      RSpec.describe Iterator do
        subject { Proxy.new }

        let(:test_domain_a) { 'en.wikipedia.co.uk' }
        let(:test_domain_enumerator_a) { subject.iterate_cookie_domain(test_domain_a) }
        it 'should be able to iterate through localhost' do
          expect(test_domain_enumerator_a.to_a).to eq(%w[en.wikipedia.co.uk wikipedia.co.uk])
        end

        let(:test_domain_b) { 'localhost' }
        let(:test_domain_enumerator_b) { subject.iterate_cookie_domain(test_domain_b) }
        it 'should be able to iterate through a valid domain' do
          expect(test_domain_enumerator_b.to_a).to eq(%w[localhost])
        end

        let(:test_domain_c) { 'workplace.facebookcorewwwi.onion' }
        let(:test_domain_enumerator_c) { subject.iterate_cookie_domain(test_domain_c) }
        it 'should be able to iterate through a private-used domain' do
          expect(test_domain_enumerator_c.to_a).to eq(%w[workplace.facebookcorewwwi.onion facebookcorewwwi.onion])
        end

        let(:test_path_a) { '/a/b/c' }
        let(:test_path_enumerator_a) { subject.iterate_cookie_path(test_path_a) }
        it 'should be able to iterate through a path' do
          expect(test_path_enumerator_a.to_a).to eq(%w[/a/b/c /a/b /a /])
        end

        let(:test_path_b) { '/' }
        let(:test_path_enumerator_b) { subject.iterate_cookie_path(test_path_b) }
        it 'should be able to iterate through the root path' do
          expect(test_path_enumerator_b.to_a).to eq(%w[/])
        end

        let(:test_path_c) { '' }
        let(:test_path_enumerator_c) { subject.iterate_cookie_path(test_path_c) }
        it 'should not choke on a blank string' do
          expect(test_path_enumerator_c.to_a).to eq(%w[/])
        end
      end
    end
  end
end