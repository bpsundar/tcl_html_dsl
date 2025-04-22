#### Actor
oo::class create Actor {
    variable mailbox behavior name

    constructor {actorName initialBehavior} {
	set name $actorName
	set behavior $initialBehavior
	set mailbox {}
	my spawn
    }

    method spawn {} {
	coroutine ::$name [self] run
    }

    method run {} {
	while 1 {
	    if {[llength $mailbox] == 0} {
		yield
	    } else {
		set message [lindex $mailbox 0]
		set mailbox [lrange $mailbox 1 end]
		{*}$behavior {*}$message
	    }
	}
    }

    method send {message} {
	lappend mailbox $message
	if {[info coroutine] ne "::$name"} {
	    ::$name
	}
    }

    method become {newBehavior} {
	set behavior $newBehavior
    }
}

#### namespace
##### minesweeper
namespace eval ::minesweeper {
    variable path [ns_server pagedir]
    source ${path}/views/wms_css.tcl
    ##### board
    proc generate_minesweeper_board {rows columns num_mines} {
	# Initialize the board with all cells hidden
	set board {}
	for {set r 1} {$r <= $rows} {incr r} {
	    set row {}
	    for {set c 1} {$c <= $columns} {incr c} {
		lappend row "h" ;# Hidden
	    }
	    dict set board $r $row
	}

	# Place mines randomly
	set mine_positions {}
	while {[llength $mine_positions] < $num_mines} {
	    set r [expr {int(rand() * $rows) + 1}]
	    set c [expr {int(rand() * $columns) + 1}]
	    if {[lsearch $mine_positions "$r,$c"] == -1} {
		lappend mine_positions "$r,$c"
		set row [dict get $board $r]
		lset row [expr {$c - 1}] "m" ;# Mine
		dict set board $r $row
	    }
	}

	# Calculate numbers for each cell
	set numbers {}
	for {set r 1} {$r <= $rows} {incr r} {
	    set row {}
	    for {set c 1} {$c <= $columns} {incr c} {
		if {[lindex [dict get $board $r] [expr {$c - 1}]] == "m"} {
		    lappend row "m"
		    continue
		}
		# Count adjacent mines
		set count 0
		foreach dr {-1 0 1} {
		    foreach dc {-1 0 1} {
			if {$dr == 0 && $dc == 0} { continue }
			set nr [expr {$r + $dr}]
			set nc [expr {$c + $dc}]
			if {$nr < 1 || $nr > $rows || $nc < 1 || $nc > $columns} { continue }
			if {[lindex [dict get $board $nr] [expr {$nc - 1}]] == "m"} {
			    incr count
			}
		    }
		}
		lappend row $count
	    }
	    dict set numbers $r $row
	}

	return [list $board $numbers]
    }
}
##### mytest
namespace eval mytest {
    variable path [ns_server pagedir]
    source ${path}/views/wms_css.tcl

}

##### events
namespace eval events {
    # variable routes [dict create]
    variable eventManager [Actor new coro-todo events::process_events]
  
    proc process_events {url met id cookie} {
	variable session_id $cookie
	switch -glob $url {
	    "/tab/*" {mytest::tab_page $url}
	    "/sse" {
		if {$met eq "GET"} {
		    ::todoapp::sse_handler
		} elseif {$met eq "POST"} {
		    # Get the id from query params
		    ::todoapp::post_handler $id
		} elseif {$met eq "DELETE"} {
		    ::todoapp::delete_handler $id
		}
	    }
	    "/game-start" {minesweeper::game-start ::nss::$session_id}
	    "/clicked" {minesweeper::clicked ::nss::$session_id $id}
	    "/flag" {minesweeper::flagged ::nss::$session_id $id}
	    "/minesweeper" {minesweeper::minesweeper $session_id}
	    "/create-property" {mytest::card_page_2}
	    "/create-lease" {mytest::card_page_3}
	    "/chart" {mytest::rotate}
	    "/todo" {mytest::todo}
	    "/" {mytest::wms_page}
	    default {
		not_found_page
	    }
	}
    }
}

##### middleware
namespace eval middleware {
    variable rate_limit_actor [Actor new coro_rate_limit middleware::browser_tracking_filter]
    proc browser_tracking_filter {cookie} {
	variable url [ns_conn url]
	variable met [ns_conn method]
	variable id [ns_queryget id]
	
	variable count
	dict incr count $cookie
	# puts [dict get $count $cookie]
	if {[dict get $count $cookie] > 500} {
	    #rate limiting logic
	    $::events::eventManager send [list "/404" $met $id $cookie]
	} else {
	    # no worries, go ahead
	    $::events::eventManager send [list $url $met $id $cookie]
	}
    }
}

#### todo
proc mytest::todo {} {
    variable todos
    lassign [scope_css $todos] scoped_css container_class
    
    set todo_app [div [list class $container_class] \
		      [style {} $scoped_css] \
		      [div {class todos data-signals {{todos: '', input: ''}}} \
		      [form {} \
			   [input {type text placeholder {Add Todo} name text data-bind $input} ] \
			   [button {data-on-click {@post('/sse?id=-1', {contentType: 'form'}); $input = '';} data-attr-disabled {$input == ''}} "Add"]] \
		      [button {data-on-click {@get('/sse')}} "Fetch todos"] \
			   [div {id todo}]]]
    
    # ns_return 200 text/html $todo_app
    ns_headers 200 {
	"Content-Type" "text/event-stream"
	"Cache-Control" "no-cache"
	"Connection" "keep-alive"
    }

    # Send the HTML fragment
    ns_write "event: datastar-merge-fragments\n"
    set target [div {id entry} [string map {\n "" "    " ""} $todo_app]]
    ns_write [subst {data: fragments $target}]\n\n

}
 
