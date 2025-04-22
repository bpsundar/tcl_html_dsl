#### scoped css
proc scope_css {css} {
    set unique_id [clock microsecond]
    set scoped_css {}
    set container_class "card-grid-$unique_id"

    foreach line [split $css "\n"] {
        set line [string trim $line]
        # Skip empty lines or lines that don't start with a selector
        if {$line eq "" || ![string match ".* \{*" $line]} {
            append scoped_css "$line\n"
            continue
        }
        # Extract the selector (before the opening brace)
        regexp {^(.*)\{.*$} $line _ selector
        set selector [string trim $selector]
        # Scope the selector under the container class
        set scoped_selector ".$container_class $selector"
        # Rebuild the line with the scoped selector
        set line [regsub {^[^\{]+} $line $scoped_selector]
        append scoped_css "$line\n"
    }

    # Return both the scoped CSS and the container class
    return [list $scoped_css $container_class]
}

#### render
proc render {data css template} {
    upvar $data _data
    upvar $css _css
    upvar $template _template
    # Generate scoped CSS and get container class
    lassign [scope_css $_css] scoped_css container_class
    
    # Create a container with the scoped CSS
    set result [div [list class $container_class] \
		    [style {} $scoped_css] \
		    [eval $_template]] 
    return $result
}

# proc defcon {name body} { proc $name {args} $body }
# defcon card {
#     lassign $args data css
#     lassign [scope_css $css] scoped_css container_class
#     div [list class $container_class] \
# 	[style {} $scoped_css] \
# 	[div {class "card-grid"} \
# 	     {*}[lmap card $data {
# 		 dict with card {}
# 		 article {class "card"} \
# 		     [h3 {class "card-title"} $title] \
# 		     [div {class "card-content"} $body] \
# 		     [expr {$footer ne "" ? 
# 			    [div {class "card-footer"} $footer] : ""}]
# 	     }]]
# }



#### svg
namespace eval svg {
    proc pie_chart {_sales} {
	# Pie chart parameters
	set cx 100  ;# Center x
	set cy 100  ;# Center y
	set r 80    ;# Radius
	
	# Calculate total
	set total 0
	foreach {k v} [dict get $_sales] {
	    dict with v {}
	    incr total $value
	}
	
	# Build SVG
	set start_angle 0
	set paths [list]
	foreach {k v} [dict get $_sales] {
	    dict with v {}
	    # Calculate angle for this slice
	    set angle [expr {($value * 360.0) / $total}]
	    set end_angle [expr {$start_angle + $angle}]
	    # Convert angles to radians
	    set start_rad [expr {$start_angle * 3.14159265359 / 180.0}]
	    set end_rad [expr {$end_angle * 3.14159265359 / 180.0}]
	    # Calculate start and end points on the circle
	    set x1 [expr {$cx + $r * cos($start_rad)}]
	    set y1 [expr {$cy + $r * sin($start_rad)}]
	    set x2 [expr {$cx + $r * cos($end_rad)}]
	    set y2 [expr {$cy + $r * sin($end_rad)}]
	    # Large arc flag (1 if angle > 180°, 0 otherwise)
	    set large_arc [expr {$angle > 180 ? 1 : 0}]
	    # Path: Move to center, line to start, arc to end, line back to center
	    set d "M $cx $cy L $x1 $y1 A $r $r 0 $large_arc 1 $x2 $y2 Z"
	    lappend paths [path [list d $d fill $color] \
			       [title {} "$k: $value"]]  ;# Add tooltip
	    # Add percentage label in each slice
	    set label_angle [expr {$start_angle + ($angle / 2)}]
	    set label_rad [expr {$label_angle * 3.14159265359 / 180.0}]
	    set label_x [expr {$cx + ($r * 0.6) * cos($label_rad)}]
	    set label_y [expr {$cy + ($r * 0.6) * sin($label_rad)}]
	    set percentage [format "%.1f%%" [expr {($value * 100.0) / $total}]]
	    set font_size [expr {10 + int(($value * 100.0 / $total) * 0.3)}] ;# Scale from 10px base
	    lappend paths [text [list x $label_x y $label_y fill "white" text-anchor "middle" font-weight "bold" font-size "${font_size}px"] $value]
	    set start_angle $end_angle
	}
	lappend paths [style {} {
	    path:hover {
		transform: scale(1.1);
		transform-origin: 100px 100px; /* Center of the pie (cx, cy) */
	    }
	}]	
	# Return SVG
	return [svg {width 200 height 200} {*}$paths]
    }

    proc bar_chart {_sales} {
	
	# Chart dimensions
	set width 400
	set height 250
	set padding 40  ;# Padding around the chart
	set bar_padding 10  ;# Space between bars
	
	# Calculate usable dimensions
	set chart_width [expr {$width - ($padding * 2)}]
	set chart_height [expr {$height - ($padding * 2)}]
	
	# Get total number of products
	set num_products [dict size $_sales]
	
	# Calculate bar width
	set bar_width [expr {($chart_width - ($bar_padding * ($num_products - 1))) / $num_products}]
	
	# Find maximum value for scaling
	set max_value 0
	dict for {product info} $_sales {
	    set value [dict get $info value]
	    if {$value > $max_value} {
		set max_value $value
	    }
	}
	
	# Scale factor for bar height
	set scale_factor [expr {$chart_height / $max_value}]
	
	# Build bars
	set elements [list]
	set x $padding
	
	# Add y-axis
	lappend elements [line [list x1 $padding y1 $padding x2 $padding y2 [expr {$height - $padding}] stroke "black" stroke-width 1]]
	
	# Add x-axis
	lappend elements [line [list x1 $padding y1 [expr {$height - $padding}] x2 [expr {$width - $padding}] y2 [expr {$height - $padding}] stroke "black" stroke-width 1]]
	
	# Add bars and labels
	dict for {product info} $_sales {
	    dict with info {}
	    set bar_height [expr {$value * $scale_factor}]
	    set y [expr {$height - $padding - $bar_height}]
	    
	    # Add bar
	    lappend elements [rect [list x $x y $y width $bar_width height $bar_height fill $color] \
				  [title {} "$product: $value"]]
	    
	    # Add product label
	    # lappend elements [text [list x [expr {$x + ($bar_width / 2)}] y [expr {$height - $padding + 15}] \
	    # 				text-anchor "middle" font-size "12px" transform "rotate(45 [expr {$x + ($bar_width / 2)}] [expr {$height - $padding + 15}])"] $product]
	    
	    # Add value label
	    lappend elements [text [list x [expr {$x + ($bar_width / 2)}] y [expr {$y - 5}] \
					text-anchor "middle" font-size "12px"] $value]
	    
	    # Move x position for next bar
	    set x [expr {$x + $bar_width + $bar_padding}]
	}
	
	# Return SVG
	return [svg [list width $width height $height viewBox "0 0 $width $height"] {*}$elements]
    }
    
    proc line_chart {} {
	variable sales
	
	# Chart dimensions
	set width 400
	set height 250
	set padding 40  ;# Padding around the chart
	
	# Calculate usable dimensions
	set chart_width [expr {$width - ($padding * 2)}]
	set chart_height [expr {$height - ($padding * 2)}]
	
	# Get total number of data points
	set num_points [dict size $sales]
	
	# Calculate point spacing
	set point_spacing [expr {$chart_width / ($num_points - 1.0)}]
	
	# Find maximum value for scaling
	set max_value 0
	dict for {product info} $sales {
	    set value [dict get $info value]
	    if {$value > $max_value} {
		set max_value $value
	    }
	}
	
	# Scale factor for point height
	set scale_factor [expr {$chart_height / $max_value}]
	
	# Build path data and points
	set elements [list]
	set path_data "M"
	set x $padding
	set points [list]
	
	# Add axes
	lappend elements [line [list x1 $padding y1 $padding x2 $padding y2 [expr {$height - $padding}] stroke "black" stroke-width 1]]
	lappend elements [line [list x1 $padding y1 [expr {$height - $padding}] x2 [expr {$width - $padding}] y2 [expr {$height - $padding}] stroke "black" stroke-width 1]]
	
	# Create points and path
	dict for {product info} $sales {
	    dict with info {}
	    set y [expr {$height - $padding - ($value * $scale_factor)}]
	    
	    # Add point to path data
	    append path_data " $x,$y"
	    
	    # Add point circle
	    lappend points [circle [list cx $x cy $y r 4 fill $color stroke "white" stroke-width 2] \
				[title {} "$product: $value"]]
	    
	    # Add x-axis label
	    lappend elements [text [list x $x y [expr {$height - $padding + 15}] \
					text-anchor "middle" font-size "12px" transform "rotate(45 $x [expr {$height - $padding + 15}])"] $product]
	    
	    # Move x position for next point
	    set x [expr {$x + $point_spacing}]
	    
	    # For the first point, just add coordinates; for subsequent points, add "L" command
	    if {$path_data eq "M"} {
		# First point - just append coordinates
		append path_data "$x,$y"
	    } else {
		# Subsequent points - use line-to command
		append path_data " L $x,$y"
	    }
	}
	
	# Create the line path
	lappend elements [path [list d $path_data stroke "#333" stroke-width 2 fill "none"]]
	
	# Add all point circles after the line so they appear on top
	lappend elements {*}$points
	
	# Return SVG
	return [svg [list width $width height $height viewBox "0 0 $width $height"] {*}$elements]
    }

    proc progress_bar {percentage {color "#4ECDC4"}} {
	# Validate percentage
	if {$percentage < 0 || $percentage > 100} {
	    set percentage [expr {$percentage < 0 ? 0 : 100}]
	}

	# Progress bar dimensions
	set width 200
	set height 20
	set x 0
	set y 0

	# Calculate the width of the filled portion
	set fill_width [expr {$width * $percentage / 100.0}]

	# Background rectangle (gray)
	set background [rect [list x $x y $y width $width height $height fill "#E0E0E0"]]

	# Filled portion (colored)
	set fill [rect [list x $x y $y width $fill_width height $height fill $color]]

	# Text label (percentage)
	set text_x [expr {$width / 2}]
	set text_y [expr {$height / 2 + 5}] ;# Vertically center the text
	set label [text [list x $text_x y $text_y text-anchor middle fill "#000000" font-size 12] "$percentage%"]

	# Combine into SVG
	return [svg [list width $width height $height] $background $fill $label]
    }
}

#### chartjs
set sales [list \
	       [dict create name "Product A" value 30 color "#FF6B6B"] \
	       [dict create name "Product B" value 20 color "#4ECDC4"] \
	       [dict create name "Product C" value 25 color "#45B7D1"] \
	       [dict create name "Product D" value 15 color "#96CEB4"] \
	       [dict create name "Product E" value 10 color "#FFEEAD"]]
set labels [join [lmap item $sales {format "'%s'" [dict get $item name]}] ", "]
set values [join [lmap item $sales {dict get $item value}] ", "]
set colors [join [lmap item $sales {format "'%s'" [dict get $item color]}] ", "]
set target [subst {
    labels: \[$labels\],
    datasets: \[{
	data: \[$values\],
	backgroundColor: \[$colors\]
    }\]
};
	   ]
proc bar_script {target} {
    return [subst {window.initChart = function() {
	const ctx = document.getElementById('myChart');
	if (ctx.chart) ctx.chart.destroy(); // Destroy existing chart if any
	ctx.chart = new Chart(ctx, {
	    type: 'pie',
	    data: {$target},
	    options: {
		plugins: {
		    tooltip: { enabled: true }
		}
	    }
	});
    };
    }]
}


#### fisheryatesshuffle
proc fisherYatesShuffle {arr} {
    set n [llength $arr]

    for {set i [expr {$n - 1}]} {$i > 0} {incr i -1} {
	set randomIndex [expr {int(rand() * ($i + 1))}]
	set temp [lindex $arr $i]
	set arr [lreplace $arr $i $i [lindex $arr $randomIndex]]
	set arr [lreplace $arr $randomIndex $randomIndex $temp]
    }
    return $arr
}
proc generate_numbers {} {
    set a [lrepeat 100 0]
    lappend a {*}[lrepeat 4 1]
    set a [fisherYatesShuffle $a]
    set positions [list]
    set start -1
    for {set i 0} {$i < 4} {incr i} {
	set idx [lsearch -start [expr {$start + 1}] $a 1]
	lappend positions $idx
	set start $idx
    }
    set numbers [list]
    set prev -1
    foreach pos $positions {
	lappend numbers [expr {$pos - $prev}]
	set prev $pos
    }
    lappend numbers [expr {104 - $prev}]
    set numbers [lmap num $numbers {expr {$num - 1}}]
    return $numbers
}
