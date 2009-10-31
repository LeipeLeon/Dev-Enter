
module Unravler
  
  class Extractor
    def initialize(options = {})
      @options = options
    end
  end
  
  class RailsExtractor < Extractor
    
    @@rails_loaded = false
    
    def initialize(options = {})
      @options = options
      load_rails
    end
    
    def run
      rails = Rails::GemDependency.new('rails', :version => Rails.version)
      [get_gem_attributes(rails)]
    end

    private
    
    def load_rails
      unless @@rails_loaded
        # load rails to get the gem dependencies
        require File.join('config', 'environment')
        @@rails_loaded = true
      end
    end
        
    #
    # recursively extract useful attributes from the gems
    #
    def get_gem_attributes(gem, level=1)
      spec = gem.specification
      @required_ruby_version = spec.required_ruby_version.to_s
      @rubygems_version = spec.rubygems_version.to_s

      dependencies = gem.specification.dependencies.reject do |dependency|
        dependency.type == :development
      end.map do |dependency|
        Rails::GemDependency.new(dependency.name, :requirement => dependency.version_requirements)
      end

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
          :dependencies => dependencies.map { |g| get_gem_attributes(g, level+1) },
        }
      }
    end

  end
  
  class DumpExtractor < RailsExtractor
    def run
      puts Rails.configuration.gems.to_yaml
    end
  end
  
  class PrintExtractor < RailsExtractor
    
    def run
      Rails.configuration.gems.each do |gem|
        print_gem_status(gem)
      end
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
  
  class GemExtractor< RailsExtractor
    
    @required_ruby_version = nil
    @rubygems_version = nil
    
    def run
      packages = Rails.configuration.gems.map do |gem|
        get_gem_attributes(gem)
      end

      ruby = if @required_ruby_version
        {
          :package => {
            :type              => 'binary', # possible values %w(gem binary plugin database scm)
            :name              => 'ruby',
            :version           => `ruby --version`.strip.chop,
            :description       => 'A dynamic, open source programming language with a focus on simplicity and productivity. It has an elegant syntax that is natural to read and easy to write.',
            :homepage          => 'http://www.ruby-lang.org/en/',
            :summary           => 'A programmers best friend.',
          }
        }
      end
      
      rubygems = if @rubygems_version
        {
          :package => {
            :type        => 'binary', # possible values %w(gem binary plugin database scm)
            :name        => 'rubygems',
            :version     => @rubygems_version,
            :description => 'RubyGems is the premier ruby packaging system.',
            :homepage    => 'http://docs.rubygems.org/',
            :summary     => 'RubyGems is the name of the project that developed the gem packaging system and the gem command. You can get RubyGems from the RubyForge repository.',
          }
        }
      end
      
      packages + [ruby] + [rubygems]
    end
  end
  
  class DatabaseExtractor < Extractor
    def run
      case ActiveRecord::Base.connection.class.to_s
      when 'ActiveRecord::ConnectionAdapters::SQLite3Adapter'
        database_package = {
          :package => {
            :type              => 'database', # possible values %w(gem binary plugin database scm)
            :name              => 'SQLite',
            :version           => `sqlite3 --version`.strip.chop,
            :description       => 'SQLite is a software library that implements a self-contained, serverless, zero-configuration, transactional SQL database engine. SQLite is the most widely deployed SQL database engine in the world. The source code for SQLite is in the public domain.',
            :homepage          => 'http://www.sqlite.org/',
            :summary           => 'Small. Fast. Reliable. Choose any three.',
          }
        }
      when 'ActiveRecord::ConnectionAdapters::MysqlAdapter'
        database_package = {
          :package => {
            :type              => 'database', # possible values %w(gem binary plugin database scm)
            :name              => 'MySQL',
            :version           => `mysql --version`.strip.chop,
            :description       => 'MySQL is a relational database management system (RDBMS) which has more than 6 million installations.',
            :homepage          => 'http://www.mysql.com/',
            :summary           => 'The world\'s most popular open source database.',
          }
        }
      end
      
      [database_package]
    end
  end
  
  class PluginExtractor < Extractor
    def run
      # list directories in vendor/plugins
      Dir.entries(File.join('vendor', 'plugins'))[2..-1].map do |plugin_name|
        {
          :package => {
            :type => 'plugin', # possible values %w(gem binary plugin database scm)
            :name => plugin_name,
          }
        }
      end
    end
  end
  
  class ScmExtractor < Extractor
    def run
      if File.directory?('.git')
        scm_package = {
          :package => {
            :type              => 'scm', # possible values %w(gem binary plugin database scm)
            :name              => 'Git',
            :version           => `git --version`.strip.chop,
            :description       => 'Git is a free & open source, distributed version control system designed to handle everything from small to very large projects with speed and efficiency.',
            :homepage          => 'http://git-scm.com/',
            :summary           => 'Git - Fast Version Control System.',
          }
        }
      elsif File.diretory?('.svn')
        scm_package = {
          :package => {
            :type              => 'svn', # possible values %w(gem binary plugin database scm)
            :name              => 'Subversion',
            :version           => `svn --version`.strip.chop,
            :description       => 'Subversion was originally designed to be a better CVS, so it has most of CVS\'s features. Generally, Subversion\'s interface to a particular feature is similar to CVS\'s, except where there\'s a compelling reason to do otherwise.',
            :homepage          => 'http://subversion.tigris.org/',
            :summary           => 'Subversion is an open source version control system.',
          }
        }
      else
        scm_package = nil
      end
      
      [scm_package]
    end
  end
  
  class RubyExtractor < Extractor
    def run
      # always dependent on ruby
      []
    end
  end
  
  class FullExtractor < Extractor
    def run
      RailsExtractor.new(@options).run +
      GemExtractor.new(@options).run +
      DatabaseExtractor.new(@options).run +
      ScmExtractor.new(@options).run +
      PluginExtractor.new(@options).run +
      RubyExtractor.new(@options).run
    end
  end
  
  class TreeExtractor < Extractor
    def run
      FullExtractor.new.run.each do |package|
        print_package(package)
      end
    end
    
    # pretty print the package dependency tree
    def print_package(package, indent=1)
      puts "   "*(indent-1)+" - [#{package[:package][:type]}] #{package[:package][:name]} #{package[:package][:version]}"
      if package[:package][:dependencies]
        package[:package][:dependencies].each { |p|
          print_package(p, indent+1)
        }
      end
    end
  end
  
end
