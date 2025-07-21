# typed: strict
# frozen_string_literal: true

require "downloadable"

module Homebrew
  module API
    class JSONDownloadStrategy < AbstractDownloadStrategy
      sig { params(url: String, name: String, version: T.any(NilClass, String, Version), meta: T.untyped).void }
      def initialize(url, name, version, **meta)
        super
        @target = T.let(meta.fetch(:target), Pathname)
        @stale_seconds = T.let(meta.fetch(:stale_seconds), Integer)
      end

      sig { override.params(timeout: T.nilable(T.any(Integer, Float))).returns(Pathname) }
      def fetch(timeout: nil)
        with_context quiet: quiet? do
          Homebrew::API.fetch_json_api_file(url, target: cached_location, stale_seconds: meta.fetch(:stale_seconds))
        end
        cached_location
      end

      sig { override.returns(Pathname) }
      def cached_location
        meta.fetch(:target)
      end
    end

    class JSONDownload
      include Downloadable

      sig { params(url: String, target: Pathname, stale_seconds: Integer).void }
      def initialize(url, target:, stale_seconds:)
        super()
        @url = T.let(URL.new(url, using: API::JSONDownloadStrategy, target:, stale_seconds:), URL)
        @target = target
        @stale_seconds = stale_seconds
      end

      sig { override.returns(API::JSONDownloadStrategy) }
      def downloader
        T.cast(super, API::JSONDownloadStrategy)
      end

      sig { override.returns(String) }
      def name = download_name

      sig { override.returns(String) }
      def download_type = "JSON API"
    end
  end
end
