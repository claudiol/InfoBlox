#!/usr/bin/env ruby
#####################################################################################
# @author Copyright 2015 Lester Claudio <lester@redhat.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License.
#
######################################################################################
#
# Contact Info: <lester@redhat.com>
#
######################################################################################

require 'rest-client'
require 'json'
require 'singleton'

#  InfoBloxConnection
#  Singleton connection class to support InfoBlox service calls.
#  This class could be used for any generic REST API service calls.
#
module InfoBlox
  class Connection
    include Singleton

    attr_reader :url

    # 
    # @!method initialize
    #
    # Constructor
    #
    # @param none.
    # @return none
    def initialize
      @method = nil
      @host = nil
      @user = nil
      @password = nil
      @verifyssl = nil
      @url = nil
    end

    # 
    # @!method set_up
    # @version 0.2
    # Sets up the internal class instance variables. 
    #
    # @param     username - Username for InfoBlox
    # @param     password - Password for InfoBlox
    # @param     host - InfoBlox host  
    # @param     verifyssl - Whether or not to use SSL (true/false)
    #
    # @return none
    #
    def setup(username, password, host, verifyssl=false)
      @username = username 
      @password = password 
      @verifyssl = verifyssl
      @host = host
      @url = "https://#{@username}:#{@password}@#{@host}"
      @debug = false
    end

    # @!method get
    # @version 0.2
    # Handles the GET requests
    # @param location - Location for REST API e.g. /wapi/v1.4/record:host? 
    # @param json_data - Data payload for API.
    #
    # @return [Hash] results - Response from WAPI REST API
    #
    def get(location, json_data)
  
      if !location.nil? 
        puts "Location: " + location if @debug
      end
      if !json_data.nil?  
         puts "Json Data: " + json_data if @debug
      end
      response = nil

      if json_data.nil?
        response = RestClient::Request.new(
            :method => :get,
            :url => @url+location,
            :user => @user,
            :password => @password,
            :verify_ssl => @verifyssl,
            :headers => { :accept => :json,
                          :content_type => :json }
          ).execute
      else
          puts "#{url}#{location}" if @debug
          response = RestClient::Request.new(
              :method => :get,
              :url => @url+location,
              :user => @user,
              :password => @password,
            :verify_ssl => @verifyssl,
            :headers => { :accept => :json,
                          :content_type => :json},
            :payload => json_data # JSON.generate(json_data)
          ).execute { |response, request, result, &block|
       	  if [301, 302, 307].include? response.code
         	response.follow_redirection(request, result, &block)
       	  else
         	response.return!(request, result, &block)
          end
        }
      end

      if !response.nil?
        results = JSON.parse(response.to_str)
        return results
      end
    end

    # @!method post
    # @version 0.2
    # Handles the POST requests
    # @param location - Location for REST API 
    # @param json_data - Data payload for API.
    #
    # @return results - Response from WAPI REST API
    #
    def post(location, json_data)
      if !location.nil? 
        puts "Location: " + @url + location if @debug
      end
      if !json_data.nil?  
         puts "Json Data: " + json_data if @debug
      end

      response = nil
      if json_data.nil?
        response = RestClient::Request.new(
            :method => :post,
            :url => @url+location,
            :user => @user,
            :verify_ssl => @verifyssl,
            :password => @password,
            :headers => { :accept => :json,
                          :content_type => :json}
        ).execute
      else
        response = RestClient::Request.new(
            :method => :post,
            :url => @url+location,
            :user => @user,
            :verify_ssl => @verifyssl,
            :password => @password,
            :headers => { :accept => :json,
                          :content_type => :json}, 
            :payload => json_data
        ).execute { |response, request, result, &block|
       	  if [301, 302, 307].include? response.code
         	response.follow_redirection(request, result, &block)
       	  else
         	response.return!(request, result, &block)
          end
        }
      end
  
      # How to fix: "unexpected token" error for JSON.parse
      # :quirks_mode => true added because InfoBlox added a space at the end of the reponse
      # POST returns: "\"record:host/ZG5zLmhvc3QkLm5vbl9ETlNfaG9zdF9yb290LnVua25vd24taG9zdA:new-host/%20\""
      #
      if !response.nil?
        puts "POST returns: " + response.inspect if @debug
        results = JSON.parse(response.to_str, :quirks_mode => true)
        return results
      end
    end

    # @!method put
    # @version 0.2
    # Handles the PUT requests 
    # @param location - Location for REST API 
    # @param json_data - Data payload for API.
    #
    # @return results - Response from WAPI REST API
    #
    def put(location, json_data)
      response = nil

      if json_data.nil?
        response = RestClient::Request.new(
            :method => :put,
            :url => @url+location,
            :user => @user,
            :verify_ssl => @verifyssl,
            :password => @password,
            :headers => { :accept => :json,
                          :content_type => :json}
        ).execute
      else
        response = RestClient::Request.new(
            :method => :put,
            :url => @url+location,
            :user => @user,
            :verify_ssl => @verifyssl,
            :password => @password,
            :headers => { :accept => :json,
                          :content_type => :json},
            :payload => json_data #JSON.generate(json_data)
        ).execute { |response, request, result, &block|
       	  if [301, 302, 307].include? response.code
         	  response.follow_redirection(request, result, &block)
       	  else
         	  response.return!(request, result, &block)
          end
        }
      end
  
      if !response.nil?
        results = JSON.parse(response.to_str, :quirks_mode=> true)
        return results
      end
    end
  
    # @!method delete
    # @version 0.2
    # Handles the DELETE requests
    # @param location - Location for REST API 
    # @param json_data - Data payload for API.
    #
    # @return results - Response from WAPI REST API
    #
    def delete(location, json_data)
  
      if !location.nil? 
        puts "delete Location: " + @url + location if @debug
      end
      if !json_data.nil?  
         puts "delete Json Data: " + json_data if @debug
      end

      response = nil
  
      if json_data.nil?
        response = RestClient::Request.new(
            :method => :delete,
            :url => @url+location,
            :user => @user,
            :verify_ssl => @verifyssl,
            :password => @password,
            :headers => { :accept => :json,
                          :content_type => :json}
        ).execute { |response, request, result, &block|
       	  if [301, 302, 307].include? response.code
         	  response.follow_redirection(request, result, &block)
       	  else
         	  response.return!(request, result, &block)
          end
        }
      else
        response = RestClient::Request.new(
            :method => :delete,
            :url => @url+location,
            :user => @user,
            :password => @password,
            :verify_ssl => @verifyssl,
            :headers => { :accept => :json,
                          :content_type => :json},
            :payload => json_data 
        ).execute { |response, request, result, &block|
       	  if [301, 302, 307].include? response.code
         	  response.follow_redirection(request, result, &block)
       	  else
         	  response.return!(request, result, &block)
          end
        }
      end
  
      if !response.nil?
        results = JSON.parse(response.to_str, :quirks_mode => true)
        return results
      end
    end
  
    # @!method api_version
    # Returns the InfoBlox GEM Version
    def api_version
      @api_ver = "v0.2"
      return @api_ver
    end
  end
end