#### tab
proc mytest::tab_page {url {standalone 1}} {
    if {[lindex [split $url /] end] eq ""} {
	set active_idx 0
    } else {
	set active_idx [lindex [split $url /] end]
    }
    
    variable tab_styles
    variable data [dict create]
    switch $active_idx {
	0 {dict set data content 0 "First tab content"}
	1 {dict set data content 1 [card_page]}
	2 {dict set data content 2 [table_page]}
	3 {dict set data content 3 [contact_page]}
	4 {dict set data content 4 [dropdown_page]}
	5 {dict set data content 5 [pagination_page]}
    }
    dict set data title {0 "Tab One" 1 "Cards" 2 "Table" 3 "Contact" 4 "Dropdown" 5 "Pagination"}
    set template {
	upvar active_idx _idx
	div [list class "tabs"] \
	    [div {class "tab-list" role "tablist"} \
		 {*}[lmap i [dict keys [dict get $_data title]] {
		     button [dict create \
				 hx-get "/tab/$i" \
				 hx-target ".tabs" \
				 hx-trigger "click" \
				 role "tab" \
				 aria-selected [expr {$i == $_idx ? "true" : "false"}] \
				 aria-controls "tab-content" \
				 class [expr {$i == $_idx ? "tab selected" : "tab"}]] \
			 [dict get $_data title $i]
		 }]] \
	    [div {id "tab-content" role "tabpanel" class "tab-panel"} \
		 [dict get $_data content $_idx]]
    }
    # Return content
    if {$standalone eq 1} {
	ns_return 200 text/html [render data tab_styles template]
    } else {
	return [render data tab_styles template]
    }
}

#### card
##### card
proc mytest::card_page {} {
    variable card_styles
    # Create some sample cards using your card proc
    set cards_data [list \
			[dict create \
			     title "Performance" \
			     body "Track your metrics..." \
			     footer [a {href "#"} "View Details"]] \
			[dict create \
			     title "Revenue" \
			     body "Monitor revenue..." \
			     footer [a {href "#"} "View Report"]]
		   ]
    set template {
        div {class "card-grid"} \
	    {*}[lmap card $_data {
		dict with card {}
		article {class "card"} \
		    [h3 {class "card-title"} $title] \
		    [div {class "card-content"} $body] \
		    [expr {$footer ne "" ? 
			   [div {class "card-footer"} $footer] : ""}]
	}]
    }
    return [render cards_data card_styles template]
}
##### card1
proc mytest::card_page_1 {} {
    variable card_1_styles
    # Create some sample cards using your card proc
    set cards_data [list \
			[dict create \
			     title "AMAZON ONLINE" \
			     seller "Eddy Trechnid" \
			     date "May 2021" \
			     amount "€23,040.00" \
			     progress "1.0" \
			     left_to_pay "€23,040.00" \
			     status [list "Notice sent" "Paid" "Receipt sent"]] \
			[dict create \
			     title "Etsy Store" \
			     seller "Jane Doe" \
			     date "June 2021" \
			     amount "€5,600.00" \
			     progress "0.5" \
			     left_to_pay "€2,800.00" \
			     status [list "Notice sent" "Paid"]] \
			[dict create \
			     title "Elite Store" \
			     seller "Jane Doe" \
			     date "June 2022" \
			     amount "€3,600.00" \
			     progress "0.2" \
			     left_to_pay "€1,800.00" \
			     status [list "Notice sent" "Paid"]]]
    set template {
	div {class "card-grid"} \
	    {*}[lmap card $_data {
		dict with card {}
		div {class card} \
		    [div {class "card-header"} \
			 [h3 {class "card-title"} $title] \
			 [span {class "card-seller"} $seller] \
			 [span {class "card-date"} $date] \
			 [div {class "card-amount"} $amount] \
			 [div [list class "progress-bar" style "background: linear-gradient(to right, #ff8c00 [expr {$progress * 100} ]%, white, grey);"]] \
			 [div {class "progress-remaining"} "Left to pay:" \
			      [span {style {text-align: right;}} $left_to_pay]] \
			 [div {} {*}[lmap s $status {
			     div {class "status-item"} \
				 [span {class "status-dot"}] \
				 [span {} $s]
			 }]]]\
		    [div {class "card-buttons"} \
			 [button {class "send"} "SEND EMAIL"] \
			 [button {class "edit"} "EDIT"]
		    ]
	    }]
    }

    return [render cards_data card_1_styles template]
}

