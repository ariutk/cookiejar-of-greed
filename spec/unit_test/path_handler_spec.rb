# frozen_string_literal: true

module Greed
  module Cookie
    module PathHandlerTest
      RSpec.describe PathHandler do
        let(:path_a) do
          subject.determine_path('/a/b', nil)
        end
        it 'should be generate the default path when encountering set-cookie header without path' do
          expect { path_a }.not_to raise_error
          expect(path_a).to eq(path: '/a')
        end

        let(:path_b) do
          subject.determine_path('', nil)
        end
        it 'should output root path as the last fallback default' do
          expect { path_b }.not_to raise_error
          expect(path_b).to eq(path: ?/)
        end

        let(:path_c) do
          subject.determine_path('', ?/)
        end
        it 'should always accept root path set by the server' do
          expect { path_c }.not_to raise_error
          expect(path_c).to eq(path: ?/)
        end

        let(:path_d) do
          subject.determine_path('/a/b', '/a/c')
        end
        it 'should not allow setting cookie path outside of the current document path' do
          expect { path_d }.to raise_error(PathViolation)
        end

        let(:path_e) do
          subject.determine_path('/a/b/c/d', '/a/b')
        end
        it 'should accepts cookie path within the current document path' do
          expect { path_e }.not_to raise_error
          expect(path_e).to eq(path: '/a/b')
        end
      end
    end
  end
end
