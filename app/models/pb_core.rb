require 'rexml/document'
require 'rexml/xpath'
require 'solrizer'
require_relative '../../lib/html_scrubber'
require_relative '../../lib/open_vault'
require_relative 'xml_backed'
require_relative 'pb_core_name_role'
require_relative '../../lib/formatter'

class PBCore # rubocop:disable Metrics/ClassLength
  # rubocop:disable Style/EmptyLineBetweenDefs
  include XmlBacked
  
  def series_title
    @series_title ||= xpath('/*/pbcoreTitle[@titleType="Series"]')
  end
  def program_title
    @program_title ||= xpath('/*/pbcoreTitle[@titleType="Program"]')
  end
  def program_number
    @program_number ||= xpath('/*/pbcoreTitle[@titleType="Program Number"]')
  end
  def item_title
    @item_title ||= xpath('/*/pbcoreTitle[@titleType="Open Vault Title"]')
  end
  
  def date
    @date ||= xpath('/*/pbcoreAssetDate[@dateType="Item Date"]')
  end
  def year
    @year ||= date.match(/(\d{4})/)[1]
  end
  
  def title
    @title ||= [series_title, program_title, item_title].select{|x| x}.join('; ')
  end
  
  def duration
    @duration ||= xpath('/*/pbcoreAnnotation[@annotationType="Duration"]')
      .gsub(/(\d\d:\d\d:\d\d):\d\d/, '\1')
  end
  def asset_type
    @asset_type ||= 'asset_type' # TODO
  end
  def series_description
    @series_description ||= 'series_description' # TODO
  end
#  def series_date
#    @series_date ||= 'series_date' # TODO
#  end
  def program_description
    @program_description ||= 'program_description' # TODO
  end
  def item_description
    @item_description ||= 'item_description' # TODO
  end
  def creators
    @creators ||= [
      PBCoreNameRole.new(nil, 'creator_1_name', 'creator_1_role'),
      PBCoreNameRole.new(nil, 'creator_2_name', 'creator_2_role')
    ] # TODO
  end
  def contributors
    @contributors ||= [
      PBCoreNameRole.new(nil, 'contrib_1_name', 'contrib_1_role'),
      PBCoreNameRole.new(nil, 'contrib_2_name', 'contrib_2_role')
    ] # TODO
  end
  def publishers
    @publishers ||= ['publisher_1', 'publisher_2'] # TODO
  end
  def subjects
    @subject ||= ['subject_1', 'subject_2'] # TODO
  end
  def locations
    @location ||= ['location_1', 'location_2'] # TODO
  end
  def genres
    @genre ||= ['genre_1', 'genre_2'] # TODO
  end
  def topics
    @topic ||= ['topic_1', 'topic_2'] # TODO
  end
  
  def rights_summary
    @rights_summary ||= "#{rights_holder}; #{rights_credit}"
  end
  def rights_holder
    @rights_holder ||= 'rights_holder' # TODO
  end
  def rights_credit
    @rights_credit ||= 'rights_credit' # TODO
  end
  
  def id
    @id ||= 'A_00B0C50853C64A71935737EF7A4DA66C' # TODO
  end
  URL_BASE = 'https://s3.amazonaws.com/openvault.wgbh.org/catalog'
  def thumbnail_src
    @thumb_src ||= "#{URL_BASE}/asset_thumbnails/#{id}.jpg"
    # TODO: some have defaults?
  end
  def proxy_src
    @media_src ||= "#{URL_BASE}/asset_proxies/#{id}.#{extension}" # TODO
  end
  def extension
    case media_type
    when VIDEO
      'mp4'
    when AUDIO
      'mp3'
    when IMAGE
      'jpg'
    end
  end
  def transcript_src
    @transcript_src ||= "#{URL_BASE}/asset_transcripts/#{id}.xml"
  end
  def captions_src
    nil # TODO
  end
  VIDEO = 'Video'
  AUDIO = 'Audio'
  IMAGE = 'Image'
  def media_type
    @media_type ||= AUDIO # TODO
  end
  def video?
    media_type == VIDEO
  end
  def audio?
    media_type == AUDIO
  end
  def image?
    media_type == IMAGE
  end

  def us_only?
    # TODO
  end
  def password_required?
    # TODO
  end
  
  def aapb_url
    @aapb_url ||= 'aapb_url' # TODO
  end
  def boston_tv_news_url
    @boston_tv_news_url ||= 'boston_tv_news_url' # TODO
  end

  def special_collections
    # TODO
  end  
  def special_collection_tabs
    # TODO
  end
  def scholar_exhibits
    # TODO
  end
  
  def playlist
    # TODO
  end
  def playlist_order
    # TODO
  end
  def playlist_next_id
    # TODO
  end
  def playlist_prev_id
    # TODO
  end
  
  # rubocop:enable Style/EmptyLineBetweenDefs

  def to_solr
    # Only just before indexing do we check for the existence of captions:
    # We don't want to ping S3 multiple times, and we don't want to store all
    # of a captions/transcript file in solr (much less in the pbcore).
    # --> We only want to say that it exists, and we want to index the words.
    
