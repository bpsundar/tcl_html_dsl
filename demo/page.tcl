#### namespace
namespace eval mytest {
    variable path [ns_server pagedir]
    source ${path}/views/wms_css.tcl
}

#### todo
proc todo {} {
    set todo_app [div {data-signals {{todos: '', input: ''}}} \
		      [form {} \
			   [input {type text placeholder {Add Todo} name text data-bind $input} ] \
			   [button {data-on-click {@post('/sse?id=-1', {contentType: 'form'}); $input = '';} data-attr-disabled {$input == ''}} "Add"]] \
		      [button {data-on-click {@get('/sse')}} "Fetch todos"] \
		      [div {id todo}]]
    # ns_return 200 text/html $todo_app
    ns_headers 200 {
	"Content-Type" "text/event-stream"
	"Cache-Control" "no-cache"
	"Connection" "keep-alive"
    }

    # Send the HTML fragment
    ns_write "event: datastar-merge-fragments\n"
    set target [div {id page-content} [string map {\n "" "    " ""} $todo_app]]
    ns_write [subst {data: fragments $target}]\n\n

}
 
#### tab
proc mytest::tab_page {idx} {
        variable tab_styles
	switch $idx {
	    0 {set content "First tab content"}
	    1 {set content [card_page]}
	    2 {set content [table_page]}
	    3 {set content [contact_page]}
	    4 {set content [dropdown_page]}
	    5 {set content [pagination_page]}
	    default {set content "Default Content"}
	}
	set tabs_dict [list \
			   [list title "Tab One" content $content] \
			   [list title "Cards" content $content] \
			   [list title "Table" content $content] \
			   [list title "Contact" content $content] \
			   [list title "Dropdown" content $content] \
			   [list title "Pagination" content $content] \
			  ]
	set tabs [div {} \
		      [style {} $tab_styles] \
		      [Tabs $tabs_dict $idx] \
		     ]

	# Return content
	ns_return 200 text/html $tabs
    }


#### card
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
    return [render_cards $card_styles $cards_data]
}

#### table
proc mytest::table_page {} {
    variable table_styles
    set headers [list "Name" "Email" "Status" "Last Active"]
    set rows [list \
		  [list "John Doe" "john@example.com" "Active" "2 hours ago"] \
		  [list "Jane Smith" "jane@example.com" "Away" "1 day ago"] \
		  [list "Bob Wilson" "bob@example.com" "Offline" "1 week ago"] \
		 ]
    return [render_table $table_styles $headers $rows]
}

#### contact
proc mytest::contact_page {} {
    variable field_styles
    variable form_styles
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

    return [render_form $field_styles $form_styles $fields_data]
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
    return [render_select $select_styles $options_data]
}

#### pagination
proc mytest::pagination_page {} {
    variable table_pa_styles
    set pa_rows {{{John Smith} john@example.com Away {2 days ago}} {{John Johnson} john.j@example.com Offline {9 hours ago}} {{Jane Smith} jane@example.com Offline {4 days ago}} {{Jane Johnson} jane.j@example.com Away {16 hours ago}} {{Bob Smith} bob@example.com Away {4 days ago}} {{Bob Johnson} bob.j@example.com Offline {6 hours ago}} {{Alice Smith} alice@example.com Offline {3 days ago}} {{Alice Johnson} alice.j@example.com Offline {10 hours ago}} {{Charlie Smith} charlie@example.com Away {2 days ago}} {{Charlie Johnson} charlie.j@example.com Away {5 hours ago}} {{David Smith} david@example.com Active {2 days ago}} {{David Johnson} david.j@example.com Offline {14 hours ago}} {{Eva Smith} eva@example.com Active {1 days ago}} {{Eva Johnson} eva.j@example.com Offline {9 hours ago}} {{Frank Smith} frank@example.com Active {4 days ago}} {{Frank Johnson} frank.j@example.com Offline {2 hours ago}} {{Grace Smith} grace@example.com Active {2 days ago}} {{Grace Johnson} grace.j@example.com Offline {19 hours ago}} {{Henry Smith} henry@example.com Active {5 days ago}} {{Henry Johnson} henry.j@example.com Away {10 hours ago}}}

    set pa_headers {Name Email Status {Last Active}}
    return [render_pa_table $table_pa_styles $pa_headers $pa_rows 1 5]
}

#### wms
proc mytest::wms_page {} {
    variable tab_styles
    variable base_styles
    variable dashboard_styles
    
    set nav_menu [nav {class "nav-menu"} \
		      [a {class "nav-link active" hx-get "/tab/0" hx-target "#page-content"} "[Icon overview] Overview"] \
		      [a {class "nav-link" data-on-click @get('/todo')} "[Icon create-lpn] Create Todo"] \
		      [a {class "nav-link" hx-get "/create-bin" hx-target "#page-content"} "[Icon create-bin] Create BIN"] \
		      [a {class "nav-link" hx-get "/create-order" hx-target "#page-content"} "[Icon create-order] Create Order"] \
		     ]
    # Build the sidebar
    set sidebar [aside {class "sidebar"} \
		     [h2 {class "sidebar-title"} "WMS Dashboard"] \
		     $nav_menu \
		    ]

    set tabs_dict [list \
		       [list title "Tab One" content "First tab content"] \
		       {title "Cards" content "Second tab content"} \
		       {title "Table" content "Third tab content"} \
		       {title "Contact" content "Fourth tab content"} \
		       {title "Dropdown" content "Fifth tab content"} \
		       {title "Pagination" content "Sixth tab content"} \
		      ]
    set tabs [div {} \
		  [style {} $tab_styles] \
		  [Tabs $tabs_dict] \
		 ]
    
    # Build the main content area
    set content [main {class "content"} \
		     [header {class "content-header"} \
			  [h1 {} "Overview"] \
			 ] \
		     [div {id page-content} $tabs] \
		    ]

    # Build the dashboard layout
    set body [div {class "dashboard"} \
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

#### sse
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

		append html_fragment [div {class todo-container} \
					  {<style> 
					      .icon {width: 16px; height: 16px;}
					      .invisible { display: none; }
					      .group:hover .visible { display: block; margin-left: auto; }
					      .todo-container {
						  max-width: 400px;
					      }
					      .group {
						  display: flex;
						  align-items: center;
						  gap: 2rem;
						  flex-direction: row;
					      }
					      </style>
					  } \
					  [subst {<li class="group">
					      <label data-on-click="@post('/sse?id=$key')">
					      <input type="checkbox" $checked>
					      </label>
					      <span $text_class>$text</span>
					      <button class="invisible visible" data-on-click="@delete('/sse?id=$key')">[Icon delete]</button>
					      </li>}]]
		}
	    }
	return $html_fragment
    }

    proc sse_handler {} {
	ns_headers 200 {
	    "Content-Type" "text/event-stream"
	    "Cache-Control" "no-cache"
	    "Connection" "keep-alive"
	}

	# Send the HTML fragment
	ns_write "event: datastar-merge-fragments\n"
	set target [div {id todo} [string map {\n "" "    " ""} [render_todos]]]
	ns_write [subst {data: fragments $target}]\n\n
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
	set target [div {id todo} [string map {\n "" "    " ""} [render_todos]]]
	ns_write [subst {data: fragments $target}]\n\n
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
	set target [div {id todo} [string map {\n "" "    " ""} [render_todos]]]
	ns_write [subst {data: fragments $target}]\n\n
    }
}
