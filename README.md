# WIP

## Containers

In theory, you should just be able to create the DB, load the schema, then boot the app.  There are some hard-coded row-creations (instead of seeding) that happen if the rows don't exist when the app loads, but I haven't tested them in a while...

### Javascript Conventions

 * All Ajax calls should be done using RAJ (Rails and AJAJ).
 * RAJ links use the class name convention "a-*" to denote they're Ajax links
 * Data display elements updated by returned JSON use the class name convention "d-_*_"
 * * This allows all elements on the page with that data to be updated in a single query

### The UI

 * First, see if you can figure out.  Tough, right?
 * Second, on a wide enough display, the left column is a table showing the contained things for the current container.
 * The middle column is a traversable and collapsible tree showing the entire hierarchy of the DB (with controls once you figure them out).  Clicking on a tree node twice, loads it into the left column as the parent.
 * The right column is a search column with options for searching.  You might have to be a little smarter than a dumbass to figure out the options.
 * The top-nav takes you: "home" (The World), selections (a feature involving the checkboxes), tags, and browser buttons (forward back) for when the app is loaded full screen on a mobile device. 

 
Note that data is loaded by AJAJ in the first two columns each page load, so clicking the back/forward buttons will always return current state from the DB.
