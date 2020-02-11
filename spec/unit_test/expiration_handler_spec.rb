# frozen_string_literal: true
require 'active_support/core_ext/integer/time'

module Greed
  module Cookie
    module ExpirationHandlerTest
      RSpec.describe ExpirationHandler do
        let(:current_time) { ::Time.now }
        let(:next_10_minute) { current_time + 10.minutes }

        let(:expiration_a) do
          subject.calculate_expiration(current_time, 5.minutes.to_i, next_10_minute)
        end
        it 'should prioritize max-age than absolute expiration' do
          expect { expiration_a }.not_to raise_error
          expect(expiration_a).to include(expires: current_time + 5.minutes)
        end
        it 'should output retrieval time' do
          expect(expiration_a).to include(retrieved_at: current_time)
        end

        let(:expiration_b) do
          subject.calculate_expiration(current_time, nil, next_10_minute)
        end
        it 'should fallback to absolute expiration value when no max-age set' do
          expect { expiration_b }.not_to raise_error
          expect(expiration_b).to include(expires: next_10_minute)
        end

        let(:expiration_c) do
          subject.calculate_expiration(current_time, 0, nil)
        end
        it 'should raise an exception when the cookie already expired' do
          expect { expiration_c }.to raise_error(Expired)
        end

        let(:expiration_d) do
          subject.calculate_expiration(current_time, nil, nil)
        end
        it 'should allow session cookies' do
          expect { expiration_d }.not_to raise_error
          expect(expiration_d).to include(expires: nil)
        end
      end
    end
  end
end
