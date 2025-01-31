
#### tab
proc tab_page {idx} {
    set tabs_dict [list \
		       [list title "Tab One" content "First tab content"] \
		       [list title "Cards" content [eval card_page]] \
		       [list title "Table" content [eval table_page]] \
		       [list title "Contact" content [eval contact_page]] \
		       [list title "Dropdown" content [eval dropdown_page]] \
		       [list title "Pagination" content [eval pagination_page]] \
		      ]
    # Return content
    ns_return 200 text/html [Tabs $tabs_dict $idx]
}

#### card
proc card_page {} {
    set path [ns_server pagedir]
    source ${path}/views/wms_css.tcl
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
proc table_page {} {
    set path [ns_server pagedir]
    source ${path}/views/wms_css.tcl
    set headers [list "Name" "Email" "Status" "Last Active"]
    set rows [list \
		  [list "John Doe" "john@example.com" "Active" "2 hours ago"] \
		  [list "Jane Smith" "jane@example.com" "Away" "1 day ago"] \
		  [list "Bob Wilson" "bob@example.com" "Offline" "1 week ago"] \
		 ]
    return [render_table $table_styles $headers $rows]
}

#### contact
proc contact_page {} {
    set path [ns_server pagedir]
    source ${path}/views/wms_css.tcl
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
proc dropdown_page {} {
    set path [ns_server pagedir]
    source ${path}/views/wms_css.tcl
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
proc pagination_page {} {
    set path [ns_server pagedir]
    source ${path}/views/wms_css.tcl
    set pa_rows {{{John Smith} john@example.com Away {2 days ago}} {{John Johnson} john.j@example.com Offline {9 hours ago}} {{Jane Smith} jane@example.com Offline {4 days ago}} {{Jane Johnson} jane.j@example.com Away {16 hours ago}} {{Bob Smith} bob@example.com Away {4 days ago}} {{Bob Johnson} bob.j@example.com Offline {6 hours ago}} {{Alice Smith} alice@example.com Offline {3 days ago}} {{Alice Johnson} alice.j@example.com Offline {10 hours ago}} {{Charlie Smith} charlie@example.com Away {2 days ago}} {{Charlie Johnson} charlie.j@example.com Away {5 hours ago}} {{David Smith} david@example.com Active {2 days ago}} {{David Johnson} david.j@example.com Offline {14 hours ago}} {{Eva Smith} eva@example.com Active {1 days ago}} {{Eva Johnson} eva.j@example.com Offline {9 hours ago}} {{Frank Smith} frank@example.com Active {4 days ago}} {{Frank Johnson} frank.j@example.com Offline {2 hours ago}} {{Grace Smith} grace@example.com Active {2 days ago}} {{Grace Johnson} grace.j@example.com Offline {19 hours ago}} {{Henry Smith} henry@example.com Active {5 days ago}} {{Henry Johnson} henry.j@example.com Away {10 hours ago}}}

    set pa_headers {Name Email Status {Last Active}}
    return [render_pa_table $table_pa_styles $pa_headers $pa_rows 1 5]
}

#### wms
proc wms_page {} {
    set path [ns_server pagedir]
    source ${path}/views/wms_css.tcl
    
    set nav_menu [nav {class "nav-menu"} \
		      [a {class "nav-link active" href "#" hx-get "/card" hx-target "#page-content"} "[Icon overview] Overview"] \
		      [a {class "nav-link" href "#" hx-get "/create-lpn" hx-target "#page-content"} "[Icon create-lpn] Create LPN"] \
		      [a {class "nav-link" href "#" hx-get "/create-bin" hx-target "#page-content"} "[Icon create-bin] Create BIN"] \
		      [a {class "nav-link" href "#" hx-get "/create-order" hx-target "#page-content"} "[Icon create-order] Create Order"] \
		     ]
    # Build the sidebar
    set sidebar [aside {class "sidebar"} \
		     [h2 {class "sidebar-title"} "WMS Dashboard"] \
		     $nav_menu \
		    ]

    set tabs_dict [list \
		       {title "Tab One" content "First tab content"} \
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
		     $tabs \
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
		    [script {src "/js/htmx.min.js"} ""]
		# [script {src "/js/datastar-1-0-0-beta-2-987d04d5a076d8bb.js"} ""]
		   ]

    proc render_html {header body} {
	set doctype "<!DOCTYPE html>\n"
	set html_content [html {} $header $body]
	return "$doctype$html_content"
    }

    # Return complete HTML
    ns_return 200 text/html [render_html $header $body]
}
