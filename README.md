# TCL HTML DSL
A lightweight, composable DSL for generating Web UI in TCL with encapsulated styling and modular components.  
Demo: [Demo Page](http://139.84.220.21:8000/) [404](http://139.84.220.21:8000/ca)


Disclaimer: Except HTMX, no js was harmed while rendering these pages ;-)

## Key Features

* Component-Based Architecture: Build reusable, self-contained components with encapsulated styles

```tcl
set card [card {} [list \
    title "Hello World" \
    body "This is a card component" \
    footer "Read more" \
]]
```
* Clean, Functional Composition: Compose complex layouts from simple components
```tcl
set main [main {} \
    $nav \
    $hero \
    $features \
]
```
* Scoped Styling: CSS is scoped to components, preventing style leaks
```tcl
set card_styles {
    .card {
        background: white;
        border-radius: 8px;
        padding: 1.5rem;
        box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
    }
}
```
* No External Dependencies: Pure TCL implementation with no dependencies
* Custom Elements: Generate complete HTML without client-side JavaScript
* Theme Support: CSS custom properties for easy theming
* Modular Design: Components can be split into separate files and sourced as needed

## Components
The DSL includes several pre-built components:

* Cards with title, body, and optional footer
* Forms with field validation and error states
* Navigation menus
* Grid layouts
* Custom components can be easily added
## Example Usage
```tcl
# Create a page with multiple components
set header [head {} \
    [meta {charset "UTF-8"}] \
    [title {} "My Page"] \
]

set body [body {} \
    [div {class "container"} \
        $nav_menu \
        $content \
    ] \
]

return [html {} $header $body]
```
```html
<html>
  <head>
    <meta charset="UTF-8" />
    <title>My Page</title>
  </head>
  <body>
    <div class="container">
      <nav class="nav-menu">
        <a class="nav-link active" href="#">Overview</a>
        <a class="nav-link" href="#">Analytics</a>
        <a class="nav-link" href="#">Reports</a>
        <a class="nav-link" href="#">Settings</a>
      </nav>
      <p>Howdy, Stranger!</p>
    </div>
  </body>
</html>
```
## Benefits

* No separate template language to learn!
* Component-based development without JavaScript
* Clean separation of concerns
* Easy to maintain and extend
* Predictable rendering and styling
* Great for server-rendered applications
## License
This is free and unencumbered software released into the public domain.

Anyone is free to copy, modify, publish, use, compile, sell, or
distribute this software, either in source code form or as a compiled
binary, for any purpose, commercial or non-commercial, and by any
means......yada yada yada...

For more information, please refer to <https://unlicense.org/>
