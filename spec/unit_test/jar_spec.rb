# frozen_string_literal: true

module Greed
  module Cookie
    module JarTest
      RSpec.describe Jar do
        # integration test mainly to ensure no runtime error
        # by maximizing code coverage

        it 'should be able to store cookies' do
          expect do
            subject.parse_set_cookie('http://localhost/', 'a=b')
            subject.parse_set_cookie('http://localhost/', 'c=d; domain=:')
            subject.parse_set_cookie('http://localhost/', 'e=f; max-age=0')
            subject.parse_set_cookie('http://localhost/', 'a=; max-age=0')
            subject.parse_set_cookie('http://localhost/', 'g=h; max-age=500')
          end.not_to raise_error
          state = subject.dump
          new_jar = Jar.new(state)
          expect(new_jar.cookie_header_for('http://localhost/')).to eq('g=h')
          expect(new_jar.cookie_header_for('https://localhost/')).to eq('g=h')
          expect(new_jar.cookie_header_for('ftp://localhost/')).to be_blank
          expect(new_jar.cookie_header_for('http:/')).to be_blank
          expect(new_jar.cookie_header_for(nil)).to be_blank
          expect(new_jar.cookie_header_for(nil)).to be_blank
          new_jar.parse_set_cookie('http://192.168.0.1/', 'i=j')
          expect(new_jar.cookie_header_for('http://192.168.0.1/')).to eq('i=j')
        end

      end
    end
  end
end