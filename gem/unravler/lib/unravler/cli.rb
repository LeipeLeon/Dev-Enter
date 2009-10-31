require 'optparse'

require 'extractor'

module Unravler

  APPNAME_FILE = ".unravler_appname"
  DEPS_FILE    = ".unravler"
  
  class CLI
    def self.execute(stdout, arguments=[])

      mandatory_options = %w(  )
      
      options = { :mode => :full }

      parser = OptionParser.new do |opts|
        opts.banner = <<-BANNER.gsub(/^          /,'')
          Unravler your Rails application dependencies...

          Usage:
            #{File.basename($0)} create yourappname # register your app name
            #{File.basename($0)} push               # push your app dependencies to unravler.com

          Options are:
        BANNER
        opts.separator ""
        opts.on("-p", "--print",
                "Print a la rake gems.") { options[:mode] = :print }
        opts.on("-d", "--dump",
                "Dump gem dependencies.") { options[:mode] = :dump }
        opts.on("-t", "--tree",
                "Pretty print the package tree.") { options[:mode] = :tree }
        opts.on("-h", "--help",
                "Show this help message.") { stdout.puts opts; exit }
        opts.parse!(arguments)

        if mandatory_options && \
          mandatory_options.find { |option| options[option.to_sym].nil? } \
          || (:full == options[:mode] && 0 == ARGV.size)
          stdout.puts opts; exit
        end

      end
      
      case options[:mode]
      when :print
        PrintExtractor.new.run
      when :dump
        DumpExtractor.new.run
      when :tree
        TreeExtractor.new.run

      when :full

        case arguments[0]
        when 'create'
          if 2 != ARGV.size
            stdout.puts opts; exit
          end
          appname = arguments[1]
          File.open(APPNAME_FILE, 'w') { |f| f.write appname }

        when 'push'
          appname = File.read(APPNAME_FILE).strip
          packages = \
            FullExtractor.new(options).run

          # write .unravler file ready for upload to webservice
          File.open(DEPS_FILE, 'w') { |f|
            f.write({
              :appname => appname,
              :packages => packages
            }.to_yaml)
          }
        
          puts "Pushed dependencies for #{appname} to unravler.com"
        end
      end

    end
  end
end