# Copyright 2013, Dell 
# 
# Licensed under the Apache License, Version 2.0 (the "License"); 
# you may not use this file except in compliance with the License. 
# You may obtain a copy of the License at 
# 
#  http://www.apache.org/licenses/LICENSE-2.0 
# 
# Unless required by applicable law or agreed to in writing, software 
# distributed under the License is distributed on an "AS IS" BASIS, 
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 
# See the License for the specific language governing permissions and 
# limitations under the License. 
# 


class SupportController < ApplicationController

  def eula
  end
  
  # used to pass a string into the debug logger to help find specificall calls  
  def marker
    Rails.logger.info "\nMARK >>>>> #{params[:id]} <<<<< KRAM\n"
    render :text=>params[:id]
  end

  def import
    @barclamps = Barclamp.all
  end

  # allows user to change UI behaviors  
  def settings_put
  
    # expected to set ALL values in one put using checkboxes
    # for this reason, missing values are assumed FALSE
    current_user.settings(:ui).refresh = params[:refresh].to_i rescue current_user.settings(:ui).refresh
    current_user.settings(:ui).fast_refresh = params[:fast_refresh].to_i rescue current_user.settings(:ui).fast_refresh
    current_user.settings(:ui).node_refresh = params[:node_refresh].to_i rescue current_user.settings(:ui).node_refresh
    current_user.settings(:ui).edge = params[:edge].eql?('true') rescue false
    current_user.settings(:ui).test = params[:test].eql?('true') rescue false
    current_user.settings(:ui).debug = params[:debug].eql?('true') rescue false
    current_user.settings(:ui).milestone_roles = params[:milestone_roles].eql?('true') rescue false
    current_user.settings(:errors).expand = params[:expand].eql?('true') rescue false
    current_user.save!
    #render :json=>true
    redirect_to :action => :settings

  end

  def settings
    respond_to do |format|
      format.html { }
    end
  end

  # supplies UI heartbeat information
  # /api/status/heartbeat
  def heartbeat
    if session[:marker] != params[:marker]
      session[:marker] = params[:marker]
      session[:start] = Time.now
    end
    elapsed = (Time.now - session[:start]) rescue 0
    nodes = Node.count

    total = nil
    error = nil
    active = nil
    NodeRole.transaction do   # performance optimization
      total = NodeRole.count
      error = NodeRole.where(state: NodeRole::ERROR).count
      active = NodeRole.where(state: NodeRole::ACTIVE).count
    end
    render :json=>{ :active=>active, :todo=>(total-error-active), :error=>error, :elapsed=>elapsed.to_i, :nodes=>nodes } 
  end
  
end 
