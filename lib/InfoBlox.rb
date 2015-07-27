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
    #  Option values are:
    #   :config_file - YAML config file
    #   Example format:
    #   # Credentials config items
    #   credentials:
    #     username: "admin"
    #     password: "infoblox"
    #     servername: "192.168.0.112"
    #     wapi_version: "v1.4"
    #
    #   OR
    #   the following options: 
    #    :username - InfoBlox User Name
    #    :password - Password
    #    :servername - InfoBlox Server name
    #    :wapi_version - Optional Version of WAPI API. Default: v1.4
    # @return none
    def initialize (options = {})
  
      if options.empty?
         raise "Please pass appropriate options for InfoBlox class"
      end
  
      if options.key?(:config_file) 
        # Read values from Config File ...
        @config_name = options[:config_file] 
        # Read the YAML config file...
        puts "#{@config_name}" if @debug if @debug
        @config = read_config(@config_name)
        @user = @config['credentials']['username']
        @password= @config['credentials']['password']
        @servername = @config['credentials']['servername']
        @wapi_version = @config['credentials']['wapi_version']
        if @wapi_version.nil?
	   @wapi_version = "v1.4"
        end
        @connection ="#{@user}:#{@password}@#{@servername}" 
        #@debug = @config['test']['debug']
        @debug = false
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
        @wapi_version = @config['credentials']['wapi_version']
        if @wapi_version.nil?
	   @wapi_version = "v1.4"
        end
        @debug = false
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
          puts exception.message if @debug
          raise exception
        end
    end
  
  
    ##################################
    # @!method fetchHost 
    # @version 0.2
    # @param options - Hash
    #  Hash should contain all of the following elements:
    #    :host - host name
    #    :ipv4addr - ip addres for the host
    #
    # @return [Boolean] True or False
    def addHost(options)
       # Set the location ... 
       @location = "/wapi/v1.2/record:host"

       json_data = {}
       ipvaddrs_data = {}
       ipvaddrs_array = []
  
       if options.key?(:name) == false &&   options.key?(:ipv4addr) == false  &&   options.key?(:view) == false  
              raise "You must pass the following options in the hash: name, ipv4addr, view"
       end
       if options.key?(:ipv4addr) 
         ipvaddrs_data[:ipv4addr] = options[:ipv4addr] 
         ipvaddrs_array[0] = ipvaddrs_data
         json_data[:ipv4addrs] = ipvaddrs_array
       end
       if options.key?(:name) 
         json_data[:name] = options[:name] 
       end 
       if options.key?(:name) 
         json_data[:view] = options[:view]
       end

       request = JSON.generate(json_data)
        
       puts request.inspect if @debug
       response = nil
       
       begin
         response = @client.post(@location, request)
         return response
       rescue => ex
         raise ex
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
       @location = "/wapi/"+@wapi_version+"/record:host?"
  
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
        
       puts request.inspect if @debug
       response = nil
       
       begin
         response = @client.get(@location, request)
         return response
       rescue => ex
         raise ex
       end
    end 
  
    ##################################
    # @!method  getAllNetworks 
    # @version 0.2
    # @param None
    # @return [Array] Array of Hashes with the information of the networks.
    ##################################
    def getAllNetworks
      # Set the location ... 
      @location = "/wapi/"+@wapi_version+"/network"
  
      begin
        response = @client.get(@location, nil)
        return response
      rescue => ex
        raise ex
      end
    end
  
    ##################################
    # @!method  deleteHost 
    #   Deletes a host entry from InfoBlox
    # @version 0.2
    # @param host_ref - Host Reference for Host Record fetched from InfoBlox  
    # Example reference record: record:host/ZG5zLmhvc3QkLm5vbl9ETlNfaG9zdF9yb290LnVua25vd24taG9zdA:unknown-host/%20
    # @return [Array] Array of Hashes with the information of the networks.
    ##################################
    ##################################
    def deleteHost(host_ref)
      if host_ref.nil?
	  raise "Need a _ref object to delete"
      end
      # Set the location ... 
      @location = "/wapi/" + @wapi_version + "/" + host_ref
  
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
    # @!method  deleteIpFromHost
    #   Deletes an IP address record to an existing Host Record in InfoBlox
    # @version 0.2
    # @param hostname - Name of the existing host in InfoBlox
    # @param ipaddress - Valid IP address
    # @return [Boolean] Call will return true if successful. Otherwise an exception will be raised.
    ##################################
    def deleteIpFromHost(hostname, ipaddress)
      # Set the location ... 
      @location = "/wapi/"+@wapi_version+"/record:host"
     
      # Use 'ipv4addrs+' or 'ipv4addrs-'
      #
      # PUT /record:host/ZG5zLmhvc3QkLl9kZWZhdWx0Lm9yZy5naC53YXBp
      # Content-Type: application/json
      #
      # { 
      #    "ipv4addrs-":[
      #       { "ipv4addr":"2.2.2.22" }
      #       { "ipv4addr":"4.4.4.24" }
      #     ]
      # }
  
      if hostname.nil? || ipaddress.nil?
         raise "You must pass in a hostname and an IP address"
      end

      if validate_ipaddr(ipaddress) == false
         raise "IP Address value: #{ipaddress} is not valid!"
      end
 
      # First we need to fetch the record ...

      puts "------- Fetch Host -------" if @debug
      options = {}
      host_ref = {}
      options[:name] = "#{hostname}"
      uooie = self.fetchHost(options)
      puts "Returned Value: " + uooie.inspect if @debug
      ref = {}
      host_ref = uooie[0] # fetchHost will return an array of 1.  Pick up the first element.
      puts "Ref = " + host_ref.inspect  if @debug
      puts "------- Fetch Host -------" if @debug

      @location = "/wapi/"+@wapi_version+"/" + host_ref["_ref"]
      # Now we can create the location to the InfoBlox API
      json_data = {}
      ipv4addr_data = {}
      ipv4addr_array = []

      json_data[:name] = hostname 
      ipv4addr_data[:ipv4addr] = ipaddress 
      ipv4addr_array[0] = ipv4addr_data
      json_data['ipv4addrs-'] = ipv4addr_array
      request = JSON.generate(json_data)
  
      puts @location if @debug
      begin
        response = @client.put(@location, request)
        return true
      rescue => ex
        raise ex
      end

    end

    ##################################
    # @!method  addIpToHost
    #   Adds an IP address record to an existing Host Record in InfoBlox
    # @version 0.2
    # @param hostname - Name of the existing host in InfoBlox
    # @param ipaddress - Valid IP address
    # @return [Boolean] Call will return true if successful. Otherwise an exception will be raised.
    ##################################
    def addIpToHost(hostname, ipaddress)
      # Set the location ... 
      @location = "/wapi/"+@wapi_version+"/record:host?"
     
      # Use 'ipv4addrs+' or 'ipv4addrs-'
      #
      # PUT /record:host/ZG5zLmhvc3QkLl9kZWZhdWx0Lm9yZy5naC53YXBp
      # Content-Type: application/json
      #
      # { 
      #    "ipv4addrs+":[
      #       { "ipv4addr":"2.2.2.22" }
      #       { "ipv4addr":"4.4.4.24" }
      #     ]
      # }
  
      if hostname.nil? || ipaddress.nil?
         raise "You must pass in a hostname and an IP address"
      end

      if validate_ipaddr(ipaddress) == false
         raise "IP Address value: #{ipaddress} is not valid!"
      end
 
      # First we need to fetch the record ...

      puts "------- Fetch Host -------" if @debug
      options = {}
      host_ref = {}
      options[:name] = "#{hostname}"
      uooie = self.fetchHost(options)
      puts "Returned Value: " + uooie.inspect if @debug
      ref = {}
      host_ref = uooie[0] # fetchHost will return an array of 1.  Pick up the first element.
      puts "Ref = " + host_ref.inspect  if @debug
      puts "------- Fetch Host -------" if @debug

      @location = "/wapi/"+@wapi_version+"/" + host_ref["_ref"]
      # Now we can create the location to the InfoBlox API
      json_data = {}
      ipv4addr_data = {}
      ipv4addr_array = []

      json_data[:name] = hostname 
      ipv4addr_data[:ipv4addr] = ipaddress 
      ipv4addr_array[0] = ipv4addr_data
      json_data['ipv4addrs+'] = ipv4addr_array
      request = JSON.generate(json_data)
  
      puts @location if @debug
      begin
        response = @client.put(@location, request)
        return true
      rescue => ex
        raise ex
      end

    end

    ##################################
    # @!method  getIP
    #  Method used to see if host exists in InfoBlox
    # @version 0.2
    # @param hostname - Name of the host
    # @param ipaddress - IP Address associated with the host. Must be valid IP address
    # @return [Boolean] Returns true if successful otherwise an exception will be thrown
    ##################################
    def getIP(hostname, ipaddress)
      # Set the location ... 
      @location = "/wapi/"+@wapi_version+"/record:host?"


      if validate_ipaddr(ipaddress) == false
         raise "IP Address value: #{ipaddress} is not valid!"
      end

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
    # @!method fetchNetworkRef 
    #   Fetch Network Reference 
    # @version 0.2
    # @param cdir - IP Network entry. e.g 192.168.0.0/24  
    # @return [network_ref] Returned InfoBlox reference to the network entry
    ##################################
    ##################################
    def fetchNetworkRef(cdir)
      # Set the location ... 
      @location = "/wapi/"+@wapi_version+"/network?"
  
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
    # @!method  nextIP
    #   Retrieve the next Available IP Address for a network
    # @version 0.2
    # @param network - InfoBlox network reference 
    # @return [String] Returns the next available IP address for he network passed
    ##################################
    def nextIP(network)
      # Set the location ... 
      #@location = "/wapi/v1.4/network"
      @location = "/wapi/"+@wapi_version+"/" + "#{network}" + "?_function=next_available_ip&num=1"
      puts "nextIP: #{@location}" if @debug
  
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
