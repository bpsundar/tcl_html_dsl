    namespace eval Smee::dsl {} {
	variable semanticHTML voidElements
    
	set semanticHTML [list a address article aside blockquote canvas caption cite code datalist del details dialog div em figure footer form h1 h2 h3 h4 h5 h6 header ins label legend li main mark meter nav optgroup option output p pre progress section select small span strong style sub sup summary table tbody td textarea tfoot th thead tr ul area base br col embed hr img input link meta track wbr html head title body]
	set voidElements [list area base br col embed hr img input link meta source track wbr]

	proc html_escape {text} {
	    # Prevent XSS and handle special characters
	    string map {
		& &amp;
		< &lt;
		> &gt;
		\" &quot;
		' &#39;
	    } $text
	}

	proc html_tag {tag_name attributes args} {
	    variable voidElements
	
	    set attr_string ""
	    if {$attributes ne {} } {
		foreach {key value} $attributes {
		    append attr_string " $key=\"$value\""
		    # use this version if strict escaping is needed
		    # append attr_string " $key=\"[html_escape $value]\""
		}
	    }

	    set content ""
	    foreach arg {*}$args {
		if {$tag_name eq "tr"} {
		    set cells [split [string trim $arg "{}"] ","]
		    foreach cell $cells {
			set cell [string trim $cell]
			append content [td nil $cell]
		    }
		} else {
		    append content $arg
		}
	    }
	    if {[lsearch -exact $voidElements $tag_name] != -1} {
		return "<$tag_name$attr_string />$content"
	    } else {
		return "<$tag_name$attr_string>$content</$tag_name>"
	    }
	}

	proc cons {name args} { proc $name {content args} [subst {html_tag $name \$content \$args}]}

	proc html-tag-maker {} {
	    variable semanticHTML
	    foreach element $semanticHTML {
		Smee::dsl::cons $element content args
	    }
	}

	html-tag-maker 
	namespace export {*}$semanticHTML
    }
