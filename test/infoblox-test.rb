require 'InfoBlox'

begin
  options = {}

  options[:config_file] = "infoblox.yaml"

  puts "------- Search Test -------"
  puts "uooie = infoblox.getIP(\"fedora-laptop\",\"192.168.0.92\")"
  infoblox = InfoBlox::WAPI.new(options)
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
  puts "------- Fetch Host Test -------"

rescue => ex
  puts ex.message
end