##### card2
proc mytest::card_page_2 {} {
    variable form_card_styles
    # Create some sample cards using your card proc
    set cards_data [list \
			[dict create \
			     start_date "01/01/2016" \
			     end_date "12/31/2024" \
			     deposit "10000" \
			     rent "4200" \
			     expense "600" \
			     entry_date "01/01/2016" \
			     exit_date "12/31/2024"]
		    ]
    set template {
        div {class "card-grid"} \
	    {*}[lmap card $_data {
		dict with card {}
		div {} \
		    [div {class "card-tabs"} \
			 [span {class "tab"} "TENANT"] \
			 [span {class "tab active"} "CONTRACT"] \
			 [span {class "tab"} "BILLING"]] \
		    [h3 {class "card-title"} "Lease"] \
		    [form {} \
			 [select {name "lease"} \
			      [option {value "369" selected "selected"} "369"]] \
			 [label {} "Start date"] \
			 [input {type "date" name "start_date" value $start_date}] \
			 [label {} "End date"] \
			 [input {type "date" name "end_date" value $end_date}] \
			 [label {} "Deposit"] \
			 [input {type "text" name "deposit" value $deposit}]] \
		    [h3 {class "card-title"} "Properties"] \
		    [form {} \
			 [select {name "property"} \
			      [option {value "clichy_tour"} "Clichy tour - occupied by current tenant"]] \
			 [label {} "Rent"] \
			 [input {type "text" name "rent" value $rent}] \
			 [label {} "Expense"] \
			 [input {type "text" name "expense" value $expense}] \
			 [label {} "Entry date"] \
			 [input {type "date" name "entry_date" value $entry_date}] \
			 [label {} "Exit date"] \
			 [input {type "date" name "exit_date" value $exit_date}] \
			 [button {class "add-property"} "ADD PROPERTY"]] \
		    [div {class "card-buttons"} \
			 [button {class "save"} "SAVE"]]
	    }]
    }
    ns_return 200 text/html [render cards_data form_card_styles template]
}

##### card3
proc mytest::card_page_3 {} {
    variable card_3_styles
    # Create some sample cards using your card proc
    set cards_data [list \
			[dict create \
			     title "Rental" \
			     total "€5,760.00" \
			     base "€4,200.00" \
			     expenses "€600.00" \
			     discount "€0.00" \
			     pre_tax_total "€4,800.00" \
			     vat "€960.00"]]
    set template {
        div {class "card-grid"} \
	    {*}[lmap card $_data {
		dict with card {}
		div {class "rental-card"} \
		    [h3 {class "card-title"} $title] \
		    [div {class "card-amount"} $total] \
		    [div {class "breakdown"} \
			 [div {class "breakdown-item"} \
			      [span {class "label"} "Base"] \
			      [span {class "amount"} $base]] \
			 [div {class "breakdown-item"} \
			      [span {class "label"} "Expenses"] \
			      [span {class "amount"} $expenses]] \
			 [div {class "breakdown-item"} \
			      [span {class "label"} "Discount"] \
			      [span {class "amount"} $discount]] \
			 [div {class "breakdown-item pre-tax"} \
			      [span {class "label"} "PRE-TAX TOTAL"] \
			      [span {class "amount"} $pre_tax_total]] \
			 [div {class "breakdown-item"} \
			      [span {class "label"} "VAT"] \
			      [span {class "amount"} $vat]] \
			 [div {class "breakdown-item total"} \
			      [span {class "label"} "TOTAL"] \
			      [span {class "amount"} $total]]]
	    }]
    }
    ns_return 200 text/html [render cards_data card_3_styles template]
}

#### table
proc mytest::table_page {} {
    variable table_styles
    dict set data headers [list "Name" "Email" "Status" "Last Active"]
    dict set data rows [list \
		  [list "John Doe" "john@example.com" "Active" "2 hours ago"] \
		  [list "Jane Smith" "jane@example.com" "Away" "1 day ago"] \
		  [list "Bob Wilson" "bob@example.com" "Offline" "1 week ago"] \
		 ]
    set template {
        div [list class "table-container"] \
	    [table {class "table"} \
		 [thead {} \
		      [tr {} \
			   {*}[lmap header [dict get $_data headers] {
			       th {} $header
			   }]]] \
		 [tbody {} \
		      {*}[lmap row [dict get $_data rows] {
			  tr {} \
			      {*}[lmap cell $row {
				  td {} $cell
			      }]
		      }]]]
    }
    return [render data table_styles template]
}

#### contact
proc mytest::contact_page {} {
    variable field_styles
    set fields_data [list \
			 [dict create \
			      id "name" \
			      name "name" \
			      type "text" \
			      label "Your Name" \
			      hint "Enter your full name"] \
			 [dict create \
			      id "email" \
			      name "email" \
			      type "email" \
			      label "Email Address" \
			      hint "We'll never share your email"] \
			 [dict create \
			      id "message" \
			      name "message" \
			      type "textarea" \
			      label "Message" \
			      error "Please enter a message"] \
			]
    set template {
        form {class "form"} \
	    [h2 [list class "form-title"] "Contact Us"] \
	    [p {class "form-description"} "Send us a message and we'll get back to you soon."] \
	    {*}[lmap field $_data {
		dict with field {}
		div {class "form-field"} \
		    [label {class "field-label" for $id} $label] \
		    [input {class "field-input" type $type id $id name $name} ""] \
		    [expr {[info exists hint] ? 
			   [div {class "field-hint"} $hint] : ""}] \
		    [expr {[info exists error] ? 
			   [div {class "field-error"} $error] : ""}]
	    }
	       ] \
	    [button {class "form-submit" type "submit"} "Send Message"]
    }
    return [render fields_data field_styles template]
}

#### Dropdown
proc mytest::dropdown_page {} {
    variable select_styles
    set options_data [dict create \
			  id "status" \
			  name "status" \
			  label "Select Status" \
			  options [list \
				       [dict create value "active" text "Active"] \
				       [dict create value "pending" text "Pending"] \
				       [dict create value "inactive" text "Inactive"] \
				      ]]
    set template {
	dict with _data {}
	div [list class "select-container $container_class"] \
	    [style {} $scoped_css] \
	    [label [list class "select-label" for $id] $label] \
	    [select [list class "select" id $id name $name] \
		 {*}[lmap option $options {
		     dict with option {
			 option [list value $value] $text
		     }
		 }]]
    }
    return [render options_data select_styles template]
}

