# WIP

## Containers

In theory, you should just be able to create the DB, load the schema, then boot the app.  There are some hard-coded row-creations (instead of seeding) that happen if the rows don't exist when the app loads, but I haven't tested them in a while...

### Javascript Conventions

 * All Ajax calls should be done using RAJ (Rails and AJAS).
 * RAJ links use the class name convention "a-*" to denote they Ajax links
 * Data display elements updated by returned JSON use the class name convention "d-*"
 * * This allows all elements on the page with that data to be updated in a single query