#    doc_with_caption_flag = @doc.deep_clone
#    # perhaps paranoid, but I don't want this method to have side effects.
#    
#    caption_id = id.gsub('_','-')
#    caption_base = 'https://s3.amazonaws.com/americanarchive.org/captions'
#    caption_url = "#{caption_base}/#{caption_id}/#{caption_id}.srt1.srt"
#    caption_response = Net::HTTP.get_response(URI.parse(caption_url))
#    if caption_response.code == '200'
#      pre_existing = REXML::XPath.match(doc_with_caption_flag, "//pbcoreAnnotation[@annotationType='#{CAPTIONS_ANNOTATION}']").first
#      if pre_existing
#        pre_existing.parent.elements.delete(pre_existing)
#      end
#      caption_body = caption_response.body.gsub(/[^[:print:][\n]&&[^ ]]+/, ' ')
#      # "\n" is not in the [:print:] class, but it should be preserved.
#      # "&&" is intersection: we also want to match " ", 
#      # so that control-chars + spaces collapse to a single space.
#      REXML::XPath.match(doc_with_caption_flag, '/*/pbcoreInstantiation').last.next_sibling.next_sibling = 
#        REXML::Element.new('pbcoreAnnotation').tap do |el|
#          el.add_attribute('annotationType', CAPTIONS_ANNOTATION)
#          el.add_text(caption_url)
#        end
#    end
    
    {
      'id' => id,
      'xml' => '<xml/>', # TODO; Formatter.instance.format(doc_with_caption_flag),

      # indexed:
      'text' => text, # TODO + [caption_body].select { |optional| optional },

      # *************************************
      #     Keep in sync with schema.xml
      # *************************************
      
      'title' => title,
      'thumbnail_src' => thumbnail_src,
      
      'year' => year,
      
      # links from details and series pages:
      'series_title' => series_title,
      'program_title' => program_title,
      
      'subjects' => subjects,
      'locations' => locations,
      
      # UI facets
      'genres' => genres,
      'topics' => topics,
      
      'asset_type' => asset_type,
      'media_type' => media_type,
      
      # exhibit/collection support
      'scholar_exhibits' => scholar_exhibits,
      'special_collections' => special_collections,
      'special_collection_tabs' => special_collection_tabs,
      
      'playlist' => playlist,
      'playlist_order' => playlist_order
    }
  end

  private

  # These methods are only used by to_solr.

  def text
    @text ||= 'text' # TODO
#    ignores = [:text, :to_solr, :contribs, :img_src, :media_srcs, :captions_src,
#               :rights_code, :access_level, :access_types,
#               :organization_pbcore_name, # internal string; not in UI
#               :title, :ci_ids, :instantiations, 
#               :outside_url, :reference_urls, :exhibits]
#    @text ||= (PBCore.instance_methods(false) - ignores)
#              .reject { |method| method =~ /\?$/ } # skip booleans
#              .map { |method| send(method) } # method -> value
#              .select { |x| x } # skip nils
#              .flatten # flattens list accessors
#              .map { |x| x.respond_to?(:to_a) ? x.to_a : x } # get elements of compounds
#              .flatten.uniq
  end

end
