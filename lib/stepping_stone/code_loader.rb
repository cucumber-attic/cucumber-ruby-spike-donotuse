# This is borrowed from rspec-core (renamed from RbProject
# and slightly modified), which in turn was borrowed (slightly
# modified) from Scott Taylor's project_path project:
#   http://github.com/smtlaissezfaire/project_path

require 'pathname'

module SteppingStone
  # One of the services Cucumber provides to the servers and reporters.
  # CodeLoader is responsible for loading code from Cucumber's file
  # system location (e.g. the cukes directory or similar)
  module CodeLoader
    def require_glob(dir, pattern)
      Dir[File.join(root, project_dir, dir, pattern)].each do |file|
        require File.join(dir, File.basename(file, '.rb'))
      end
    end

    def add_to_load_path(*dirs)
      dirs.map {|dir| add_dir_to_load_path(File.join(root, dir))}
    end

    def add_dir_to_load_path(dir) # :nodoc:
      $LOAD_PATH.unshift(dir) unless $LOAD_PATH.include?(dir)
    end

    def root # :nodoc:
      @project_root ||= determine_root
    end

    def project_dir # :nodoc:
      @project_dir ||= 'sst'
    end

    def determine_root # :nodoc:
      find_first_parent_containing(project_dir) || '.'
    end

    def find_first_parent_containing(dir) # :nodoc:
      ascend_until {|path| File.exists?(File.join(path, dir))}
    end

    def ascend_until # :nodoc:
      Pathname(File.expand_path('.')).ascend do |path|
        return path if yield(path)
      end
    end

    module_function :require_glob
    module_function :add_to_load_path
    module_function :add_dir_to_load_path
    module_function :root
    module_function :project_dir
    module_function :determine_root
    module_function :find_first_parent_containing
    module_function :ascend_until
  end
end
