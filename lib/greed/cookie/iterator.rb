# frozen_string_literal: true
require 'active_support/core_ext/object/blank'
require 'strscan'

module Greed
  module Cookie
    module Iterator
      private

      def iterate_cookie_domain(domain_name)
        chunk_scanner = /\A[-_\w\d]+\./
        ::Enumerator.new do |yielder|
          scanner = ::StringScanner.new(domain_name.downcase)
          until scanner.eos?
            removed_part = scanner.scan(chunk_scanner)
            break unless removed_part
            yielder << scanner.rest
          end
        end.yield_self do |parent_domains|
          [domain_name].chain(parent_domains.lazy).lazy
        end
      end

      def iterate_cookie_path(path)
        ensured_absolute = path.sub(/\A\/*/, ?/)
        ::Enumerator.new do |yielder|
          scanner = ::File.expand_path(?., ensured_absolute)
          loop do
            yielder << scanner
            break if (scanner.blank?) || (?/ == scanner)
            scanner = ::File.expand_path('..', scanner)
          end
        end
      end
    end
  end
end
