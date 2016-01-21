require 'rexml/document'
require 'rexml/xpath'
require 'solrizer'
require_relative '../../lib/open_vault'
require_relative 'xml_backed'
require_relative 'pb_core_name_role'
require_relative '../../lib/formatter'

class PBCore # rubocop:disable Metrics/ClassLength
  # rubocop:disable Style/EmptyLineBetweenDefs
  include XmlBacked
  
  def id
    @id ||= xpath('/*/pbcoreIdentifier[@source="Open Vault UID"]')
  end
  
  def series_title
    @series_title ||= xpath_optional('/*/pbcoreTitle[@titleType="Series"]')
  end
  def program_title
    @program_title ||= xpath_optional('/*/pbcoreTitle[@titleType="Program"]')
  end
  def program_number
    @program_number ||= xpath_optional('/*/pbcoreTitle[@titleType="Program Number"]')
  end
  def asset_title
    @asset_title ||= xpath_optional('/*/pbcoreTitle[@titleType="Open Vault Title"]')
  end
  
  def date
    @date ||= xpath_optional('/*/pbcoreAssetDate[@dateType="Item Date"]')
  end
  def year
    @year ||= if date
      date.match(/(\d{4})/)[1]
    end
  end
  
  def title
    @title ||= [series_title, program_title, asset_title].select{|x| x}.join('; ')
  end
  
  def duration
    @duration ||= begin
      full = xpath_optional('/*/pbcoreAnnotation[@annotationType="Duration"]')
      full.gsub(/(\d\d:\d\d:\d\d):\d\d/, '\1') if full
    end
  end
  def asset_type
    @asset_type ||= xpath('/*/pbcoreAssetType')
  end
  def series_description
    @series_description ||= xpath_optional('/*/pbcoreDescription[@descriptionType="Series Description"]')
  end
  def program_description
    @program_description ||= xpath_optional('/*/pbcoreDescription[@descriptionType="Program Description"]')
  end
  def asset_description
    @asset_description ||= xpath_optional('/*/pbcoreDescription[@descriptionType="Asset Description"]')
  end
  def contributors
    @contributors ||= REXML::XPath.match(@doc, '/*/pbcoreContributor').map do|rexml|
      PBCoreNameRole.new(rexml)
    end
  end
  def creators
    @creators ||= REXML::XPath.match(@doc, '/*/pbcoreCreator').map do|rexml|
      PBCoreNameRole.new(rexml)
    end
  end
  def publishers
    @publishers ||= xpaths('/*/pbcorePublisher/publisher')
  end
  def subjects
    @subjects ||= xpaths('/*/pbcoreSubject')
  end
  def locations
    @locations ||= xpaths('/*/pbcoreCoverage[coverageType="Spatial"]/coverage')
  end
  def genres
    @genre ||= xpaths('/*/pbcoreGenre[@source="Series Genre"]')
  end
  def topics
    @topic ||= xpaths('/*/pbcoreGenre[@source="Series Topic"]')
  end
  
  def rights_summary
    @rights_summary ||= xpath_optional('/*/pbcoreRightsSummary/rightsSummary')
  end
  
  VIDEO = 'Video'
  AUDIO = 'Audio'
  IMAGE = 'Image'
  def media_type
    @media_type ||= xpath('/*/pbcoreAnnotation[@annotationType="Media Type"]')
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
  def extensions
    case media_type
    when VIDEO
      ['mp4', 'webm']
    when AUDIO
      ['mp3']
    when IMAGE
      ['jpg']
    else 
      fail("Unrecognized media_type: #{media_type}")
    end
  end
  
  URL_BASE = 'https://s3.amazonaws.com/openvault.wgbh.org/catalog'
  def thumbnail_src
    @thumb_src ||= begin
      if xpath_boolean('/*/pbcoreAnnotation[@annotationType="Thumbnail"]')
        "#{URL_BASE}/asset_thumbnails/#{id}.jpg"
      else 
        case media_type
        when VIDEO
          '/images/video_icon.png'
        when AUDIO
          '/images/audio_icon.png'
        when IMAGE
          '/images/image_icon.png'
        else
          fail("Unrecognized media_type: #{media_type}")
        end
      end
    end
    # TODO: some have defaults?
  end
  def proxy_srcs
    @proxy_srcs ||= 
      if xpath_boolean('/*/pbcoreAnnotation[@annotationType="Digitized"]')
        extensions.map { |ext| "#{URL_BASE}/asset_proxies/#{id}.#{ext}" }
      else
        []
      end
  end
  
  def transcript_srcs
    @transcript_srcs ||= 
      if xpath_boolean('/*/pbcoreAnnotation[@annotationType="Transcript"]')
        ["#{URL_BASE}/asset_transcripts/#{id}.xml"]
      else
        []
      end
  end

  def blocked_country_codes
    xpaths('/*/pbcoreAnnotation[@annotationType="Geoblock"]')
  end
  
  def password_required?
    xpath_boolean('/*/pbcoreAnnotation[@annotationType="Password"]')
  end
  
  AAPB_RE = /^http:\/\/americanarchive.org\//
  NEWS_RE = /^http:\/\/bostonlocaltv.org\//
  def outside_url
    @outside_url ||=
      xpath_optional('/*/pbcoreAnnotation[@annotationType="Outside URL"]').tap do |url|
        if url && !url.match(AAPB_RE) && !url.match(NEWS_RE)
          fail("'#{url}' matches neither #{AAPB_RE} nor #{NEWS_RE}")
        end
      end
  end
  def aapb_url
    @aapb_url ||= begin
      outside_url if outside_url && outside_url.match(AAPB_RE)
    end
  end
  def boston_tv_news_url
    @boston_tv_news_url ||= begin
      outside_url if outside_url && outside_url.match(NEWS_RE)
    end 
  end

  def special_collections
    @special_collections ||= xpaths('/*/pbcoreAnnotation[@annotationType="Special Collection"]')
  end  
  def special_collection_tags
    @special_collection_tags ||= xpaths('/*/pbcoreAnnotation[@annotationType="Special Collection Tag"]')
  end
  def scholar_exhibits
    @scholar_exhibits ||= xpaths('/*/pbcoreAnnotation[@annotationType="Scholar Exhibit"]')
  end
  
