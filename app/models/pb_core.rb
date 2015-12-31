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
  def descriptions
    @descriptions ||= xpaths('/*/pbcoreDescription').map { |description| HtmlScrubber.scrub(description) }
  end
  def genres
    @genres ||= xpaths('/*/pbcoreGenre[@annotation="genre"]')
  end
  def topics
    @topics ||= xpaths('/*/pbcoreGenre[@annotation="topic"]')
  end
  def subjects
    @subjects ||= xpaths('/*/pbcoreSubject')
  end
  def contributors
    @contributors ||= REXML::XPath.match(@doc, '/*/pbcoreContributor').map do|rexml|
      PBCoreNameRoleAffiliation.new(rexml)
    end
  end
  def creators
    @creators ||= REXML::XPath.match(@doc, '/*/pbcoreCreator').map do|rexml|
      PBCoreNameRoleAffiliation.new(rexml)
    end
  end
  def publishers
    @publishers ||= REXML::XPath.match(@doc, '/*/pbcorePublisher').map do|rexml|
      PBCoreNameRoleAffiliation.new(rexml)
    end
  end
  def instantiations
    @instantiations ||= REXML::XPath.match(@doc, '/*/pbcoreInstantiation').map do|rexml|
      PBCoreInstantiation.new(rexml)
    end
  end
  def rights_summary
    @rights_summary ||= xpath('/*/pbcoreRightsSummary/rightsSummary')
  rescue NoMatchError
    nil
  end
  def asset_type
    @asset_type ||= xpath('/*/pbcoreAssetType')
  rescue NoMatchError
    nil
  end
  def asset_dates
    @asset_dates ||= pairs_by_type('/*/pbcoreAssetDate', '@dateType')
  end
  def asset_date
    @asset_date ||= xpath('/*/pbcoreAssetDate[1]')
  rescue NoMatchError
    nil
  end
  def titles
    @titles ||= pairs_by_type('/*/pbcoreTitle', '@titleType')
  end
  def title
    @title ||= titles.map { |pair| pair.last }.join('; ')
  end
  def id
    @id ||= xpath('/*/pbcoreIdentifier[1]').gsub("cpb-aacip/", 'cpb-aacip_')
  end
  CAPTIONS_ANNOTATION = 'Captions URL'
  def captions_src
    @captions_src ||= xpath("/*/pbcoreAnnotation[@annotationType='#{CAPTIONS_ANNOTATION}']")
  rescue NoMatchError
    nil
  end
  def img_src
    @img_src ||=
      case media_type
      when MOVING_IMAGE
        "#{OpenVault::S3_BASE}/thumbnail/TODO"
      when SOUND
        '/thumbs/audio-digitized.jpg'
      when OTHER
        '/thumbs/other.jpg'
      end
  end
  MOVING_IMAGE = 'Moving Image'
  SOUND = 'Sound'
  OTHER = 'other'
  def media_type
    @media_type ||= begin
      media_types = xpaths('/*/pbcoreInstantiation/instantiationMediaType')
      [MOVING_IMAGE, SOUND, OTHER].each do|type|
        return type if media_types.include? type
      end
      return OTHER if media_types == [] # pbcoreInstantiation is not required, so this is possible
      fail "Unexpected media types: #{media_types.uniq}"
    end
  end
  def video?
    media_type == MOVING_IMAGE
  end
  def audio?
    media_type == SOUND
  end
  def duration
    @duration ||= begin
      xpath('/*/pbcoreInstantiation/instantiationGenerations[text()="Proxy"]/../instantiationDuration')
    rescue
      xpaths('/*/pbcoreInstantiation/instantiationDuration').first
    end
  end

  # rubocop:enable Style/EmptyLineBetweenDefs

  def to_solr
    # Only just before indexing do we check for the existence of captions:
    # We don't want to ping S3 multiple times, and we don't want to store all
    # of a captions/transcript file in solr (much less in the pbcore).
    # --> We only want to say that it exists, and we want to index the words.
    
    doc_with_caption_flag = @doc.deep_clone
    # perhaps paranoid, but I don't want this method to have side effects.
    
    caption_id = id.gsub('_','-')
    caption_base = 'https://s3.amazonaws.com/americanarchive.org/captions'
    caption_url = "#{caption_base}/#{caption_id}/#{caption_id}.srt1.srt"
    caption_response = Net::HTTP.get_response(URI.parse(caption_url))
    if caption_response.code == '200'
      pre_existing = REXML::XPath.match(doc_with_caption_flag, "//pbcoreAnnotation[@annotationType='#{CAPTIONS_ANNOTATION}']").first
      if pre_existing
        pre_existing.parent.elements.delete(pre_existing)
      end
      caption_body = caption_response.body.gsub(/[^[:print:][\n]&&[^ ]]+/, ' ')
      # "\n" is not in the [:print:] class, but it should be preserved.
      # "&&" is intersection: we also want to match " ", 
      # so that control-chars + spaces collapse to a single space.
      REXML::XPath.match(doc_with_caption_flag, '/*/pbcoreInstantiation').last.next_sibling.next_sibling = 
        REXML::Element.new('pbcoreAnnotation').tap do |el|
          el.add_attribute('annotationType', CAPTIONS_ANNOTATION)
          el.add_text(caption_url)
        end
    end
    
    {
      'id' => id,
      'xml' => Formatter.instance.format(doc_with_caption_flag),

      # constrained searches:
      'text' => text + [caption_body].select { |optional| optional },
      # Unused at the moment, but let's continue to index so it could be re-enabled.
      'titles' => titles.map { |pair| pair.last },
      'contribs' => contribs,

      # sort:
      'title' => title,

      # sort and facet:
      'year' => year,

      # facets:
      'media_type' => media_type == OTHER ? nil : media_type,
      'genres' => genres,
      'topics' => topics,
      'asset_type' => asset_type
    }.merge(
      Hash[
        titles.group_by { |pair| pair[0] }.map do|key, pairs|
          ["#{key.downcase.tr(' ', '_')}_titles", pairs.map { |pair| pair[1] }]
        end
      ]
    )
  end

  private

  # These methods are only used by to_solr.

  def text
    ignores = [:text, :to_solr, :contribs, :img_src, :media_srcs, :captions_src,
               :rights_code, :access_level, :access_types,
               :organization_pbcore_name, # internal string; not in UI
               :title, :ci_ids, :instantiations, 
               :outside_url, :reference_urls, :exhibits]
    @text ||= (PBCore.instance_methods(false) - ignores)
              .reject { |method| method =~ /\?$/ } # skip booleans
              .map { |method| send(method) } # method -> value
              .select { |x| x } # skip nils
              .flatten # flattens list accessors
              .map { |x| x.respond_to?(:to_a) ? x.to_a : x } # get elements of compounds
              .flatten.uniq
  end

  def contribs
    @contribs ||=
      # TODO: Cleaner xpath syntax?
      xpaths('/*/pbcoreCreator/creator') +
      xpaths('/*/pbcoreCreator/creator/@affiliation') +
      xpaths('/*/pbcoreContributor/contributor') +
      xpaths('/*/pbcoreContributor/contributor/@affiliation') +
      xpaths('/*/pbcorePublisher/publisher') +
      xpaths('/*/pbcorePublisher/publisher/@affiliation')
  end

  def year
    @year ||= asset_date ? asset_date.gsub(/-\d\d-\d\d/, '') : nil
  end
end
