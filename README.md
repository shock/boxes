# Boxes a.k.a. Containers

A web app for managing a hierarchy of containers and their contents.  The app is a Rails app, and the database is Postgres.  It's a bit of a mess, but it's working.  I built it to keep track of all my belongings when I packed to move from Austin.  It's extremely useful, since a lot of my stuff is still in boxes, and this enables me to keep track of what's in what box, and where the boxes are, heiarchically.  I'm using it to manage my boxes, but I'm sure it could be used for other things.

Eventually, I want to rewrite this app in React or another SPA framework, and make the backend a pure REST API running on a lightweight framework like Bun.  The trick will be finding a good ORM for Postgres, since Rails takes care of so much of the heavy lifting in that regard.  Maybe it makes sense to keep Rails as the backend, since the logic is already there, and moving the frontend rendering to a SPA framework will simplify the Rails codebase.

## Docker

This project still uses Ruby 2.6.6 and Rails 4.2.8.  Ruby 2.6.6 doesn't compile on ARM64 (M1 Mac), so Docker with x86 emulation is required.  The Dockerfile has been updated to use Debian archive repositories (since Debian 10 buster is EOL) and the build process now compiles assets inside the container.

To start the app, just run:
```bash
./script/docker_start.sh
```

This will build the Docker image (cached if nothing changed) and start the container.  Works with Colima or Docker Desktop.  Database runs on the host machine - ensure `.env` file has `DATABASE_URL` with `host.docker.internal` as the hostname.

### Docker Image Registry

The Docker image is also available in a local Docker registry at `localdock.lan`:

- **Image**: `localdock.lan/boxes4_ruby_2_6_6:latest`
- **Pull**: `docker pull localdock.lan/boxes4_ruby_2_6_6:latest`

To push updates to the local registry:
```bash
docker tag boxes4_ruby_2_6_6:latest localdock.lan/boxes4_ruby_2_6_6:latest
docker push localdock.lan/boxes4_ruby_2_6_6:latest
```

# Notes

## Database

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
