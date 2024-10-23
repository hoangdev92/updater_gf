# frozen_string_literal: true

require 'fileutils'
module UpdaterGf
  # class HandleRubocop
  class HandleRubocop
    attr_reader :project_root

    def initialize(project_root)
      @project_root = project_root
    end

    def run
      unless project_root
        puts 'Project root is not specified'
        return
      end

      rubocop_yml_path = File.join(project_root, '.rubocop.yml')
      new_rubocop_yml_path = File.expand_path('.rubocop.yml', __dir__)

      unless File.exist?(rubocop_yml_path)
        FileUtils.touch(rubocop_yml_path)
        puts '.rubocop.yml not found, created a new one'
      end

      if File.exist?(new_rubocop_yml_path)
        FileUtils.cp(new_rubocop_yml_path, rubocop_yml_path)
        puts 'Updated .rubocop.yml'
      else
        puts 'Either .rubocop.yml does not exist'
      end
    end
  end
end
