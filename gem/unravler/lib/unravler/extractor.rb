
module Unravler
  
  class Extractor
    def initialize(options = {})
      @options = options
    end
  end

  # # useful attributes from Gem::Dependency tree
  # dep = {
  #   :frozen => true,
  #   :lib => 'capistrano',
  #   :name => 'capistrano-ext',
  #   :source => 'http://gems.github.com',
  #   :spec => {
  #     :name => 'capistrano-ext',
  #     :version => {
  #       :version => '1.0.0',
  #     },
  #     :platform => 'ruby',
  # 
  #     :dependencies => {
  #       :name => 'test',
  #       :version_requirement => {
  #         :conditions => ">=",
  #         :version => {
  #           :version => '1.0.0'
  #         }
  #       }
  #     },
  #     :description => '',
  #     :authors => [ 'Jamis Buck' ],
  #     :exectuables => [],
  #     :homepage => 'http://www.capify.org',
  #     :required_ruby_version => {
  #       :requirements => {
  #         :version => {
  #           :conditions => ">=",
  #           :version => {
  #             :version => '1.0.0'
  #           }
  #         }
  #       }
  #     },
  #     :rubyforge_project => 'capistrano-ext',
  #     :rubygems_version => '1.3.5',
  #     :summary => 'Useful task libraries and methods for Capistrano',
  #   },
  # }
  
  class GemExtractor< Extractor
    
    def run
      # load rails to get the gem dependencies
      require File.join('config', 'environment')

      # gems = Rails.configuration.gems
      # puts gems.to_yaml

      packages = Rails.configuration.gems.map do |gem|
        unravler(gem)
      end

      packages
    end
    
    private
    
    #
    # recursively extract useful attributes from the gems
    #
    def unravler(gem, level=1)
      spec = gem.specification
      {
        :package => {
          :type              => 'gem', # possible values %w(gem binary plugin database scm)
          :name              => gem.name,
          :source            => gem.source,
          :lib               => gem.lib,
          :version           => spec.version.to_s,
          :platform          => spec.platform,
          :description       => spec.description,
          :authors           => spec.authors,
          :homepage          => spec.homepage,
          :rubyforge_project => spec.rubyforge_project,
          :summary           => spec.summary,
          :required_ruby_version => spec.required_ruby_version.to_s,
          :dependencies => gem.dependencies.map { |g| unravler(g, level+1) },
        }
      }
    end

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
    def run
      []
    end
  end
  
  class PluginExtractor < Extractor
    def run
      []
    end
  end
  
  class ScmExtractor < Extractor
    def run
      []
    end
  end
  
  class RubyExtractor < Extractor
  end
  
end
