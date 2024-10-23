# frozen_string_literal: true

require_relative 'constants'
require_relative 'handle_rubocop'

module UpdaterGf
  # HandleUpdate class
  class HandleUpdate
    attr_reader :is_add_gem, :is_add_robocop

    def initialize(is_add_gem, is_add_robocop)
      @is_add_gem = is_add_gem
      @is_add_robocop = is_add_robocop
    end

    def process
      gemfile_path = find_gemfile_path
      content = File.read(gemfile_path)

      # Replace all double quotes with single quotes
      updated_content = content.gsub(/"/, "'")
      updated_content = update_final_content(updated_content) if is_add_gem
      File.write(gemfile_path, updated_content)
      HandleRubocop.new(find_project_root).run if is_add_robocop
    end

    private

    def update_final_content(updated_content)
      lines = updated_content.lines
      group_test_end_index = find_group_test_end_index(lines)
      return updated_content if group_test_end_index.nil?

      below_group_test_lines = lines[(group_test_end_index + 1)..]
      other_lines = get_other_lines(below_group_test_lines)
      sorted_gem_lines = sorted_gem_lines(below_group_test_lines)
      final_lines = lines[0..group_test_end_index] + other_lines + sorted_gem_lines

      # Add gems from list_gems_add if not already present
      final_lines += add_missing_gems(final_lines, Constants::LIST_GEMS_ADD)

      # Sort gem lines alphabetically after adding new gems, but only those after the group :test block
      final_lines = sort_gem_lines_after_test_block(final_lines, group_test_end_index)

      # Add gems from list_gems_add_develop to group :development if not already present
      final_lines = add_gems_to_development_group(final_lines, Constants::LIST_GEMS_ADD_DEVELOP)

      final_lines.join
    end

    def find_gemfile_path
      current_dir = Dir.pwd

      until File.exist?(File.join(current_dir, 'Gemfile'))
        parent_dir = File.expand_path('..', current_dir)
        break if current_dir == parent_dir # Reached the root directory

        current_dir = parent_dir
      end

      gemfile_path = File.join(current_dir, 'Gemfile')
      raise Error, 'Gemfile not found' unless File.exist?(gemfile_path)

      gemfile_path
    end

    def find_project_root
      current_dir = Dir.pwd
      until File.exist?(File.join(current_dir, 'Gemfile'))
        parent_dir = File.expand_path('..', current_dir)
        return nil if current_dir == parent_dir # Reached the root directory

        current_dir = parent_dir
      end
      current_dir
    end

    def find_group_test_end_index(lines)
      group_test_start_index = lines.index { |line| line.strip == 'group :test do' }
      return nil if group_test_start_index.nil?

      group_test_end_index = lines[group_test_start_index..].index { |line| line.strip == 'end' }
      return nil if group_test_end_index.nil?

      group_test_start_index + group_test_end_index
    end

    def sorted_gem_lines(below_group_test_lines)
      get_gem_lines(below_group_test_lines).sort_by { |line| line.match(/gem '([^']+)'/)[1] }
    end

    def get_gem_lines(below_group_test_lines)
      below_group_test_lines.select { |line| line.strip.start_with?("gem '") && !line.strip.start_with?('#') }
    end

    def get_other_lines(below_group_test_lines)
      below_group_test_lines.reject { |line| line.strip.start_with?("gem '") && !line.strip.start_with?('#') }
    end

    def add_missing_gems(final_lines, gems_list)
      existing_gems = final_lines.select { |line| line.strip.start_with?("gem '") }.map do |line|
        match = line.match(/gem '([^']+)'/)
        match[1]
      end
      missing_gems = gems_list.reject do |gem|
        existing_gems.include?(gem[:name])
      end
      missing_gems.map do |gem|
        version_string = gem[:version] ? ", '#{gem[:version]}'" : ''
        condition_string = gem[:condition] ? ", '#{gem[:condition]}'" : ''
        "gem '#{gem[:name]}'#{version_string}#{condition_string}\n"
      end
    end

    def sort_gem_lines_after_test_block(final_lines, group_test_end_index)
      lines_after_test_block = final_lines[(group_test_end_index + 1)..]
      gem_lines = lines_after_test_block.select { |line| line.strip.start_with?("gem '") }
      other_lines = lines_after_test_block.reject { |line| line.strip.start_with?("gem '") }
      sorted_gem_lines = gem_lines.sort_by { |line| line.match(/gem '([^']+)'/)[1] }
      final_lines[0..group_test_end_index] + other_lines + sorted_gem_lines
    end

    def add_gems_to_development_group(final_lines, gems_list)
      development_group_start_index = final_lines.index { |line| line.strip == 'group :development do' }
      return final_lines if development_group_start_index.nil?

      development_group_end_index = final_lines[development_group_start_index..].index { |line| line.strip == 'end' }
      return final_lines if development_group_end_index.nil?

      development_group_end_index += development_group_start_index

      development_group_lines = final_lines[(development_group_start_index + 1)...development_group_end_index]
      existing_gems = development_group_lines.select { |line| line.strip.start_with?("gem '") }.map do |line|
        match = line.match(/gem '([^']+)'/)
        match[1]
      end

      missing_gems = gems_list.reject do |gem|
        existing_gems.include?(gem[:name])
      end
      new_gem_lines = missing_gems.map do |gem|
        version_string = gem[:version] ? ", '#{gem[:version]}'" : ''
        condition_string = gem[:condition] ? ", '#{gem[:condition]}'" : ''
        "  gem '#{gem[:name]}'#{version_string}#{condition_string}\n"
      end

      final_lines[0..development_group_start_index] +
        development_group_lines +
        new_gem_lines +
        final_lines[development_group_end_index..]
    end
  end
end
