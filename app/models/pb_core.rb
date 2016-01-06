require 'rexml/document'
require 'rexml/xpath'
require 'solrizer'
require_relative '../../lib/html_scrubber'
require_relative '../../lib/open_vault'
require_relative 'xml_backed'
require_relative 'pb_core_instantiation'
require_relative 'pb_core_name_role_affiliation'
require_relative '../../lib/formatter'

class PBCore # rubocop:disable Metrics/ClassLength
  # rubocop:disable Style/EmptyLineBetweenDefs
  include XmlBacked
  
  def series_title
    @series_title ||= 'series_title' # TODO
  end
  def program_title
    @program_title ||= 'program_title' # TODO
  end
  def item_title
    @item_title ||= 'item_title' # TODO ("Open Vault Title"?)
  end
  def title
    @title ||= 'title' # TODO
  end
  def episode_title
    @episode_title ||= 'episode_title' # TODO
  end
  def episode_number
    @episode_number ||= 'episode_number' # TODO
  end
  def series_description
    @series_description ||= 'series_description' # TODO
  end
  def series_date
    @series_date ||= 'series_date' # TODO
  end
  def program_description
    @program_description ||= 'program_description' # TODO
  end
  def creators
    @creators ||= [] # TODO
  end
  def contributors
    @contributors ||= [] # TODO
  end
  def publishers
    @publishers ||= [] # TODO
  end
  def subjects
    @subject ||= ['subject'] # TODO
  end
  def locations
    @location ||= ['location'] # TODO
  end
  def genres
    @genre ||= ['genre'] # TODO
  end
  def topics
    @topic ||= ['topic'] # TODO
  end
  def rights_holder
    @rights_holder ||= 'rights_holder' # TODO
  end
  def rights_credit
    @rights_credit ||= 'rights_credit' # TODO
  end
  
  def id
    @id ||= 'id' # TODO
  end
  def img_src
    @img_src ||= 'img_src' # TODO
#      case media_type
#      when MOVING_IMAGE
#        "#{OpenVault::S3_BASE}/thumbnail/TODO"
#      when SOUND
#        '/thumbs/audio-digitized.jpg'
#      when OTHER
#        '/thumbs/other.jpg'
#      end
  end
  MOVING_IMAGE = 'Moving Image'
  SOUND = 'Sound'
  OTHER = 'other'
  def media_type
    @media_type ||= 'media_type' # TODO
  end
#  def video?
#    media_type == MOVING_IMAGE
#  end
#  def audio?
#    media_type == SOUND
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
      'id' => id,
      'xml' => '<xml/>', # TODO; Formatter.instance.format(doc_with_caption_flag),

      # constrained searches:
      'text' => text, # TODO + [caption_body].select { |optional| optional },

      # facets:
      'asset_type' => asset_type,
      'media_type' => media_type,
      'genres' => genres,
      'topics' => topics
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
