#### form
proc form_field {field_data} {
    dict with field_data {}
    div {class "form-field"} \
        [label {class "field-label" for $id} $label] \
        [input {class "field-input" type $type id $id name $name} ""] \
        [expr {[info exists hint] ? 
            [div {class "field-hint"} $hint] : ""}] \
        [expr {[info exists error] ? 
            [div {class "field-error"} $error] : ""}]
}

proc render_form {field_styles form_styles fields_data} {
    form {class "form"} \
        [style {} $field_styles] \
        [style {} $form_styles] \
        [h2 {class "form-title"} "Contact Us"] \
        [p {class "form-description"} "Send us a message and we'll get back to you soon."] \
        {*}[lmap field $fields_data {
            form_field $field
        }] \
        [button {class "form-submit" type "submit"} "Send Message"]
}

#### card
# proc card {css attributes content} {
#     # Extract title, body, and footer from content dictionary
#     set title [dict get $content title]
#     set body [dict get $content body]
#     set footer [dict get $content footer]
    
#     # Create the card structure
#     return [article {class $attributes} \
#         [style {} $css] \
#         [h3 {class "card-title"} $title] \
# 		[div {class "card-content"} $body] \
# 		[expr {$footer ne "" ? [div {class "card-footer"} $footer] : ""}] \
#     ]
# }

proc render_cards {css cards_data} {
    # Single wrapper div with the shared styles
    div {class "card-grid"} \
	[style {} {
	    .card-grid {
		display: grid;
		grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
		gap: 2rem;
		padding: 2rem;
	    }
	}] \
        [style {} $css] \
        {*}[lmap card $cards_data {
	    dict with card {}
	    article {class "card"} \
                [h3 {class "card-title"} $title] \
                [div {class "card-content"} $body] \
		[expr {$footer ne "" ?
		       [div {class "card-footer"} $footer] : ""}]
        }]
}

#### table
proc render_table {table_styles headers rows} {
    div {class "table-container"} \
        [style {} $table_styles] \
        [table {class "table"} \
            [thead {} \
                [tr {} \
                    {*}[lmap header $headers {
                        th {} $header
                    }]]] \
            [tbody {} \
                {*}[lmap row $rows {
                    tr {} \
                        {*}[lmap cell $row {
                            td {} $cell
                        }]
                }]]]
}

#### select
proc render_select {select_styles options_data} {
    dict with options_data {}
    div {class "select-container"} \
        [style {} $select_styles] \
        [label [list class "select-label" for $id] $label] \
        [select [list class "select" id $id name $name] \
            {*}[lmap option $options {
                dict with option {
                    option [list value $value] $text
                }
            }]]
}

#### pagination

# Helper proc to generate page numbers list
proc generate_page_numbers {current_page total_pages {window 2}} {
    set pages [list]
    
    # Always show first page
    lappend pages 1
    
    # Calculate window around current page
    set start [expr {max(2, $current_page - $window)}]
    set end [expr {min($total_pages - 1, $current_page + $window)}]
    
    # Add ellipsis after 1 if needed
    if {$start > 2} {
        lappend pages "..."
    }
    
    # Add pages within window
    for {set i $start} {$i <= $end} {incr i} {
        lappend pages $i
    }
    
    # Add ellipsis before last page if needed
    if {$end < ($total_pages - 1)} {
        lappend pages "..."
    }
    
    # Always show last page if there is more than one page
    if {$total_pages > 1} {
        lappend pages $total_pages
    }
    
    return $pages
}

proc render_pagination_controls {current_page total_pages} {
    set controls [list]
    
    # Previous button
    set prev_disabled [expr {$current_page == 1}]
    set prev_class [expr {$prev_disabled ? "disabled" : ""}]
    lappend controls [button [list class "pagination-btn $prev_class" data-page [expr {$current_page - 1}]] "Previous"]
    
    # Page numbers
    set page_numbers [generate_page_numbers $current_page $total_pages]
    foreach page $page_numbers {
        if {$page eq "..."} {
            lappend controls [span {class "pagination-ellipsis"} "..."]
        } else {
            set active_class [expr {$page == $current_page ? "active" : ""}]
            lappend controls [button [list class "pagination-btn $active_class" data-page $page] $page]
        }
    }
    
    # Next button
    set next_disabled [expr {$current_page == $total_pages}]
    set next_class [expr {$next_disabled ? "disabled" : ""}]
    lappend controls [button [list class "pagination-btn $next_class" data-page [expr {$current_page + 1}]] "Next"]
    
    return [div {class "pagination-controls"} {*}$controls]
}

proc render_pa_table {table_styles headers rows {page 1} {per_page 10}} {
    # Calculate pagination metadata
    set total_rows [llength $rows]
    set total_pages [expr {ceil(double($total_rows) / $per_page)}]
    set start_idx [expr {($page - 1) * $per_page}]
    set end_idx [expr {min($start_idx + $per_page, $total_rows)}]
    
    # Slice the rows for current page
    set page_rows [lrange $rows $start_idx [expr {$end_idx - 1}]]
    
    # Render the table container with metadata
    div {class "table-container"} \
        [style {} $table_styles] \
        [div {class "table-info"} \
            "Showing [expr {$start_idx + 1}] to $end_idx of $total_rows entries"] \
        [table {class "table"} \
            [thead {} \
                [tr {} \
                    {*}[lmap header $headers {
                        th {} $header
                    }]]] \
            [tbody {} \
                {*}[lmap row $page_rows {
                    tr {} \
                        {*}[lmap cell $row {
                            td {} $cell
                        }]
                }]]] \
        [render_pagination_controls $page $total_pages]
}

#### tabs
proc Tabs {tabs {active_idx 0}} {
    div {class "tabs"} \
        [div {class "tab-list" role "tablist"} \
            {*}[lmap i $tabs {
                set idx [lsearch $tabs $i]
                button [dict create \
                    hx-get "/tab/$idx" \
                    hx-target ".tabs" \
                    hx-trigger "click" \
                    role "tab" \
                    aria-selected [expr {$idx == $active_idx ? "true" : "false"}] \
                    aria-controls "tab-content" \
                    class [expr {$idx == $active_idx ? "tab selected" : "tab"}]] \
                    [dict get $i title]
            }]] \
        [div {id "tab-content" role "tabpanel" class "tab-panel"} \
            [dict get [lindex $tabs $active_idx] content]]
}

# <div class="tabs">
# <div class="tab-list">
# <button hx-get="/tab/0" hx-target="#tab-content" class="tab active">Tab One</button>
# <button hx-get="/tab/1" hx-target="#tab-content" class="tab">Tab Two</button>
# </div>
# <div id="tab-content" class="tab-panel">First tab content</div>
# </div>
