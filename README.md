# InfoBlox
This is a InfoBlox GEM that can be used by users that want to communicate with the InfoBlox appliance.

This GEM has the following basic functionality:

* addHost - Adds a host entry to InfoBlox
* fetchHost - Fetches a host entry from InfoBlox
* deleteHost - Deletes a host entry from InfoBlox
* getAllNetworks - Retrieves all defined networks in InfoBlox
* deleteIPHost - Deletes an IP record from a host entry.
* addIPToHost - Adds an IP record to an existing host entry.
* getIP - Checks if the the IP address exists in a record in InfoBlox.
* fetchNetworkRef - Retries the network reference from InfoBlox for a particular network.
* nextIP - Retrieves the next available IP address from InfoBlox.

## InfoBlox Ruby API
-----------------
InfoBlox API to communicate with InfoBlox WAPI.

This GEM is targeted to be installed in a Cloudform Appliance and used within the Automate code.

The directory structure are:

doc/ - Contains YardDoc documentation for the Connection and WAPI classes.

test/ - Contains a test suite for the API.

lib/ - Contains the source code for the Connection and WAPI APIs.

spec/ - Contains the spec to build the GEM.

Makefile - Make file to build the GEM.

## YardDoc documentation
We try to document all our code with YardDoc.  The doc directory contains the generated YarDoc documentation for this GEM.

## How to build it

    [claudiol@fedora20 InfoBlox (claudiol-infoblox *)]$ gem build spec/InfoBlox.gemspec
    Successfully built RubyGem
    Name: InfoBloxConnection
    Version: 0.2
    File: InfoBloxConnection-0.2.gem
    [claudiol@fedora20 InfoBlox (claudiol-infoblox *)]$

If you make changes please make sure that you do the following:

* Make the changes to the code.
* Test them and add a test in the test/infoblox-test.rb
* Create a pull request


## How to use the GEM

### YAML Config File
You can use a config file with the InfoBlox GEM.  The config file format is:
    #
    # YAML Config file for InfoBlox Service
    #
    # Credentials config items
    credentials:
      username: "admin"
      password: "infoblox"
      servername: "192.168.0.112"
      wapi_version: "v1.4"

Then in your code you can do the following:

    require 'InfoBlox'

    options = {}
    options[:config_file] = "infoblox.yaml"

    @infoblox = InfoBlox::WAPI.new(options)

## Passing Parameters
You can also just pass the Parameters required in the options hash like so:

    require 'InfoBlox'

    options = {}
    options[:username] = "admin"
    options[:password]: "infoblox"
    options[:servername] = "<IP Address>"
    options[:wapi_version] = "v1.4" # default is v1.2
    @infoblox = InfoBlox::WAPI.new(options)

### Within Cloudforms
You can use the GEM withing Cloudforms.  All you need to do is include the following statements:

1. Make sure that the gem is installed on your Cloudforms Worker Appliance
2. Add the following to the method you want to use the GEM in:

        def my_cloudforms_method()
          require 'InfoBlox'

          options = {}
          options[:username] = "admin"
          options[:password]: "infoblox"
          options[:servername] = "<IP Address>"
          options[:wapi_version] = "v1.4" # default is v1.2
          @infoblox = InfoBlox::WAPI.new(options)
          ...
        end
Obviously you can put the values in a variable inside a CloudForms State Machine but the above will work.


### Outside of Cloudforms
1. Make sure that the gem in installed.

    gem install --local InfoBloxConnection-0.2.gem
2. The following is an example on how to use the API:

        require 'InfoBlox'

        @network_ref = nil
        @debug = false

        def add_host_test(infoblox)
          begin
            options = {}
            puts "------- Add Host Test -------" if @debug
            options[:name] = "my-host"
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

        # Tests start here
        begin
          @add_host_test = false
          options = {}

          options[:config_file] = "infoblox.yaml"
          @infoblox = InfoBlox::WAPI.new(options)

          @add_host_test = add_host_test(@infoblox)

          puts "add_host_test: #{@add_host_test}"

        rescue => ex
          puts ex.message
          puts ex.backtrace
        end



## Contact Information
If you have any questions regarding this code base please send an email to one of the following contributors:
Lester Claudio - lester@redhat.com
Jason Ritenour - jritenou@redhat.com
Jose Simonelli - jose@redhat.com