#### pagination
proc mytest::pagination_page {} {
    variable data [dict create]
    variable table_pa_styles
    
    dict set data rows {{{John Smith} john@example.com Away {2 days ago}} {{John Johnson} john.j@example.com Offline {9 hours ago}} {{Jane Smith} jane@example.com Offline {4 days ago}} {{Jane Johnson} jane.j@example.com Away {16 hours ago}} {{Bob Smith} bob@example.com Away {4 days ago}} {{Bob Johnson} bob.j@example.com Offline {6 hours ago}} {{Alice Smith} alice@example.com Offline {3 days ago}} {{Alice Johnson} alice.j@example.com Offline {10 hours ago}} {{Charlie Smith} charlie@example.com Away {2 days ago}} {{Charlie Johnson} charlie.j@example.com Away {5 hours ago}} {{David Smith} david@example.com Active {2 days ago}} {{David Johnson} david.j@example.com Offline {14 hours ago}} {{Eva Smith} eva@example.com Active {1 days ago}} {{Eva Johnson} eva.j@example.com Offline {9 hours ago}} {{Frank Smith} frank@example.com Active {4 days ago}} {{Frank Johnson} frank.j@example.com Offline {2 hours ago}} {{Grace Smith} grace@example.com Active {2 days ago}} {{Grace Johnson} grace.j@example.com Offline {19 hours ago}} {{Henry Smith} henry@example.com Active {5 days ago}} {{Henry Johnson} henry.j@example.com Away {10 hours ago}}}

    dict set data headers {Name Email Status {Last Active}}
    set page 1  ;# Current page (default to 1)
    set page_size 5  ;# Rows per page

    set template {
	upvar page _page
	upvar page_size _page_size
	table {class "pagination-table"} \
	    [tr {} \
		 {*}[lmap header [dict get $_data headers] {
		     th {} $header
		 }]] \
	    {*}[lmap row [lrange [dict get $_data rows] [expr {($_page - 1) * $_page_size}] [expr {$_page * $_page_size - 1}]] {
		tr {} \
		    {*}[lmap cell $row {
			td {} $cell
		    }]
	    }] \
	    [div {class "pagination-nav"} \
		 [if {$_page > 1} {
		     a [list href "/pagination?page=[expr {$_page - 1}]" rel "prev"] "Previous"
		 }] \
		 [span {} "Page $_page"] \
		 [if {$_page * $_page_size < [llength [dict get $_data rows]]} {
		     a [list href "/pagination?page=[expr {$_page + 1}]" rel "next"] "Next"
		 }]]
    }
    return [render data table_pa_styles template]
}

#### stream
##### ad
proc mytest::ad_page {ad_name} {
    variable ad_styles
    
    set ad_data [list \
		     [dict create \
			  title "Pizza" \
			  subtitle "Yummy" \
			  image "sample.jpeg" \
			  cta_href "www.localshop.in" \
			  cta_text "Shop local"]]

    set template {
	div {} \
     	    {*}[lmap ad $_data {
		h1 {} $ad
	    }]
    }
	
    # set template {
    # 	div {class "ad-container"} \
    # 	    {*}[lmap ad $_data {
    # 		dict with ad {}
    # 		h1 {class "ad-title"} $title \
    # 		    [p {class "ad-subtitle"} $subtitle] \
    # 		    [img [list src "/images/$image" class "ad-image"]] \
    # 		    [p {} [a [list href $cta_href class "ad-cta" rel "deal"] $cta_text]]
    # 	    }]    
    # }
    # # ns_return 200 text/html $todo_app
    return [div {id ad-content} [string map {\n "" "    " ""} [render ad_name ad_styles template]]]
}
proc mytest::stream_ads {} {
    # Fetch ad names once (we'll shuffle later)
    set ad_names [list]
    foreach file [glob -directory "[ns_server pagedir]/assets" sample*.jpeg] {
        lappend ad_names [file tail $file]
    }
    # Initialize idx if not set
    if {![info exists ::mytest::stream_ads_idx]} {
        set ::mytest::stream_ads_idx 0
    }
    # Set SSE headers
    ns_headers 200 {
        "Content-Type" "text/event-stream"
        "Cache-Control" "no-cache"
        "Connection" "keep-alive"
    }
    # Loop to stream ads
    while {[ns_conn isconnected]} {
        set idx [incr ::mytest::stream_ads_idx]
        set ad [lindex $ad_names [expr {($idx - 1) % [llength $ad_names]}]]
        set target [mytest::ad_page $ad]  ;# Call ad_page for one ad
        if {![ns_write "event: datastar-merge-fragments\n"] || ![ns_write [subst {data: fragments $target}]\n\n]} {
	    break
	}
        after 5000  ;# Wait 5 seconds
    }	
}

##### chart
proc mytest::stream_chart {target} {
    ns_headers 200 {
        "Content-Type" "text/event-stream"
        "Cache-Control" "no-cache"
        "Connection" "keep-alive"
    }
    ns_write "event: datastar-merge-fragments\n"
    ns_write [subst {data: fragments $target}]\n\n
}

