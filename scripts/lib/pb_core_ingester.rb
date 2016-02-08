require 'rsolr'
require 'date' # NameError deep in Solrizer without this.
require 'logger'
require 'zip'
require_relative '../../app/models/validated_pb_core'
require_relative 'null_logger'
require_relative 'mount_validator'
require_relative '../../lib/solr'

class PBCoreIngester
  attr_reader :errors
  attr_reader :success_count

  def initialize(opts)
    # TODO: hostname and corename from config?
    @solr = Solr.instance.connect
    @solr.get('../admin/cores')['status']['blacklight-core']['dataDir'].tap do|data_dir|
      MountValidator.validate_mount("#{data_dir}index", 'solr index') unless opts[:is_same_mount]
    end
    $LOG ||= NullLogger.new
    @errors = Hash.new([])
    @success_count = 0

    @re = Regexp.new(opts[:regex] || '') # Empty RE will match anything.
  end

  def self.load_fixtures
    # This is a test in its own right elsewhere.
    ingester = PBCoreIngester.new(is_same_mount: true)
    ingester.delete_all
    Dir['spec/fixtures/pbcore/*.xml'].each do |pbcore|
      ingester.ingest(path: pbcore)
    end
  end

  def delete_all
    @solr.delete_by_query('*:*')
    commit
  end

  def ingest(opts)
    path = opts[:path]
    is_batch_commit = opts[:is_batch_commit]

    begin
      Zip::File.open(path) do |zip_file|
        zip_file.each do |entry|
          begin
            ingest_xml_no_commit(entry.get_input_stream.read)
            commit unless is_batch_commit
            @success_count += 1
          rescue => e
            record_error(e, "#{path} :: #{entry.name}")
          end
        end
      end
    rescue Zip::Error
      begin
        ingest_xml_no_commit(File.read(path))
        @success_count += 1
      rescue => e
        record_error(e, path)
      end
    end

    commit unless is_batch_commit
  end

  def record_error(e, path, id_extracts = '')
    message = "#{path} #{id_extracts}: #{e.message}"
    $LOG.warn(message)
    @errors["#{e.class}: #{e.message.split(/\n/).first}"] += [message]
  end

  def commit
    @solr.commit
  end

  def ingest_xml_no_commit(xml)
    begin
      pbcore = ValidatedPBCore.new(xml)
    rescue => e
      raise ValidationError.new(e)
    end

    if @re.match(xml)
      begin
        @solr.add(pbcore.to_solr)
      rescue => e
        raise SolrError.new(e)
      end
      $LOG.info("Updated solr record #{pbcore.id}")
    else
      $LOG.info("Skip solr record #{pbcore.id}: does not match #{@re}")
    end

    pbcore
  end

  class ChainedError < StandardError
    # Sorry, this is more java-ish than ruby-ish,
    # but downstream I want to distinguish different
    # error types, AND I want to know the root cause.
    # This makes that possible.
    def initialize(e)
      @base_error = e
    end

    def message
      if @base_error.respond_to?(:message)
        @base_error.message + "\n" + @base_error.backtrace[0..2].join("\n") + "\n..."
      else
        @base_error
      end
    end
  end
  class ValidationError < ChainedError
  end
  class SolrError < ChainedError
  end
end
