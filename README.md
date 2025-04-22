# An experimentation in Tcl 

Tools used:  
**Tcl**, **NaviServer**, **DataStar**

**Demo**:  
[Demo Page](http://139.84.220.21:8000/)

Projects built:  
Minesweeper game and a To-Do app.

# Code Walk-Through

Lets start with rendering the web page. 

        proc render_html {header body} {
            set doctype "<!DOCTYPE html>\n"
            set html_content [html {} $header $body]
            return "$doctype$html_content"
    }
    
    # Return complete HTML
    ns_return 200 text/html [render_html $header $body]

We define a simple \`proc\` that takes two arguments, a header and a body. And use \`ns_return\` to render the page. 

Let me point out one interesting thing here, variable \`html_content\`, it calls \`html\` with the provided arguments.  

	set html_content [html {} $header $body]

Before we proceed let me show the 'header' and 'body' first,

    set header [head {} \
                    [meta {charset "UTF-8"}] \
                    [meta {name "viewport" content "width=device-width, initial-scale=1"}] \
                    [title {} "Dashboard"] \
                    $all_styles \
                    [script {src /js/htmx/htmx.min.js} ""] \
                    [script {type module src "/js/datastar/datastar-1-0-0-beta-2-987d04d5a076d8bb.js"}] \
                   ]
    
    set body [div {id main class "dashboard"} \
                  $sidebar \
                  $content \
                 ]

Did you notice that all the HTML tags are procedure calls? 

'meta' 'title' 'script' 'div'? 

[HTML elements](https://github.com/bpsundar/tcl_html_dsl/blob/main/demo/views/dsl.tcl) are created with Tcl procedures (e.g., main, header, h1), where 

arguments specify attributes {id main class dashboard} and content, "Dashboard".

    # Build the sidebar
    set sidebar [aside {class "sidebar"} \
                     [h2 {class "sidebar-title"} "PropMan Dashboard"] \
                     $nav_menu \
                    ]
    
    # Build the main content area
    set content [main {class "content"} \
                     [header {class "content-header"} \
                          [h1 {} "Overview"] \
                          [div {id entry} \
                               [div {} [card_page]]] \
                         ]
                ]

Let us compare and contrast with Templ 

(make your own judgement, as both produce valid HTML). 

    package main
    
    templ content() {
        <main class="content">
            <header class="content-header">
                <h1>Overview</h1>
                <div id="entry">
                    <div>{ card_page() }</div>
                </div>
            </header>
        </main>
    }

Another aspect is the nested procedure call, in the \`content\`,

    [div {} [card_page]]

This allows card_page to be composed within other procedures, enabling hierarchical
UI construction similar to modern frameworks, but without their complexity.

And let us check out the \`card\`

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

---
Key Aspects of the Tcl Approach:

-   Tcl’s Variable Substitution as Free Templating:

What It Means:

Tcl’s natural variable substitution (e.g., $title, $body, $footer in the template) to embed dynamic content into HTML-like structures. 

This eliminates the need for a separate templating language (unlike Go’s templ, Handlebars, or Django templates).

-   Reusable Components:

\`card_page\` acts like components, encapsulating logic and presentation with Dynamic and Data-Driven Rendering.

The ability to embed **code** in data or templates makes the UI highly expressive. 

(more examples are in the [demo](https://github.com/bpsundar/tcl_html_dsl/tree/main/demo) folder).

Captivated yet??

Let me show you how we \`render\`

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

CSS is scoped to the 'component' and hence prevents style leak. 

And 'eval' is the magic word.

By using \`upvar\` we can call \`render\` in any context, as it is generic, working with any data, css, and template. 

Now we can move on to [Hypermedia](<https://hypermedia.systems/introduction/>) and turn
our back-end code into a Hypermedia-Driven Application using [DataStar](<https://data-star.dev/>)

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

And Viola! 

we have lift-off (not going to explain much here about DataStar, go read the docs)

---
Next stop is to turn network requests into events, and for that we are going to use coroutines. 

In our NaviServer config we handle all incoming routes through the \`rooot_handler\`

And it calls the \`rate_limit_actor\` which is an Actor middleware.

    proc root_handler {args} {
        set cookie_value [ns_getcookie session_id 0]
        if {$cookie_value eq "0"} {
            set salt [md5crypt::salt]
            ns_setcookie -expires -1 -- third_visit $salt
        } else {
            set salt $cookie_value
        }
        $::middleware::rate_limit_actor send $salt
    }
    
    namespace eval middleware {
        variable rate_limit_actor [Actor new coro_rate_limit middleware::browser_tracking_filter]
        proc browser_tracking_filter {cookie} {
            variable url [ns_conn url]
            variable met [ns_conn method]
            variable id [ns_queryget id]
            puts "$met $url $id"
    
            variable count
            dict incr count $cookie
            # puts [dict get $count $cookie]
            if {[dict get $count $cookie] > 500} {
                #rate limiting logic
                $::events::eventManager send [list "/404" $met $id]
            } else {
                # no worries, go ahead
                $::events::eventManager send [list $url $met $id]
            }
        }
    }

We make use of a simplified Actor class for this purpose.  

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

Incoming request are sent to the 'mailbox' of the respective Actor where it is queued for processing.

---
Next is **state** management,

    namespace eval ::nss::$session_id {
        variable click_count 0
        variable start_time 0
        variable board [::minesweeper::generate_minesweeper_board 10 10 10]
        variable state_list [lindex $board 0]
        variable numbers_list [lindex $board 1]
    }

We create a 'namespace' using the 'cookie' and then pass the 'state' as an argument to any function that might need it.

    proc minesweeper::flagged {session_id args} {
        ...
        namespace upvar $session_id state_list state_list 
        namespace upvar $session_id numbers_list numbers_list
        .... # clipped for breviety
        }

