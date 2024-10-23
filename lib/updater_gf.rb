# frozen_string_literal: true

require_relative "updater_gf/version"

module UpdaterGf
  class Error < StandardError; end

  class Updater
    class << self
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

      def update_gemfile
        gemfile_path = find_gemfile_path
        content = File.read(gemfile_path)

        # Replace all double quotes with single quotes
        updated_content = content.gsub(/"/, "'")

        final_content = update_final_content(updated_content)

        File.write(gemfile_path, final_content)
      end

      def update_final_content(updated_content)
        lines = updated_content.lines
        group_test_end_index = find_group_test_end_index(lines)
        return updated_content if group_test_end_index.nil?

        below_group_test_lines = lines[(group_test_end_index + 1)..]
        other_lines = get_other_lines(below_group_test_lines)
        sorted_gem_lines = sorted_gem_lines(below_group_test_lines)
        final_lines = lines[0..group_test_end_index] + other_lines + sorted_gem_lines

        # Add gems from list_gems_add if not already present
        final_lines += add_missing_gems(final_lines, list_gems_add)

        # Sort gem lines alphabetically after adding new gems, but only those after the group :test block
        final_lines = sort_gem_lines_after_test_block(final_lines, group_test_end_index)

        # Add gems from list_gems_add_develop to group :development if not already present
        final_lines = add_gems_to_development_group(final_lines, list_gems_add_develop)

        final_lines.join
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
        existing_gems = final_lines.select { |line| line.strip.start_with?("gem '") }.map { |line| line.match(/gem '([^']+)'/)[1] }
        missing_gems = gems_list - existing_gems
        missing_gems.map { |gem| "gem '#{gem}'\n" }
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
        existing_gems = development_group_lines.select { |line| line.strip.start_with?("gem '") }.map { |line| line.match(/gem '([^']+)'/)[1] }
        missing_gems = gems_list - existing_gems
        new_gem_lines = missing_gems.map { |gem| "  gem '#{gem}'\n" }

        final_lines[0..development_group_start_index] +
          development_group_lines +
          new_gem_lines +
          final_lines[development_group_end_index..]
      end

      def list_gems_add
        %w[ransack devise pagy pundit rack-cors redis sidekiq draper paranoia active_admin]
      end

      def list_gems_add_develop
        %w[pry letter_opener bullet better_errors binding_of_caller]
      end
    end
  end
end
