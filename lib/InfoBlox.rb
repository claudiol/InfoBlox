###################################
#
# EVM Automate Method: Infoblox_Host_Record
#
# Notes: EVM Automate method to add Host entry to Infoblox
#
###################################


require 'rest_client'
require 'json'
require 'nokogiri'
require 'ipaddr'
#require 'YAML'
require 'safe_yaml'
load 'InfoBloxConnection.rb'

#require 'singleton'

module InfoBlox
  class WAPI

    #
    # @!method initialize
    #
    # Constructor. Sets up the internal variables for this class
    #
    # @param options - Hash
    #  Hash should contain the following:
    #    :username - InfoBlox User Name
    #    :password - Password
    #    :servername - InfoBlox Server name
    # @return none
    def initialize (options = {})
  
      if options.empty?
         raise "Please pass appropriate options for InfoBlox class"
      end
  
      if options.key?(:config_file) 
        # Read values from Config File ...
        @config_name = options[:config_file] 
        # Read the YAML config file...
        puts "#{@config_name}"
        @config = read_config(@config_name)
        @user = @config['credentials']['username']
        @password= @config['credentials']['password']
        @servername = @config['credentials']['servername']
        @connection ="#{@user}:#{@password}@#{@servername}" 
      else
        # We will get each option from the options hash
        if options.key?(:username) == false || 
	   options.key?(:password) == false ||
           options.key?(:servername) == false 
	  raise "Please pass all required options :username, :password, :servername"
        end
        @user = options[:username]
        @password =  options[:password]
        @servername = options[:servername]
      end
      # get the InfoBlox Connection Instance - Singleton
      @client = InfoBlox::Connection.instance
      @client.setup(@user, @password, @servername)
    end

    # 
    # @!method read_config
    # @version 0.2
    # @param config_name [String] Configuration file name
    #
    # @return [Collection] Returns the YAML collection of configuration items. 
    def read_config(config_name)
        begin
          return YAML.load_file(config_name)
        rescue => exception
          puts exception.message
        end
    end
  
  
    ##################################
    # @!method fetchHost 
    # @version 0.2
    # @param options - Hash
    #  Hash should contain one or more of the following:
    #    :host - host name
    #    :mac - mac address for the host
    #    :ipv4addr - ip addres for the host
    #
    # @return [Hash] Hash with the information of the host or empty. 
    ##################################
    def fetchHost(options)
   
       # Set the location ... 
       @location = "/wapi/v1.4/record:host?"
  
       # We can search for any of these in InfoBlox
       #
       # "_ref"=>"record:host_ipv4addr/ZG5zLmhvc3RfYWRkcmVzcyQubm9uX0ROU19ob3N0X3Jvb3QuZmVkb3JhLWxhcHRvcC4xOTIuMTY4LjAuOTIu:192.168.0.92/fedora-laptop/%20"
       # "configure_for_dhcp"=>false 
       # "host"=>"fedora-laptop"
       # "ipv4addr"=>"192.168.0.92" 
       # "mac"=>"24:77:03:3c:f4:0c"
       ##
       json_data = {}
  
       if options.key?(:name) == false  
          if options.key?(:mac) == false  
            if options.key?(:ipv4addr) == false  
              raise "You must have one of the following options in the hash: name, mac, ipv4addr"
            end
          end
       end
       if options.key?(:name) 
         json_data[:name] = options[:name] 
       end 
       if options.key?(:ipv4addr) 
         json_data[:ipv4addr] = options[:ipv4addr] 
       end
       if options.key?(:mac) 
         json_data[:mac] = options[:mac] 
       end
       request = JSON.generate(json_data)
        
       puts request.inspect
       response = nil
       
       begin
         response = @client.get(@location, request)
         return response
       rescue => ex
         raise ex
       end
    end 
  
    ##################################
    # @!methot  getAllNetworks 
    # @version 0.2
    # @param None
    # @return [Array] Array of Hashes with the information of the networks.
    ##################################
    def getAllNetworks
      # Set the location ... 
      @location = "/wapi/v1.4/network"
  
      begin
        response = @client.get(@location, nil)
        return response
      rescue => ex
        raise ex
      end
    end
  
    ##################################
    # Delete Host                    #
    ##################################
    def deleteHost(item)
      if item.nil?
	  raise "Need a _ref object to delete"
      end
      # Set the location ... 
      @location = "/wapi/v1.4/record:host/" + item
  
      begin
        response = @client.delete(@location, nil)
        return response
      rescue => ex
        raise ex
      end
      #begin
        #url = 'https://' + @connection + '/wapi/v1.4/' + item
        #dooie = RestClient.delete url
        #return true
      #rescue Exception => e
        #puts e.inspect
        #return false
      #end
    end
  
    ##################################
    # Get IP Address                 #
    ##################################
    def getIP(hostname, ipaddress)
      # Set the location ... 
      @location = "/wapi/v1.4/record:host?" 
  
      json_data = {}
      json_data[:name] = hostname unless hostname.nil?
      json_data[:ipv4addr] = ipaddress unless ipaddress.nil?
      request = JSON.generate(json_data)
  
      begin
        response = @client.get(@location, request)
        return true
      rescue => ex
        raise ex
      end
      #begin
        #url = 'https://' + @connection + '/wapi/v1.4/record:host'
        #content = "\{\"ipv4addrs\":\[\{\"ipv4addr\":\"#{ipaddress}\"\}\],\"name\":\"#{hostname}\"\}"
        ##dooie = RestClient.post url, content, :content_type => :json, :accept => :json
        ##dooie = RestClient.post url, content, :content_type => :json, :accept => :json
        #dooie = RestClient.get url, content
        #return true
      #rescue Exception => e
        #puts e.inspect
        #return false
      #end
    end
  
    ##################################
    # Fetch Network Ref              #
    ##################################
    def fetchNetworkRef(cdir)
      # Set the location ... 
      #@location = "/wapi/v1.4/#{cdir}"
      @location = "/wapi/v1.4/network?"
  
      json_data = {}
      json_data[:network] = "#{cdir}"
      request = JSON.generate(json_data)
  
      begin
        response = @client.get(@location, nil)
        return response
      rescue => ex
        raise ex
      end
      
      #begin
        #$evm.log("info","GetIP --> Network Search - #{cdir}")
        #url = 'https://' + @connection + '/wapi/v1.4/network'
        #dooie = RestClient.get url
        #doc = Nokogiri::XML(dooie)
        #root = doc.root
        #networks = root.xpath("value/_ref/text()")
        #networks.each do | a |
          #a = a.to_s
          #unless a.index(cdir).nil?
            #return a
          #end
        #end
        #return nil
      #rescue Exception => e
        #return false
      #end
    end
  
    ##################################
    # Next Available IP Address      #
    ##################################
    def nextIP(network)
      # Set the location ... 
      #@location = "/wapi/v1.4/network"
      @location = "/wapi/v1.4/" + "#{network}" + "?_function=next_available_ip&num=1"
      puts "nextIP: #{@location}"
  
      #json_data = {}
      #json_data[:network] = "#{network}"
      #json_data[:_function] = "next_available_ip"
      #json_data[:num] = "1"
      #request = JSON.generate(json_data)
  
      begin
        response = @client.post(@location, nil)
        nextip = response["ips"]
        return nextip
      rescue => ex
        raise ex
      end
      #begin
        #$evm.log("info","NextIP on - #{network}")
        #url = 'https://' + @connection + '/wapi/v1.0/' + network
        #dooie = RestClient.post url, :_function => 'next_available_ip', :num => '1'
        #doc = Nokogiri::XML(dooie)
        #root = doc.root
        #nextip = root.xpath("ips/list/value/text()")
        #return nextip
      #rescue Exception => e
        #return false
      #end
    end
  
    ############################
    #
    # Method: validate_ipaddr
    # Notes: This method uses a regular expression to validate the ipaddr and gateway
    # Returns: Returns string: true/false
    #
    ############################
    def validate_ipaddr(ip)
      ip_regex = /\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b/
      if ip_regex =~ ip
        return true
      else
        return false
      end
    end
  
    ##################################
    # Set netmask                        #
    ##################################
    def netmask(cdir)
      netblock = IPAddr.new(cdir)
      netins =  netblock.inspect
      netmask = netins.match(/(?<=\/)(.*?)(?=\>)/)
      return netmask
    end
  end
end
