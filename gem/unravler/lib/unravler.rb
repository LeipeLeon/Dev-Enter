$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

$:.unshift(File.join(File.dirname(__FILE__), 'unravler'))

module Unravler
  VERSION = '0.0.1'
end