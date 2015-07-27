require 'InfoBlox'

@network_ref = nil
@debug = false

def add_host_test(infoblox)
  begin
     options = {}
     puts "------- Add Host Test -------" if @debug
     options[:name] = "unknown-host"
     options[:ipv4addr] = "192.168.0.2"
     options[:view] = ' '
     uooie = infoblox.addHost(options)
     puts "Returned Value: " + uooie.inspect if @debug
     puts "------- Add Host Test -------" if @debug
     puts "" if @debug
     return true
  rescue => ex
     puts "------- FAILED: Add Host Test -------" if @debug
     puts ex.message
     return false
  end
end

def add_ip_to_host_test(infoblox) 
  begin
    puts "" if @debug
    puts "------- Add IP to Host Test -------" if @debug
    puts "uooie = infoblox.addIpToHost(\"unknown-host\",\"192.168.0.3\")" if @debug
    uooie = infoblox.addIpToHost("unknown-host","192.168.0.3")
    puts "Returned Value: " + uooie.inspect if @debug
    puts "------- Add IP to Host Test -------" if @debug
    puts "" if @debug
    return true
  rescue => ex
    puts "------- FAILED: Add IP to Host Test -------" if @debug
    puts ex.message
    return false
  end
end

def delete_ip_from_host_test(infoblox) 
  begin
    puts "" if @debug
    puts "------- Delete IP from Host Test -------" if @debug
    puts "uooie = infoblox.deleteIpFromHost(\"unknown-host\",\"192.168.0.3\")" if @debug
    uooie = infoblox.deleteIpFromHost("unknown-host","192.168.0.3")
    puts "Returned Value: " + uooie.inspect if @debug
    puts "------- Delete IP from Host Test -------" if @debug
    puts "" if @debug
    return true
  rescue => ex
    puts "------- FAILED: Add IP to Host Test -------" if @debug
    puts ex.message if @debug
    puts ex.backtrace
    return false
  end
end


def search_ip_test(infoblox) 
  begin
    puts "------- Search Test -------" if @debug
    puts "uooie = infoblox.getIP(\"fedora-laptop\",\"192.168.0.92\")" if @debug
    uooie = infoblox.getIP("fedora-laptop","192.168.0.92")
    puts "Returned Value: #{uooie}" if @debug
    puts "------- End Search Test -------" if @debug
    return true
  rescue => ex
    puts "------- FAILED: Search Test -------" if @debug
    puts ex.message
    return false
  end
end

def network_search_all_test(infoblox) 
  begin
    puts "" if @debug
    puts "------- Network Search All Test -------" if @debug
    uooie = infoblox.getAllNetworks
    puts "Returned Value: " + uooie.inspect if @debug
    puts "------- End Network Search All Test -------" if @debug
    @network_ref = uooie[0]["_ref"]
    return true
  rescue => ex
    puts "------- FAILED: Network Search All Test -------" if @debug
    puts ex.message
    return false
  end
end


def network_next_ip_test (infoblox) 
  begin
    puts "" if @debug
    puts "------- Network Search Next IP Test -------" if @debug
    uooie = infoblox.nextIP(@network_ref)
    puts "Returned Value: " + uooie.inspect if @debug
    puts "------- End Network Search Next IP Test -------" if @debug
    puts "" if @debug
    return true
  rescue => ex
    puts "------- FAILED: Network Search Next IP Test -------" if @debug
    puts ex.message
    return false
  end
end

def fetch_network_test(infoblox) 
  begin
    puts "------- Fetch Network Test -------" if @debug
    uooie = infoblox.fetchNetworkRef("192.168.0.0/24")
    puts "Returned Value: " + uooie.inspect if @debug
    puts "------- Fetch Network Test -------" if @debug
    return true
  rescue => ex
    puts "------- FAILED: Fetch Network Test -------" if @debug
    puts ex.message
    return false
  end
end

ref = {}
def fetch_host_test(infoblox) 
  begin
    puts "------- Fetch Host Test -------" if @debug
    options = {}
    options[:name] = "unknown-host"
    uooie = infoblox.fetchHost(options)
    puts "Returned Value: " + uooie.inspect if @debug
    @ref = uooie[0] # fetchHost will return an array of 1.  Pick up the first element.
    puts "Ref = " + ref.inspect + "\n uoie[0] = " + uooie[0].inspect  if @debug
    puts "------- Fetch Host Test -------" if @debug
    puts "" if @debug
    return true
  rescue => ex
    puts "------- FAILED: Fetch Host Test -------" if @debug
    puts ex.message
    return false
  end
end

def delete_host_test(infoblox) 
  begin
    puts "------- Delete Host Test -------" if @debug
    # Pass in the "_ref" element to deleteHost.
    # It should look like: record:host/ZG5zLmhvc3QkLm5vbl9ETlNfaG9zdF9yb290LnVua25vd24taG9zdA:unknown-host/%20
    # 
    uooie = infoblox.deleteHost(@ref["_ref"])
    puts "Returned Value: " + uooie.inspect if @debug
    puts "------- Delete Host Test -------" if @debug
    puts "" if @debug
    return true
  rescue => ex
    puts "------- FAILED: Delete Host Test -------" if @debug
    puts ex.message
    return false
  end
end

begin
  @add_host_test = false
  options = {}

  options[:config_file] = "infoblox.yaml"
  @infoblox = InfoBlox::WAPI.new(options)

  @add_host_test = add_host_test(@infoblox)

  puts "add_host_test: #{@add_host_test}" 

  @add_ip_to_host_test = add_ip_to_host_test(@infoblox)
  puts "add_ip_to_host_test: #{@add_ip_to_host_test}" 

  @delete_ip_from_host = delete_ip_from_host_test(@infoblox) 
  puts "delete_ip_from_host_test: #{@delete_ip_from_host}" 

  @search_ip_test = search_ip_test(@infoblox)
  puts "search_ip_to_host_test: #{@search_ip_test}" 

  @network_search_all_test = network_search_all_test(@infoblox)
  puts "network_search_all_test: #{@network_search_all_test}" 

  @network_next_ip_test = network_next_ip_test(@infoblox)
  puts "network_next_ip_test: #{@network_next_ip_test}" 

  @fetch_network_test = fetch_network_test(@infoblox)
  puts "fetch_network_test: #{@fetch_network_test}" 

  @fetch_host_test = fetch_host_test(@infoblox)
  puts "fetch_host_test: #{@fetch_host_test}" 

  @delete_host_test = delete_host_test(@infoblox)
  puts "delete_host_test: #{@delete_host_test}" 

rescue => ex
  puts ex.message
  puts ex.backtrace
end

