     proc about_page {} {
	 # CSS for elegant design
	 set styles {
	     :root {
		 --primary: #2D3047;
		 --text: #333333;
		 --accent: #6E7DAB;
		 --light: #F6F8FF;
	     }
	     body { 
		 font-family: "Inter", -apple-system, sans-serif;
		 color: var(--text);
		 line-height: 1.7;
		 margin: 0;
		 padding: 0;
		 background-color: white;
	     }
	     .nav {
		 padding: 2rem;
		 display: flex;
		 justify-content: space-between;
		 align-items: center;
		 border-bottom: 1px solid #eee;
	     }
	     .logo {
		 font-weight: 700;
		 font-size: 1.2rem;
		 color: var(--primary);
		 text-decoration: none;
	     }
	     .nav-links a {
		 margin-left: 2.5rem;
		 text-decoration: none;
		 color: var(--text);
		 font-size: 0.95rem;
		 transition: color 0.2s ease;
	     }
	     .nav-links a:hover {
		 color: var(--accent);
	     }
	     .hero {
		 padding: 6rem 2rem;
		 text-align: center;
		 background-color: var(--light);
	     }
	     .hero h1 {
		 font-size: 3rem;
		 margin: 0;
		 color: var(--primary);
		 font-weight: 800;
		 line-height: 1.2;
	     }
	     .hero p {
		 font-size: 1.2rem;
		 max-width: 600px;
		 margin: 1.5rem auto;
		 color: var(--accent);
	     }
	     .cta {
		 display: inline-block;
		 padding: 1rem 2rem;
		 background-color: var(--primary);
		 color: white;
		 text-decoration: none;
		 border-radius: 4px;
		 font-weight: 500;
		 transition: transform 0.2s ease;
	     }
	     .cta:hover {
		 transform: translateY(-2px);
	     }
	     .features {
		 padding: 5rem 2rem;
		 max-width: 1200px;
		 margin: 0 auto;
		 display: grid;
		 grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
		 gap: 3rem;
	     }
	     .feature {
		 text-align: center;
		 padding: 2rem;
	     }
	     .feature h3 {
		 color: var(--primary);
		 margin: 1rem 0;
	     }
	     .feature p {
		 color: #666;
		 font-size: 0.95rem;
	     }
	 }

	 # Create page structure
	 set header [head {} \
			 [meta {charset "UTF-8"}] \
			 [meta {name "viewport" content "width=device-width, initial-scale=1"}] \
			 [title {} "Elegant Design"] \
			 [link {rel "stylesheet" href "https://fonts.googleapis.com/css2?family=Inter:wght@400;500;700;800&display=swap"}] \
			 [style {} $styles] \
			]

	 set nav [nav {class "nav"} \
		      [a {class "logo" href "/"} "Elegant."] \
		      [div {class "nav-links"} \
			   [a {href "/about"} "About"] \
			   [a {href "/work"} "Work"] \
			   [a {href "/services"} "Services"] \
			   [a {href "/contact"} "Contact"] \
			  ] \
		     ]

	 set hero [section {class "hero"} \
		       [h1 {} "Create Beautiful\nExperiences"] \
		       [p {} "We craft elegant digital solutions that blend form and function to elevate your brand and engage your audience."] \
		       [a {class "cta" href "/contact"} "Get Started"] \
		      ]

	 set features [section {class "features"} \
			   [div {class "feature"} \
				[h3 {} "Strategic Design"] \
				[p {} "Thoughtful solutions that align with your business goals and user needs."] \
			       ] \
			   [div {class "feature"} \
				[h3 {} "Crafted Code"] \
				[p {} "Clean, efficient, and maintainable code that brings your vision to life."] \
			       ] \
			   [div {class "feature"} \
				[h3 {} "User Experience"] \
				[p {} "Intuitive interfaces that delight users and drive engagement."] \
			       ] \
			  ]

	 set main [main {} \
		       $nav \
		       $hero \
		       $features \
		  ]

	 set body [body {} $main]

	 # Return complete HTML
	 return [html {} $header $body]
     }
