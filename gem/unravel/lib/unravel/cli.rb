require 'optparse'

require 'extractor'

module Unravel

  APPNAME_FILE = ".unravel_appname"
  DEPS_FILE    = ".unravel"
  
  class CLI
    def self.execute(stdout, arguments=[])

      # NOTE: the option -p/--path= is given as an example, and should be replaced in your application.

      options = {
        :path     => '~'
      }
      mandatory_options = %w(  )

      parser = OptionParser.new do |opts|
        opts.banner = <<-BANNER.gsub(/^          /,'')
          Unravel your Rails application dependencies...

          Usage:
            #{File.basename($0)} create yourappname # register your app name
            #{File.basename($0)} push               # push your app dependencies to unravel.com

          Options are:
        BANNER
        opts.separator ""
        # opts.on("-p", "--path=PATH", String,
        #         "This is a sample message.",
        #         "For multiple lines, add more strings.",
        #         "Default: ~") { |arg| options[:path] = arg }
        opts.on("-h", "--help",
                "Show this help message.") { stdout.puts opts; exit }
        opts.parse!(arguments)

        if mandatory_options && mandatory_options.find { |option| options[option.to_sym].nil? } || 0 == ARGV.size
          stdout.puts opts; exit
        end
        
        case arguments[0]

        when 'create'
          if 2 != ARGV.size
            stdout.puts opts; exit
          end
          appname = arguments[1]
          File.open(APPNAME_FILE, 'w') { |f| f.write appname }

        when 'push'
          appname = File.read(APPNAME_FILE).strip
          packages = GemExtractor.new(options).run
          packages += DatabaseExtractor.new(options).run
          packages += ScmExtractor.new(options).run
          packages += PluginExtractor.new(options).run

          # write .unravel file ready for upload to webservice
          File.open(DEPS_FILE, 'w') { |f|
            f.write "#{appname}\n"
            f.write packages.to_yaml
          }

        else
          stdout.puts opts; exit
        end
      end

    end
  end
end