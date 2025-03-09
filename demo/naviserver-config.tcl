# sudo /usr/local/ns/bin/nsd -u void -t  /home/void/Downloads/code/tcl/nsproj/my-server.tcl -f
# 
# This is a fairly minimal NaviServer configuration file that makes the server to
# accept HTTP requests on 0.0.0.0:8000 (IPv4)
#
# Logs are in the logs/nsd.log and logs/access.log
#
# When the nscp module is enabled it will accept telnet into nscp on
# [::1]:2080 (IPv6) or 127.0.0.1:2080 (IPv4)
#

ns_section ns/servers {
    ns_param    default         NaviServer
}

ns_section ns/server/default {
    ns_param enabletclpages true
}

ns_section ns/server/default/adp {
    ns_param    map              /*.adp
}
ns_section ns/server/default/modules {
    #ns_param   nscp            nscp
    ns_param    nssock          nssock
    ns_param    nslog           nslog
    ns_param    websocket       tcl
}
ns_section ns/server/default/module/nssock {
    ns_param    address         0.0.0.0
    ns_param    port            8000
}

ns_section ns/server/default/fastpath {
    ns_param pagedir /home/tcl/mytest
    ns_param directoryfile "routes.tcl"
}
ns_section "ns/server/default/module/websocket/live-reload" {
    ns_param urls     /live-reload
    ns_param refresh  1000
    }