#  def playlist
#    # TODO
#  end
#  def playlist_order
#    # TODO
#  end
#  def playlist_next_id
#    # TODO
#  end
#  def playlist_prev_id
#    # TODO
#  end
  
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
      id: id,
      xml: @xml,

      # indexed:
      text: text, # TODO + [caption_body].select { |optional| optional },

      # *************************************
      #     Keep in sync with schema.xml
      # *************************************
      
      title: title,
      thumbnail_src: thumbnail_src,
      
      year: year,
      
      # links from details and series pages:
      series_title: series_title,
      program_title: program_title,
      
      subjects: subjects,
      locations: locations,
      
      # UI facets
      genres: genres,
      topics: topics,
      
      asset_type: asset_type,
      media_type: media_type,
      
      # exhibit/collection support
      scholar_exhibits: scholar_exhibits,
      special_collections: special_collections,
      special_collection_tags: special_collection_tags,
      
#      playlist: playlist,
#      playlist_order: playlist_order
    }
  end

  private

  # These methods are only used by to_solr.

  def text
    @text = begin
      ignores = [
        :text, :to_solr, :id, :duration, 
        :media_type, :asset_type, 
        :extensions, :blocked_country_codes,
        :scholar_exhibits, :special_collections, :special_collection_tags
      ]
      (PBCore.instance_methods(false) - ignores)
              .reject { |method| method =~ /(\?|srcs?|url)$/ } # skip booleans, urls
              .map { |method| send(method) } # method -> value
              .select { |x| x } # skip nils
              .flatten # flattens list accessors
              .map { |x| x.respond_to?(:to_a) ? x.to_a : x } # get elements of compounds
              .flatten.uniq
    end
  end

end
