class Admin::SecureController < ApplicationController
  include AuthenticatedSystem
  include Admin::SortHelper
  include Admin::QueriesHelper 
  
  before_filter :login_required
  before_filter :manager_required
  
  def login_required
      authorized? || access_denied
    end

    def access_denied
      respond_to do |format|
        format.html do
          store_location
          redirect_to new_admin_sessions_path
        end
        format.any do
          request_http_basic_authentication 'Web Password'
        end
      end
    end
    
    def manager_required
      manager? || not_authorized_access
    end
  
    def not_authorized_access
      render :text => 'You have to be manager to access this page'
    end
    
    def manager?
      current_user.is_manager?
    end
end

