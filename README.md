# Meteor Launchpad - Base Docker Image for Meteor Apps

Based on https://github.com/gbhrdt/meteor-launchpad and originally https://github.com/jshimko/meteor-launchpad

Notable differences (to gbhrdt/meteor-launchpad):
- Uses a different package mirror by default
- `MONGO_URL` is optional and no local mongo server will be provided
- Default Node.js version determined by used Meteor version (14.x for Meteor v2 apps; 24.x for Meteor v3+)

### Build this image

Setup for Apple Silicon devices:

```sh
docker buildx build -t yourname/appbuild --platform linux/amd64
```

> Note that this image will use a custom package mirror by default that is only available in our university network. You can change the mirror by setting the `MIRROR_SOURCE` environment variable.


### Build your app image

Add the following to a `Dockerfile` in the root of your app:

```Dockerfile
FROM fmidue/meteor-launchpad
# You can also use a specific version. All available tags can be seen at the Docker Hub page.
# FROM fmidue/meteor-launchpad:2025-12-03.12-08
```

Then you can build the image with:

```sh
docker build -t yourname/app .
```

**Setting up a .dockerignore file**

There are several parts of a Meteor development environment that you don't need to pass into a Docker build because a complete production build happens inside the container.  For example, you don't need to pass in your `node_modules` or the local build files and development database that live in `.meteor/local`.  To avoid copying all of these into the container, here's a recommended starting point for a `.dockerignore` file to be put into the root of your app.  Read more: https://docs.docker.com/engine/reference/builder/#dockerignore-file

```
.git
.meteor/local
node_modules
```

### Run

Now you can run your container with the following command...
(note that the app listens on port 3000 because it is run by a non-root user for [security reasons](https://github.com/nodejs/docker-node/issues/1) and [non-root users can't run processes on port 80](https://stackoverflow.com/questions/16573668/best-practices-when-running-node-js-with-port-80-ubuntu-linode))

```sh
docker run -d \
  -e ROOT_URL=http://example.com \
  -e MONGO_URL=mongodb://url \
  -e MONGO_OPLOG_URL=mongodb://oplog_url \
  -e MAIL_URL=smtp://mail_url.com \
  -p 80:3000 \
  yourname/app
```


### Build Options

Meteor Launchpad supports setting custom build options in one of two ways.  You can either create a launchpad.conf config file in the root of your app or you can use [Docker build args](https://docs.docker.com/engine/reference/builder/#arg).  The currently supported options are to install any list of `apt-get` dependencies (Meteor Launchpad is built on `debian:stable`).  

This image does not contain a MongoDB installation. You need to host your database externally and provide a `MONGODB_URL`. Note that this is optional.

Here are examples of both methods of setting custom options for your build:

**Option #1 - launchpad.conf**

To use any of them, create a `launchpad.conf` in the root of your app and add any of the following values.

```sh
# launchpad.conf

# Override the default Node.js version (default for meteor 2.x: 14.x; default for meteor 3.x: 24.x)
NODE_VERSION=24.9.0
```

**Option #2 - Docker Build Args**

If you prefer not to have a config file in your project, your other option is to use the Docker `--build-arg` flag.  When you build your image, you can set any of the same values above as a build arg.

```sh
docker build \
  --build-arg NODE_VERSION=24.9.0 \
  -t myorg/myapp:latest .
```

## Installing Private NPM Packages

You can provide your [NPM auth token](https://blog.npmjs.org/post/118393368555/deploying-with-npm-private-modules) with the `NPM_TOKEN` build arg.

```sh
docker build --build-arg NPM_TOKEN="<your token>" -t myorg/myapp:latest .
```
