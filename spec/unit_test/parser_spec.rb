# frozen_string_literal: true

module Greed
  module Cookie
    module ParserTest

      RSpec.describe Parser do
        let(:token) { '5cb6-6788,7cc8,gdiq/Dikg==' }
        let(:expires) { 'Sat, 23-Jan-2021 13:55:13 GMT' }

        let(:parsed_a) do
          subject.parse(
            "token=#{token}; "\
            "expires=#{expires}; "\
            'path=/; '\
            'secure; '\
            'HttpOnly'
          )
        end
        it 'should be able to parse set-cookie header with commas in the value' do
          expect { parsed_a }.not_to raise_error
          parsed = parsed_a
          expect(parsed).to be_present
          expect(parsed).to include(
            value: token,
            path: ?/,
            secure: true,
            httponly: true,
          )
          expect(parsed[:expires]).to eq(::Time.parse(expires))
        end

        let(:parsed_b) do
          subject.parse(
            "token=#{token}; "\
            "expires=null; "\
            'path=/; '\
            'secure; '\
            'HttpOnly'
          )
        end
        it 'should be able to handles an invalid expiration value' do
          expect { parsed_b }.not_to raise_error
          parsed = parsed_b
          expect(parsed).to be_present
          expect(parsed[:expires]).to be_nil
        end

        let(:parsed_c) do
          subject.parse('asdfghjkl.zxcvbnm=poiuytrewq; =;')
        end
        it 'should return nil on unparsable occurrence' do
          expect { parsed_c }.not_to raise_error
          parsed = parsed_c
          expect(parsed).to be_nil
        end

      end
    end
  end
end