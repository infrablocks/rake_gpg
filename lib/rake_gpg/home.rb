# frozen_string_literal: true

module RakeGPG
  class Home
    def initialize(work_directory, home_directory)
      @work_directory = work_directory
      @home_directory = home_directory
    end

    def with_resolved_directory(&block)
      if @home_directory == :temporary
        Dir.mktmpdir('home', @work_directory, &block)
      else
        FileUtils.mkdir_p(@home_directory)
        yield @home_directory
      end
    end
  end
end
