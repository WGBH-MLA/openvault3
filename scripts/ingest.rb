require_relative '../lib/rails_stub'
require_relative 'lib/pb_core_ingester'
require 'logger'
require 'rake'

class Exception
  def short
    message + "\n" + backtrace[0..2].join("\n")
  end
end

class ParamsError < StandardError
end

class Ingest
  def const_init(name)
    const_name = name.upcase.tr('-', '_')
    flag_name = "--#{name}"
    begin
      # to avoid "warning: already initialized constant" in tests.
      Ingest.const_get(const_name)
    rescue NameError
      Ingest.const_set(const_name, flag_name)
    end
  end

  def initialize(argv)
    orig = argv.clone

    %w(files dirs).each do |name|
      const_init(name)
    end

    %w(batch-commit same-mount stdout-log).each do |name|
      flag_name = const_init(name)
      variable_name = "@is_#{name.tr('-', '_')}"
      instance_variable_set(variable_name, argv.include?(flag_name))
      argv.delete(flag_name)
    end

    mode = argv.shift
    args = argv

    log_init(orig)
    $LOG.info("START: Process ##{Process.pid}: #{__FILE__} #{orig.join(' ')}")

    @flags = { is_same_mount: @is_same_mount, is_just_reindex: @is_just_reindex }

    begin
      case mode

      when DIRS
        fail ParamsError.new if args.empty? || args.map { |dir| !File.directory?(dir) }.any?
        target_dirs = args

      when FILES
        fail ParamsError.new if args.empty?
        @files = args

      else
        fail ParamsError.new
      end
    rescue ParamsError
      abort usage_message
    end

    @files ||= target_dirs.map do |target_dir|
      Dir.entries(target_dir)
      .reject { |file_name| ['.', '..'].include?(file_name) }
      .map { |file_name| "#{target_dir}/#{file_name}" }
    end.flatten.sort
  end

  def log_init(argv)
    sanitized_argv = argv.grep(/--/).map { |a| a.sub('--', '') }.join('-')
    log_file_name = if @is_stdout_log
                      $stdout
                    else
                      Rails.root + "log/ingest-#{sanitized_argv}.log"
    end
    $LOG = Logger.new(log_file_name, 'daily')
    $LOG.formatter = proc do |severity, datetime, _progname, msg|
      "#{severity} [#{datetime.strftime('%Y-%m-%d %H:%M:%S')}]: #{msg}\n"
    end
    puts "logging to #{log_file_name}"
  end

  def usage_message
    <<-EOF.gsub(/^ {4}/, '')
      USAGE: #{File.basename(__FILE__)}
               [#{BATCH_COMMIT}] [#{SAME_MOUNT}] [#{STDOUT_LOG}]
               #{FILES} FILE ...

      boolean flags:
        #{BATCH_COMMIT}: Optionally, make just one commit at the end, rather than
          one commit per file.
        #{SAME_MOUNT}: Optionally, allow same mount point for the script and the
          solr index. This is what you want in development, but the default, to
          disallow this, would have stopped me from running out of disk many times.
        #{STDOUT_LOG}: Optionally, log to stdout, rather than a log file.

      mutually exclusive modes:
        #{DIRS}: Clean and ingest the given files.
        #{FILES}: Clean and ingest the given files.
      EOF
  end

  def process
    ingester = PBCoreIngester.new(is_same_mount: @is_same_mount)

    @files.each do |path|
      begin
        success_count_before = ingester.success_count
        error_count_before = ingester.errors.values.flatten.count
        ingester.ingest(path: path, is_batch_commit: @is_batch_commit)
        success_count_after = ingester.success_count
        error_count_after = ingester.errors.values.flatten.count
        $LOG.info("Processed '#{path}' #{'but not committed' if @is_batch_commit}")
        $LOG.info("success: #{success_count_after - success_count_before}; " \
          "error: #{error_count_after - error_count_before}")
      end
    end

    if @is_batch_commit
      $LOG.info('Starting one big commit...')
      ingester.commit
      $LOG.info('Finished one big commit.')
    end

    # TODO: Investigate whether optimization is worth it. Requires a lot of disk and time.
    # puts 'Ingest complete; Begin optimization...'
    # ingester.optimize

    errors = ingester.errors.sort # So related errors are together
    error_count = errors.map { |pair| pair[1] }.flatten.count
    success_count = ingester.success_count
    total_count = error_count + success_count

    $LOG.info('SUMMARY: DETAIL')
    errors.each {|type, list|
      $LOG.warn("#{list.count} #{type} errors:\n#{list.join("\n")}")
    }

    $LOG.info('SUMMARY: STATS')
    $LOG.info('(Look just above for details on each error.)')
    errors.each {|type, list|
      $LOG.warn("#{list.count} (#{percent(list.count, total_count)}%) #{type}")
    }
    $LOG.info("#{success_count} (#{percent(success_count, total_count)}%) succeeded")

    $LOG.info('DONE')
  end

  def percent(part, whole)
    (100.0 * part / whole).round(1)
  end
end

Ingest.new(ARGV).process if __FILE__ == $PROGRAM_NAME
