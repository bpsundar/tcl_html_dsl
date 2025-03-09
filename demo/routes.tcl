package require md5crypt

proc root_handler {args} {
    set cookie_value [ns_getcookie first_visit 0]
    if {$cookie_value eq "0"} {
        set salt [md5crypt::salt]
        ns_setcookie -expires -1 -- first_visit $salt
    } else {
        set salt $cookie_value
    }
    $::middleware::rate_limit_actor send $salt
}
# proc set_cookie {args} {
#     if {![ns_getcookie first_visit 0]} {
# 	ns_setcookie -expires -1 -- first_visit [md5crypt::salt]
#     }
#     return "filter_ok"
# }
# ns_register_filter preauth GET /* set_cookie

set path [ns_server pagedir]
source ${path}/views/wms_page.tcl
source ${path}/views/dsl.tcl
source ${path}/views/components.tcl
source ${path}/views/wms_icons.tcl
source ${path}/views/not_found_page.tcl
# foreach viewfile [glob -nocomplain ${path}/views/*.tcl] {source $viewfile}

ns_register_proc GET "/js/htmx/*" [list ns_returnfile 200 application/javascript "${path}/js/htmx.min.js"]
ns_register_proc GET "/js/datastar/*" [list ns_returnfile 200 application/javascript "${path}/js/datastar-1-0-0-beta-2-987d04d5a076d8bb.js"]

# ns_register_proc GET "/css/*" { ns_returnfile 200 text/css "/home/void/Downloads/code/tcl/hot-glue/mytest/views/wms.css"}
ns_register_proc GET /* root_handler
ns_register_proc POST /* root_handler
ns_register_proc DELETE /* root_handler
