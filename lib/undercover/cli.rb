# frozen_string_literal: true

require 'undercover'
require 'rainbow'

module Undercover
  module CLI
    # TODO: Report calls >parser< for each file instead of
    # traversing the whole project at first!

    WARNINGS_TO_S = {
      stale_coverage: Rainbow('🚨 WARNING: Coverage data is older than your ' \
        'latest changes and results might be incomplete. ' \
        'Re-run tests to update').yellow,
      no_changes: Rainbow('✅ No reportable changes').green
    }.freeze

    # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    def self.run(args)
      opts = build_opts(args)

      syntax_version(opts.syntax_version)
      report = Undercover::Report.new(changeset(opts), opts).build

      error = report.validate(opts.lcov)
      if error
        puts(WARNINGS_TO_S[error])
        return 0 if error == :no_changes
      end

      warnings = report.build_warnings
      puts Undercover::Formatter.new(warnings)
      warnings.any? ? 1 : 0
    end
    # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

    def self.build_opts(args)
      configuration = project_options.concat(args)
      Undercover::Options.new.parse(configuration)
    end

    def self.project_options
      args_from_options_file(project_options_file)
    end

    def self.args_from_options_file(path)
      return [] unless File.exist?(path)

      File.read(path).split('\n').flat_map { |line| line.split(' ') }
    end

    def self.project_options_file
      './.undercover'
    end

    def self.syntax_version(version)
      return unless version

      Imagen.parser_version = version
    end

    def self.changeset(opts)
      git_dir = File.join(opts.path, opts.git_dir)
      Undercover::Changeset.new(git_dir, opts.compare)
    end
  end
end