proc mytest::rotate {} {
    variable card_styles
    set template {
	div {class card-grid} \
	    [svg::pie_chart $_data] \
	    [svg::bar_chart $_data] \
	    [svg::progress_bar [expr {round(rand()*100)}]] \
	}

    # set check 1
    # while {$check} {
	    set rvalue [generate_numbers]
	    
	    dict set sales productA [subst {value [lindex $rvalue 0] color "#FF6B6B"}]
	    dict set sales ProductB [subst {value [lindex $rvalue 1] color "#4ECDC4"}]
	    dict set sales ProductC [subst {value [lindex $rvalue 2] color "#45B7D1"}]
	    dict set sales ProductD [subst {value [lindex $rvalue 3] color "#96CEB4"}]
	    dict set sales ProductE [subst {value [lindex $rvalue 4] color "#FFEEAD"}]
	    
	    # dict set sales1 productA {value 20 color "#FF6B6B"}
	    # dict set sales1 ProductB {value 25 color "#4ECDC4"}
	    # dict set sales1 ProductC {value 5 color "#45B7D1"}
	    # dict set sales1 ProductD {value 20 color "#96CEB4"}
	    # dict set sales1 ProductE {value 30 color "#FFEEAD"}
	    set target [div {id ad-content data-on-load__delay.5s "@get('/chart')" } [string map {\n "" "    " ""} [render sales card_styles template]]]
    # 	    if {![mytest::stream_chart $target]} {
    # 		set check 0
    # 		break
    # 	    }
    # 	    after 3000
    # }
    mytest::stream_chart $target
}
    # set target [div {id ad-content} [div {data-on-load "initChart()"}]]


#### minesweeper
##### logic
proc minesweeper::minesweeper {session_id} {
    variable movie_style
    if {[namespace exists ::nss::$session_id]} {
	namespace delete ::nss::$session_id
    }
    namespace eval ::nss::$session_id {
	variable click_count 0
	variable start_time 0
	variable board [::minesweeper::generate_minesweeper_board 10 10 10]
	variable state_list [lindex $board 0]
	variable numbers_list [lindex $board 1]
    }
    # variable click_count [set ${session_id}::click_count]
    set board [dict create rows 10 columns 10]
    # set state [dict create 1 {0 0 0 1 0 0 x 0 0 0 0 0} 2 {0 0 0 0 0 0 0 0 0 0 0 0}]
    namespace upvar ::nss::$session_id click_count click_count

    set template {
	upvar state _state
	upvar click_count _click_count
	dict with _data {
	    set grid ""
	    for {set r 1} {$r <= $rows} {incr r} {
		set line ""
		for {set c 1} {$c <= $columns} {incr c} {
		    append line [input [subst {
			type checkbox class seat \
			    data-signals-flagged.$r$c 0 data-class-flagged \$flagged.$r$c \
			    data-signals-revealed.$r$c 0 data-class-revealed \$revealed.$r$c \
			    data-class-disabled \$revealed.$r$c \
			    data-signals-gameover 0 data-class-gameover \$gameover \
			    data-signals-value.$r$c "" data-attr-content \$value.$r$c\
			    data-on-contextmenu__prevent {@post('/flag?id=$r$c')} \
			    data-on-click {@post('/clicked?id=$r$c')}}]]
		}
		append grid [div {class rows} $line]
	    }
	}
	div {class main} \
	    [div {class counter} "Your Clicks:" \
		 [span {id click-count} $_click_count] \
		 [div {id clck-strt} [h3 {data-on-click @get('/game-start')} [h3 {} "Time:"]]]
		] \
	    [div [list class container style "--rows: $rows; --columns: $columns;"] $grid] \
	}
    
    ns_headers 200 {
	"Content-Type" "text/event-stream"
	"Cache-Control" "no-cache"
	"Connection" "keep-alive"
    }

    # Send the HTML fragment
    ns_write "event: datastar-merge-fragments\n"
    set target [div {id entry} [string map {\n "" "    " ""} [render board movie_style template]]]
    ns_write [subst {data: fragments $target}]\n\n
}

##### clock
proc minesweeper::game-start {session_id} {
    ns_headers 200 {
	"Content-Type" "text/event-stream"
	"Cache-Control" "no-cache"
	"Connection" "keep-alive"
    }
	# Send the HTML fragment
    minesweeper::sse_send -event fragment [div {id clck-strt data-on-interval__duration.1s.leading @get('/game-start')} "Time:" [clock format [clock seconds] -format "%H:%M:%S"]]
}

##### sse_send
proc minesweeper::sse_send {args} {
    # Parse arguments
    if {[llength $args] < 3 || [lindex $args 0] ne "-event"} {
        error "Usage: sse_send -event <type> <args>"
    }
    set event_type [lindex $args 1]
    set event_args [lrange $args 2 end]
    
    # Set SSE headers
    ns_headers 200 {
        "Content-Type" "text/event-stream"
        "Cache-Control" "no-cache"
        "Connection" "keep-alive"
    }
    
    switch -- $event_type {
        "fragment" {
            # Expect: sse_send -event fragment <html_fragment>
            set target [lindex $event_args 0]
            ns_write "event: datastar-merge-fragments\n"
            ns_write [subst {data: fragments $target}]\n\n
        }
        "signal" {
            # Expect: sse_send -event signal <key1> <value1> <key2> <value2> ...
            # or sse_send -event signal <preformatted_signal_string>
            set signals {}
            if {[llength $event_args] == 1} {
                # Preformatted signal string (e.g., "revealed: {33: true, 34: true}, value: {33: \"0\", 34: \"1\"}")
                set signals [lindex $event_args 0]
            } else {
                # Key-value pairs (e.g., revealed.33 true value.33 "\"0\"")
                set pairs {}
                foreach {k v} $event_args {
                    lappend pairs "$k: $v"
                }
                set signals [join $pairs ", "]
            }
            ns_write "event: datastar-merge-signals\n"
            ns_write [subst {data: signals {$signals}}]\n\n
        }
        default {
            error "Unknown event type: $event_type (expected 'fragment' or 'signal')"
        }
    }
}
    
