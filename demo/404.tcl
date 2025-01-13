     proc not_found_page {} {
	 # CSS for the 404 page
	 set styles {
	     body { 
		 background-color: #1a1a1a; 
		 color: #e0e0e0; 
		 font-family: monospace;
		 line-height: 1.6;
		 height: 100vh;
		 margin: 0;
		 display: flex;
		 flex-direction: column;
		 justify-content: center;
		 align-items: center;
		 text-align: center;
	     }
	     .ascii-art {
		 font-family: monospace;
		 white-space: pre;
		 font-size: 1.2rem;
		 margin: 2rem 0;
		 color: #888;
	     }
	     .glitch {
		 animation: glitch 1s infinite;
		 position: relative;
	     }
	     @keyframes glitch {
		 0% { transform: translate(0) }
		 20% { transform: translate(-2px, 2px) }
		 40% { transform: translate(-2px, -2px) }
		 60% { transform: translate(2px, 2px) }
		 80% { transform: translate(2px, -2px) }
		 100% { transform: translate(0) }
	     }
	     a { 
		 color: #e0e0e0;
		 text-decoration: none;
		 border-bottom: 1px dotted #888;
		 margin-top: 2rem;
	     }
	     a:hover {
		 border-bottom-style: solid;
	     }
	     .message {
		 max-width: 600px;
		 margin: 1rem 2rem;
	     }
	     .code {
		 font-size: 5rem;
		 margin: 0;
		 color: #888;
	     }
	 }

	 # ASCII art for 404
	 set ascii_art {
	     ___________________
	     |                   |
	     |   Page not found  |
	     |      ¯\_(ツ)_/¯   |
	     |___________________|
	 }

	 # Create the page structure
	 set header [head {} \
			 [meta {charset "UTF-8"}] \
			 [meta {name "viewport" content "width=device-width, initial-scale=1"}] \
			 [title {} "404 - Page Not Found"] \
			 [style {} $styles] \
			]

	 set main_content [main {} \
			       [h1 {class "code glitch"} "404"] \
			       [div {class "ascii-art"} $ascii_art] \
			       [div {class "message"} \
				    [p {} "Looks like this page has wandered off into the digital void."] \
				    [p {} "Perhaps it's exploring the mysteries of the internet,"] \
				    [p {} "or maybe it's just taking a well-deserved break."] \
				   ] \
			       [p {} \
				    [a {href "/"} "← Let's go back home and try again"] \
				   ] \
			      ]

	 set body [body {} $main_content]

	 # Return complete HTML
	 return [html {} $header $body]
     }
