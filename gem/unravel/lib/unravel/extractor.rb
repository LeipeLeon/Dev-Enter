
module Unravel
  
  class Extractor
    def initialize(options = {})
      @options = options
    end
  end
  
  class Dependency
    dep = {
      :frozen => true,
      :lib => 'capistrano',
      :name => 'capistrano-ext',
      :source => 'http://gems.github.com',
      :spec => {
        :name => 'capistrano-ext',
        :version => {
          :version => '1.0.0',
        },
        :platform => 'ruby',

        :dependencies => {
          :name => 'test',
          :version_requirement => {
            :conditions => ">=",
            :version => {
              :version => '1.0.0'
            }
          }
        },
        :description => '',
        :authors => [ 'Jamis Buck' ],
        :exectuables => [],
        :homepage => 'http://www.capify.org',
        :required_ruby_version => {
          :requirements => {
            :version => {
              :conditions => ">=",
              :version => {
                :version => '1.0.0'
              }
            }
          }
        },
        :rubyforge_project => 'capistrano-ext',
        :rubygems_version => '1.3.5',
        :summary => 'Useful task libraries and methods for Capistrano',
      },
      
    }
  end
  
  class GemExtractor< Extractor
    
    def run
      require File.join('config', 'environment')

      # do stuff
      gems = Rails.configuration.gems
      puts gems.to_yaml
      dependencies = gems.inject([]) do |memo, gem|
        memo << {
          :name        => gem.name,
          :source      => gem.source,
          :lib         => gem.lib,
          # :version     => gem.spec.version.version,
          # :platform    => gem.spec.platform,
          # :description => gem.spec.description,
          # :authors     => gem.spec.authors,
          # :homepage    => gem.spec.homepage,
          # :rubyforge_project => gem.spec.rubyforge_project,
          # :summary     => gem.spec.summary,
        }
      end
      puts dependencies.to_yaml
      # each do |gem|
      #   print_gem_status(gem)
      # end
      # puts
      # puts "I = Installed"
      # puts "F = Frozen"
      # puts "R = Framework (loaded before rails starts)"
    end
    
    private

    def print_gem_status(gem, indent=1)
      code = case
        when gem.framework_gem? then 'R'
        when gem.frozen?        then 'F'
        when gem.installed?     then 'I'
        else                         ' '
      end
      puts "   "*(indent-1)+" - [#{code}] #{gem.name} #{gem.requirement.to_s}"
      gem.dependencies.each { |g| print_gem_status(g, indent+1) }
    end
  end
  
  class DatabaseExtractor < Extractor
  end
  
  class PluginExtractor < Extractor
  end
  
  class ScmExtractor < Extractor
  end
  
  class RubyExtractor < Extractor
  end
  
end
