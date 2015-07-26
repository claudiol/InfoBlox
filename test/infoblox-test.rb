require 'InfoBlox'

begin
  options = {}

  options[:config_file] = "infoblox.yaml"
  infoblox = InfoBlox::WAPI.new(options)

  puts "------- Add Host Test -------"
  options[:name] = "unknown-host"
  options[:ipv4addr] = "192.168.0.2"
  options[:view] = ' '
  uooie = infoblox.addHost(options)
  puts "Returned Value: " + uooie.inspect
  puts "------- Add Host Test -------"
  puts ""


  puts "------- Search Test -------"
  puts "uooie = infoblox.getIP(\"fedora-laptop\",\"192.168.0.92\")"
  uooie = infoblox.getIP("fedora-laptop","192.168.0.92")
  puts "Returned Value: #{uooie}"
  puts "------- End Search Test -------"


  puts ""
  puts "------- Network Search All Test -------"
  uooie = infoblox.getAllNetworks
  puts "Returned Value: " + uooie.inspect
  puts "------- End Network Search All Test -------"

  puts ""
  puts "------- Network Search Next IP Test -------"
  network_ref = uooie[0]["_ref"]
  puts network_ref.inspect

  uooie = infoblox.nextIP(network_ref)
  puts "Returned Value: " + uooie.inspect
  puts "------- End Network Search All Test -------"

  puts "------- Fetch Network Test -------"
  uooie = infoblox.fetchNetworkRef("192.168.0.0/24")
  puts "Returned Value: " + uooie.inspect
  puts "------- Fetch Network Test -------"

  puts "------- Fetch Host Test -------"
  options = {}
  options[:name] = "unknown-host"
  uooie = infoblox.fetchHost(options)
  puts "Returned Value: " + uooie.inspect
  ref = {}
  ref = uooie[0] # fetchHost will return an array of 1.  Pick up the first element.
  puts "Ref = " + ref.inspect + "\n uoie[0] = " + uooie[0].inspect 
  puts "------- Fetch Host Test -------"

  puts "------- Delete Host Test -------"
  # Pass in the "_ref" element to deleteHost.
  # It should look like: record:host/ZG5zLmhvc3QkLm5vbl9ETlNfaG9zdF9yb290LnVua25vd24taG9zdA:unknown-host/%20
  # 
  uooie = infoblox.deleteHost(ref["_ref"])
  puts "Returned Value: " + uooie.inspect
  puts "------- Delete Host Test -------"
rescue => ex
  puts ex.message
  puts ex.backtrace
end