##### flagged
proc minesweeper::flagged {session_id args} {
    package require json
    
    namespace upvar $session_id state_list state_list 
    namespace upvar $session_id numbers_list numbers_list

    set r [expr {$args / 10}]
    set c [expr {$args % 10}]
    if {$r > 10} {
	set r [expr {$r / 10}]
	set c 10
    }
    if {$c == 0} {
        set r [expr {$r - 1}]
        set c 10
    }
    set flag [dict get [::json::json2dict [ns_conn content]] flagged $args]
    set row [dict get $state_list $r]
    if {[expr !$flag]} {
	lset row [expr {$c - 1}] "f"
    } else {
	lset row [expr {$c - 1}] "h"
    }
    dict set state_list $r $row
    minesweeper::win $session_id $flag $args
}

##### victory
proc minesweeper::win {session_id flag args} {
    namespace upvar $session_id click_count click_count
    namespace upvar $session_id state_list state_list 
    namespace upvar $session_id numbers_list numbers_list
    namespace upvar $session_id start_time start_time
    
    # Check win condition
    set mine_count 0
    set correctly_flagged 0
    foreach row [dict keys $numbers_list] {
        set numbers_row [dict get $numbers_list $row]
        set state_row [dict get $state_list $row]
        foreach number $numbers_row state $state_row {
            if {$number eq "m"} {
                incr mine_count
                if {$state eq "f"} {
                    incr correctly_flagged
                }
            }
        }
    }
    
    # Win condition: all mines are flagged, and no non-mine cells are flagged
    if {$mine_count == $correctly_flagged} {
	set stop_time [clock seconds]
	set game_stop [expr {$stop_time - $start_time}]
	set target [span {id click-count} $click_count]
	minesweeper::sse_send -event fragment $target
	
	foreach {k v} $numbers_list {
	    set i 1           
	    foreach n $v {
		if {[string is integer $n]} {
		    if {$n eq "0"} {
			append v_result "$k$i: \"\", "
		    } else {
			append v_result "$k$i: \"$n\", "
		    }
		} else {
		    append v_result "$k$i: \"💥\", "
		}
		append r_result "$k$i: true, "
		incr i
	    }
	}
	
	minesweeper::sse_send -event fragment [div {id clck-strt} "You won in $game_stop secs" \
						   [button {data-on-click @get('/minesweeper')} "Again?"]]
	minesweeper::sse_send -event signal [subst {value: {$v_result}, revealed: {$r_result}, gameover: "true"}]
    } else {
	minesweeper::sse_send -event signal [subst {flagged: {$args: [expr !$flag]}}]
    }
}

##### clicked
proc minesweeper::clicked {session_id args} {
    namespace upvar $session_id click_count click_count
    namespace upvar $session_id state_list state_list 
    namespace upvar $session_id numbers_list numbers_list
    namespace upvar $session_id start_time start_time
    
    if {$click_count == 0} {
	variable ${session_id}::start_time [clock seconds]
    }
    
    set r [expr {$args / 10}]
    set c [expr {$args % 10}]
    if {$r > 10} {
	set r [expr {$r / 10}]
	set c 10
    }
    if {$c == 0} {
        set r [expr {$r - 1}]
        set c 10
    }
    set state [lindex [dict get $state_list $r] [expr {$c - 1}]]
    set number [lindex [dict get $numbers_list $r] [expr {$c - 1}]]
    
    if {$state eq "m"} {
	set stop_time [clock seconds]
	set game_stop [expr {$stop_time - $start_time}]
	set target [span {id click-count} $click_count]
	minesweeper::sse_send -event fragment $target
	
	foreach {k v} $numbers_list {
	    set i 1           
	    foreach n $v {         
		if {$n eq "0"} {
		    append v_result "$k$i: \"\", "
		} else {
		    append v_result "$k$i: \"$n\", "
		}
		append r_result "$k$i: true, "
		incr i
	    }
	}
	minesweeper::sse_send -event fragment [div {id clck-strt} "You lost in $game_stop secs" \
						   [button {data-on-click @get('/minesweeper')} "Again?"]]
	# minesweeper::sse_send -event fragment [div {id clck-strt} $game_stop]
	minesweeper::sse_send -event signal [subst {value: {$v_result}, revealed: {$r_result}, gameover: "true"}]
	return
    }
    
    set row [dict get $state_list $r]
    lset row [expr {$c - 1}] $number
    dict set state_list $r $row
    
    if {$number eq "0"} {
	set stack [list [list $r $c]]
	set visited [dict create]
	
	while {[llength $stack] > 0} {
	    set cell [lindex $stack end]
	    set stack [lrange $stack 0 end-1]
	    set r [lindex $cell 0]
	    set c [lindex $cell 1]
	    if {[dict exists $visited "$r,$c"]} {
		continue
	    }
	    dict set visited "$r,$c" 1

	    foreach dr {-1 0 1} {
		set new_r [expr {$r + $dr}]
		if {$new_r < 1 || $new_r > 10} {
		    continue
		} 
		foreach dc {-1 0 1} {
		    if {$dr == 0 && $dc == 0} {
			continue
		    }
		    set new_c [expr {$c + $dc}]
		    if {$new_c < 1 || $new_c > 10} {
			continue
		    }
		    set new_c_idx [expr {$new_c - 1}]
		    set neighbor_row [dict get $state_list $new_r]
		    set neighbor_state [lindex $neighbor_row $new_c_idx]
		    if {$neighbor_state eq "h"} {
			set number_row [dict get $numbers_list $new_r]
			set new_n [lindex $number_row $new_c_idx]
			if {$new_n eq "0"} {
			    lappend stack [list $new_r $new_c]
			}
			if {$new_n ne "m"} {
			    lset neighbor_row $new_c_idx $new_n
			    dict set state_list $new_r $neighbor_row
			}
		    }
		}
	    }
	}
	
	foreach {k v} $state_list {
	    set i 1           
	    foreach n $v {
		if {[string is integer $n]} {
		    if {$n eq "0"} {
			append v_result "$k$i: \"\", "
		    } else {
			append v_result "$k$i: \"$n\", "
		    }
		    append r_result "$k$i: true, "
		}
		incr i
	    }
	}
	minesweeper::sse_send -event fragment [span {id click-count} [string map {\n "" "    " ""} [incr click_count]]]
	minesweeper::sse_send -event signal [subst {revealed: {$r_result}, value: {$v_result}}]
	minesweeper::sse_send -event fragment [div {id clck-strt data-on-load @get('/game-start')} "Time:" [clock format [clock seconds] -format "%H:%M:%S"]]
	return
    }
    minesweeper::sse_send -event fragment [span {id click-count} [string map {\n "" "    " ""} [incr click_count]]]
    minesweeper::sse_send -event fragment [div {id clck-strt data-on-load @get('/game-start')} "Time:" [clock format [clock seconds] -format "%H:%M:%S"]]
    minesweeper::sse_send -event signal [subst {revealed: {$args: true}, value: {$args: "$number"}}]
}
    

