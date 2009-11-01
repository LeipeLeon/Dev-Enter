class ApplicationController < ActionController::Base
  # AuthenticatedSystem must be included for RoleRequirement, and is provided by installing acts_as_authenticates and running 'script/generate authenticated account user'.
  # include AuthenticatedSystem
  # You can move this into a different controller, if you wish.  This module gives you the require_role helpers, and others.
  # include RoleRequirementSystem


  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  include ExceptionNotifiable
  
  # Scrub sensitive parameters from your log
  filter_parameter_logging :password
  
  def frontpage
    
  end
end
