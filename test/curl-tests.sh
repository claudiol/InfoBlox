#curl -k -u admin:infoblox -X GET https://192.168.0.112/wapi/v1.0/record:host -d name~=fedora-laptop
#curl -k -u admin:infoblox -X GET https://192.168.0.112/wapi/v1.0/record:host -d ipv4addr~=192.168.0.92
#curl -k -u admin:infoblox -X POST https://192.168.0.112/wapi/v1.4/record:host -d ipv4addr~=192.168.0.92
#curl -k -u admin:infoblox -H "Content-Type: application/json" -X POST https://192.168.0.112/wapi/v1.2/record:host -d '{ "ipv4addrs":[{"configure_for_dhcp": false,"ipv4addr": "192.168.0.2"}],"name": "unknown-host","view": " "}'
#curl -k -u admin:infoblox -X DELETE https://192.168.0.112/wapi/v1.0/record:host?_ref=ZG5zLmhvc3RfYWRkcmVzcyQubm9uX0ROU19ob3N0X3Jvb3QuZmVkb3JhLWxhcHRvcC4xOTIuMTY4LjAuOTIu
curl -k -u admin:infoblox -X DELETE https://192.168.0.112/wapi/v1.4/record:host/ZG5zLmhvc3QkLm5vbl9ETlNfaG9zdF9yb290LnVua25vd24taG9zdA:unknown-host/%20
#curl -k -u admin:infoblox -X POST https://admin:infoblox@192.168.0.112/wapi/v1.4/network/ZG5zLm5ldHdvcmskMTkyLjE2OC4wLjAvMjQvMA:192.168.0.0/24/default?_function=next_available_ip&num=3


