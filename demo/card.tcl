     proc card_page {} {
	 # Define the base styles
	 set base_styles {
	     :root {
		 --primary: #2D3047;
		 --sidebar-bg: #f8f9fa;
		 --text: #666;
		 --border: #eee;
		 --hover: rgba(0, 0, 0, 0.05);
	     }
	
	     ,* {
		 box-sizing: border-box;
		 margin: 0;
		 padding: 0;
	     }
	
	     body, html {
		 height: 100%;
		 font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
	     }
	 }

	 # Define dashboard-specific styles
	 set dashboard_styles {
	     .dashboard {
		 display: grid;
		 grid-template-columns: 250px 1fr;
		 height: 100%;
	     }
	
	     .sidebar {
		 background: var(--sidebar-bg);
		 padding: 2rem 1rem;
		 border-right: 1px solid var(--border);
	     }
	
	     .nav-menu {
		 display: flex;
		 flex-direction: column;
		 gap: 0.5rem;
	     }
	
	     .nav-link {
		 display: block;
		 padding: 0.75rem 1rem;
		 color: var(--text);
		 text-decoration: none;
		 border-radius: 6px;
		 transition: all 0.2s ease;
	     }
	
	     .nav-link:hover {
		 background: var(--hover);
		 color: var(--primary);
	     }
	
	     .nav-link.active {
		 background: var(--primary);
		 color: white;
	     }
	
	     .content {
		 padding: 2rem;
		 overflow-y: auto;
	     }
	
	     .content-header {
		 margin-bottom: 2rem;
	     }
	
	     .card-grid {
		 display: grid;
		 grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
		 gap: 2rem;
	     }
	
	     @media (max-width: 768px) {
		 .dashboard {
		     grid-template-columns: 1fr;
		 }
	    
		 .sidebar {
		     display: none;
		 }
	     }
	 }

	 # Build the navigation menu
	 set nav_menu [nav {class "nav-menu"} \
			   [a {class "nav-link active" href "#"} "Overview"] \
			   [a {class "nav-link" href "#"} "Analytics"] \
			   [a {class "nav-link" href "#"} "Reports"] \
			   [a {class "nav-link" href "#"} "Settings"] \
			  ]

	 # Build the sidebar
	 set sidebar [aside {class "sidebar"} \
			  [h2 {class "sidebar-title"} "Dashboard"] \
			  $nav_menu \
			 ]

	 # Create some sample cards using your card proc
	 set cards [list \
			[card {} [list \
				      title "Performance" \
				      body "Track your key metrics and performance indicators." \
				      footer [a {href "#"} "View Details"] \
				     ]] \
			[card {} [list \
				      title "Revenue" \
				      body "Monitor your revenue streams and financial data." \
				      footer [a {href "#"} "View Report"] \
				     ]] \
			[card {} [list \
				      title "Users" \
				      body "Analyze user engagement and behavior patterns." \
				      footer [a {href "#"} "View Analytics"] \
				     ]] \
		       ]

	 # Build the main content area
	 set content [main {class "content"} \
			  [header {class "content-header"} \
			       [h1 {} "Overview"] \
			      ] \
			  [div {class "card-grid"} {*}$cards] \
			 ]

	 # Build the dashboard layout
	 set dashboard [div {class "dashboard"} \
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
			]

	 set body [body {} $dashboard]

	 # Return complete HTML
	 return [html {} $header $body]
     }


     proc card {attributes content} {
	 # Default styles for cards
	 set card_styles {
	     .card {
		 background: white;
		 border-radius: 8px;
		 padding: 1.5rem;
		 box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
		 transition: transform 0.2s ease;
	     }
	     .card:hover {
		 transform: translateY(-2px);
	     }
	     .card-title {
		 font-size: 1.25rem;
		 font-weight: 600;
		 margin: 0 0 1rem 0;
		 color: var(--primary, #2D3047);
	     }
	     .card-content {
		 color: var(--text, #666);
		 line-height: 1.6;
	     }
	     .card-footer {
		 margin-top: 1.5rem;
		 padding-top: 1rem;
		 border-top: 1px solid #eee;
	     }
	 }

	 # Extract title, body, and footer from content dictionary
	 set title [dict get $content title]
	 set body [dict get $content body]
	 set footer [dict get $content footer]
    
	 # Create the card structure
	 return [article {class $attributes} \
		     [style {} $card_styles] \
		     [h3 {class "card-title"} $title] \
		     [div {class "card-content"} $body] \
		     [expr {$footer ne "" ? [div {class "card-footer"} $footer] : ""}] \
		    ]
     }
