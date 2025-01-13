     proc form_field {type attributes content} {
	 # Default styles for form fields
	 set field_styles {
	     .form-field {
		 margin-bottom: 1.5rem;
	     }
	     .field-label {
		 display: block;
		 font-size: 0.875rem;
		 font-weight: 500;
		 margin-bottom: 0.5rem;
		 color: var(--primary, #2D3047);
	     }
	     .field-input {
		 width: 100%;
		 padding: 0.75rem;
		 font-size: 1rem;
		 border: 1px solid var(--border, #eee);
		 border-radius: 6px;
		 background: white;
		 transition: border-color 0.2s ease, box-shadow 0.2s ease;
	     }
	     .field-input:focus {
		 outline: none;
		 border-color: var(--primary, #2D3047);
		 box-shadow: 0 0 0 3px rgba(45, 48, 71, 0.1);
	     }
	     .field-hint {
		 font-size: 0.75rem;
		 margin-top: 0.5rem;
		 color: var(--text, #666);
	     }
	     .field-error {
		 color: var(--error, #dc3545);
		 font-size: 0.75rem;
		 margin-top: 0.5rem;
	     }
	 }

	 # Extract field properties from content dictionary
	 set label [dict get $content label]
	 set name [dict get $content name]
	 if {[dict exists $content error]} {
	     set error [dict get $content error]
	 } else {
	     set error "" 
	 }
	 if {[dict exists $content hint]} {
	     set hint [dict get $content hint]
	 } else {
	     set hint "" 
	 }
	 # set error [expr [dict exists $content error] ? [dict get $content error] : ""]

	 # Create the form field structure
	 return [div {class "form-field"} \
		     [style {} $field_styles] \
		     [label {class "field-label" for $name} $label] \
		     [expr {$type eq "textarea" ? 
			    [textarea {class "field-input" name $name id $name} ""] :
			    [input {class "field-input" type $type name $name id $name} ""]}] \
		     [expr {$hint ne "" ? [div {class "field-hint"} $hint] : ""}] \
		     [expr {$error ne "" ? [div {class "field-error"} $error] : ""}] \
		    ]
     }

proc iform {attributes content} {
	 # Default styles for form
	 set form_styles {
	     .form {
		 max-width: 32rem;
		 margin: 0 auto;
	     }
	     .form-title {
		 font-size: 1.5rem;
		 font-weight: 600;
		 margin-bottom: 1.5rem;
		 color: var(--primary, #2D3047);
	     }
	     .form-description {
		 color: var(--text, #666);
		 margin-bottom: 2rem;
	     }
	     .form-submit {
		 background: var(--primary, #2D3047);
		 color: white;
		 border: none;
		 border-radius: 6px;
		 padding: 0.75rem 1.5rem;
		 font-size: 1rem;
		 font-weight: 500;
		 cursor: pointer;
		 transition: background-color 0.2s ease;
	     }
	     .form-submit:hover {
		 background-color: var(--primary-dark, #1a1c2e);
	     }
	 }

	 # Extract form properties
	 set title [dict get $content title]
	 set description [dict get $content description]
	 set fields [dict get $content fields]
	 if {[dict exists $content submit]} {
	     set submit [dict get $content submit]
	 } else {
	     set submit "" 
	 }

	 # Create the form structure
	 return [form {class "form" $attributes} \
		     [style {} $form_styles] \
		     [h2 {class "form-title"} $title] \
		     [expr {$description ne "" ? [p {class "form-description"} $description] : ""}] \
		     {*}$fields \
		     [button {class "form-submit" type "submit"} $submit] \
		    ]
     }

     set login_form [form {action "/login" method "post"} [list \
    title "Sign In" \
    description "Welcome back! Please sign in to continue." \
    fields [list \
        [form_field "email" {} [list \
            label "Email" \
            name "email" \
        ]] \
        [form_field "password" {} [list \
            label "Password" \
            name "password" \
            hint "Must be at least 8 characters" \
        ]] \
    ] \
    submit "Sign In" \
]]

set contact_form [form {action "/contact" method "post"} [list \
    title "Contact Us" \
    description "Fill out the form below and we'll get back to you shortly." \
    fields [list \
        [form_field "text" {} [list \
            label "Full Name" \
            name "full_name" \
            hint "Enter your full name as it appears on official documents" \
        ]] \
        [form_field "email" {} [list \
            label "Email Address" \
            name "email" \
            hint "We'll never share your email with anyone else" \
        ]] \
        [form_field "textarea" {} [list \
            label "Message" \
            name "message" \
        ]] \
    ] \
    submit "Send Message" \
]]
     
