require 'nokogiri'
require 'curl'
require_relative 'pb_core'

class ValidatedPBCore < PBCore
  SCHEMA = Nokogiri::XML::Schema(File.read('lib/pbcore-2.1.xsd'))

  def initialize(xml)
    super(xml)
    schema_validate(xml)
    method_validate
    url_validate
  end

  private

  def schema_validate(xml)
    document = Nokogiri::XML(xml)
    errors = SCHEMA.validate(document)
    return if errors.empty?
    fail 'Schema validation errors: ' + errors.join("\n")
  end

  def method_validate
    # Warm the object and check for missing data, beyond what the schema enforces.
    errors = []
    (PBCore.instance_methods(false) - [:to_solr]).each do |method|
      begin
        send(method)
      rescue => e
        errors << (["'##{method}' failed: #{e.message}"] + e.backtrace[0..2]).join("\n")
      end
    end
    return if errors.empty?
    fail 'Method validation errors: ' + errors.join("\n")
  end

  def url_validate
    errors = []
    expected_url_methods = Set.new([
      :outside_url, :aapb_url, :boston_tv_news_url,
      :thumbnail_src, :proxy_srcs, :transcript_src
    ])
    url_methods = Set.new(PBCore.instance_methods(false).grep(/(src|url)s?/))
    fail("Unexpected URL methods: #{url_methods.sort} != #{expected_url_methods.sort}") if url_methods != expected_url_methods
    url_methods.each do |method|
      urls = [send(method)].select { |u| u }.flatten
      urls.each do |url|
        begin
          if url.match(/^\//)
            path = __dir__ + '/../../public' + url
            errors << "No file at #{path}" unless File.exist?(path)
          else
            Curl::Easy.new(url).tap do |curl|
              curl.headers['Referer'] = 'http://openvault.wgbh.org/'
              curl.http_head
              unless curl.response_code == 200
                errors << "HEAD #{url} (from ##{method}) not 200: #{curl.status}"
              end
            end
          end
        rescue => e
          errors << (["'##{method}' failed: #{e.message}"] + e.backtrace[0..2]).join("\n")
        end
      end
    end
    return if errors.empty?
    fail 'Method validation errors: ' + errors.join("\n")
  end
end