#### wms
proc mytest::wms_page {} {
    variable tab_styles
    variable base_styles
    variable dashboard_styles
    
    set nav_menu [nav {class "nav-menu"} \
		      [a {class "nav-link active"} "[Icon overview] Overview"] \
		      [a {class "nav-link" data-on-click @get('/minesweeper')} "[Icon create-order] MineSweeper"] \
		      [a {class "nav-link" data-on-click @get('/todo')} "[Icon create-lpn] Create Todo"] \
		      [a {class "nav-link" hx-get "/create-property" hx-swap "innerHTML" hx-target "#entry"} "[Icon create-bin] Create Property"] \
		      [a {class "nav-link" hx-get "/create-lease" hx-swap "innerHTML" hx-target "#entry"} "[Icon create-order] Create Lease"] \
		     ]
    # Build the sidebar
    set sidebar [aside {class "sidebar"} \
		     [h2 {class "sidebar-title"} "Dashboard"] \
		     $nav_menu \
		    ]
    
    # Build the main content area
    set content [main {class "content"} \
		     [header {class "content-header"} \
			  [div {id entry} \
			       [h1 {} "Thank You"] \
			       [div {} \
				    [p {} [subst {Thanks goes to these people for being the fork in my road, \
						      [div {} "<br\>Mark Tarver [a {href https://shenlanguage.org} (Shen-Language)]. " \
							   [span {} "Reading his Book of Shen is when I first heard about Tcl."]] \
						      [div {} "Karl Lehenbauer (FlightAware)."] \
						      [div {} "And all the [a {href https://www.tcl-lang.org/} Tcl] community folks."] \
						      [div {} "Ashok P. Nadkarni for [a {href https://www.magicsplat.com/ttpl/index.html} {Tcl9 book}] ."] \
						      [div {}  "The good folks at the [a {href https://hn.algolia.com/?q=tcl} Orange-site] without their perspective it would have been hard to stick with Tcl."] \
						      [div {} "<br\>And all errors are mine only, for it reflects my current understanding of the concepts. <br\>Help me to imporve or just say \"Hi\" on my X handle [a {href https://x.com/sundarbp} {Beerana P Sundar}] or [a {href https://github.com/bpsundar} Github]"]  \
						  }]] \
				   ]]]]
    # [div {id ad-content data-on-interval__duration.3s "@get('/chart')"}] \
	# [div {id ad-content} [tab_page [ns_conn url] 0]] \
	# [div {} [canvas {id myChart}]] \
	# [div {} [card_page_2]] \
	# [div {} [card_page_3]] \

    # Build the dashboard layout
    set body [div {id main class "dashboard"} \
		  $sidebar \
		  $content \
		 ]

    # Combine all styles
    set all_styles [style {} "$base_styles $dashboard_styles"]
    
    # Build the complete page
    set header [head {} \
		    [meta {charset "UTF-8"}] \
		    [meta {name "viewport" content "width=device-width, initial-scale=1"}] \
		    [title {} "Dashboard"] \
		    $all_styles \
		    [script {src /js/htmx/htmx.min.js} ""] \
		    [script {type module src "/js/datastar/datastar-1-0-0-beta-2-987d04d5a076d8bb.js"}] \
		   ]

    proc render_html {header body} {
	set doctype "<!DOCTYPE html>\n"
	set html_content [html {} $header $body]
	return "$doctype$html_content"
    }

    # Return complete HTML
    ns_return 200 text/html [render_html $header $body]
}
# [script {src "https://cdn.jsdelivr.net/npm/chart.js"}]

#### sse
##### old
# set sse [div {} \
# 	     [input {data-bind input} ""] \
# 	     [div {data-text $input} "I will be replaced with the contents of the input signal"] \
# 	    ]

# set quiz_section [div {data-signals {{response: '', answer: ''}} \
# 			   data-computed-correct {$response.toLowerCase() == $answer}} \
# 		      [div {id question} ""] \
# 		      [button {data-on-click {@get('/sse')}} "Fetch a question"] \
# 		      [button {data-show {$answer != ''} \
# 				   data-on-click {$response = prompt('Answer:') ?? ''}} "BUZZ"] \
# 		      [div {data-show {$response != ''}} \
# 			   [div {} "You answered  \
# 				    [span {data-text $response}]." \
# 				[span {data-show $correct} " That is correct ✅"] \
# 				[span {data-show {!$correct}} " The correct answer is  \
# 					 [span {data-text $answer}] 🤷" ]]]]

# proc sse_handler {} {
#     ns_headers 200 {
#         "Content-Type" "text/event-stream"
#         "Cache-Control" "no-cache"
#         "Connection" "keep-alive"
#     }
    
#     # Example of sending an event
#     ns_write "event: datastar-merge-fragments\n"
#     set html_update [subst {data: fragments [div {id question} "What is '2+2'?"]}]
#     ns_write "$html_update\n\n"

#     ns_write "event: datastar-merge-signals\n"
#     set signals_update [list data: signals {answer: '4'}]
#     ns_write "$signals_update\n\n"
# }

# proc sse_handler {} {
#     ns_headers 200 {
#         "Content-Type" "text/event-stream"
#         "Cache-Control" "no-cache"
#         "Connection" "keep-alive"
#     }

#     # First question
#     ns_write "event: datastar-merge-fragments\n"
#     set html_update [subst {data: fragments [div {id question} "What is 2+2?"]}]
#     ns_write "$html_update\n\n"
#     ns_write "event: datastar-merge-signals\n"
#     ns_write "data: signals {answer: '4'}\n\n"
    
#     ns_write "event: datastar-merge-fragments\n"
#     set html_update [subst {data: fragments [div {id question} "What is the capital of France?"]}]
#     ns_write "$html_update\n\n"
#     ns_write "event: datastar-merge-signals\n"
#     ns_write "data: signals {answer: 'Paris'}\n\n"
    
#     ns_write "event: datastar-merge-fragments\n"
#     set html_update [subst {data: fragments [div {id question} "What do you put in a toaster?"]}]
#     ns_write "$html_update\n\n"
#     ns_write "event: datastar-merge-signals\n"
#     ns_write "data: signals {answer: 'bread'}\n\n"
# }
# Get the current todos from some storage
# set todos {[
# 		{"id": 1, "text": "Learn Tcl", "completed": false},
# 		{"id": 2, "text": "Build a todo app", "completed": true}
# 	       ]}
# set todos [string map {\n "" "    " ""} $todos]

# #Update the signals with todo data
# ns_write "event: datastar-merge-signals\n"
# ns_write "data: signals \{todos: '$todos'\}\n\n"

##### current
# Our static todos with their current state
namespace eval ::todoapp {
    variable todos {
	1 {text "Learn Tcl" completed false}
	2 {text "Build a Todo app" completed true}
    }

    proc render_todos {} {
	variable todos
	# Build HTML fragment
	set html_fragment ""
	foreach {key value} $todos {
	    dict with value {
		set checked [expr {$completed ? "checked" : ""}]
		# set checkbox [expr {$completed ? "☑" : "☐"}]
		set text_class [expr {$completed ? "style=\"text-decoration: line-through;\"" : ""}]

		append html_fragment [div [list class "todo-container"] \
					  [subst {<li class="group">
					      <label data-on-click="@post('/sse?id=$key')">
					      <input type="checkbox" $checked>
					      </label>
					      <span $text_class>$text</span>
					      <button class="invisible visible" data-on-click="@delete('/sse?id=$key')">[Icon delete]</button>
					      </li>}]]
		}
	    }
	return [div {id todo} [string map {\n "" "    " ""} $html_fragment]] 
    }

    proc sse_handler {} {
	ns_headers 200 {
	    "Content-Type" "text/event-stream"
	    "Cache-Control" "no-cache"
	    "Connection" "keep-alive"
	}

	# Send the HTML fragment
	ns_write "event: datastar-merge-fragments\n"
	ns_write [subst {data: fragments [render_todos]}]\n\n
    }

    proc post_handler {idx} {
	variable todos
	if {$idx < 0} {
	    set new_id [expr {[llength [dict keys $todos]] + 1}]
	    dict set todos $new_id [dict create text [ns_set get [ns_conn form] text] completed false]
	} else {
	    # Find and toggle the matched todo
	    set mod [dict get $todos $idx completed]
	    dict set todos $idx completed [expr {!$mod}]
	}
	
	ns_headers 200 {
	    "Content-Type" "text/event-stream"
	    "Cache-Control" "no-cache"
	    "Connection" "keep-alive"
	}

	# Send the HTML fragment
	ns_write "event: datastar-merge-fragments\n"
	ns_write [subst {data: fragments [render_todos]}]\n\n
    }

    proc delete_handler {idx} {
	variable todos
	dict unset todos $idx
	ns_headers 200 {
	    "Content-Type" "text/event-stream"
	    "Cache-Control" "no-cache"
	    "Connection" "keep-alive"
	}

	# Send the HTML fragment
	ns_write "event: datastar-merge-fragments\n"
	ns_write [subst {data: fragments [render_todos]}]\n\n
    }
}


#### test
