FROM debian:stable

RUN groupadd -r node && useradd -m -g node node

# build directories
ENV APP_SOURCE_DIR=/opt/meteor/src
ENV APP_BUNDLE_DIR=/opt/meteor/dist
ENV BUILD_SCRIPTS_DIR=/opt/build_scripts

# Add entrypoint and build scripts
COPY scripts $BUILD_SCRIPTS_DIR
RUN chmod -R 750 $BUILD_SCRIPTS_DIR


ONBUILD ENV METEOR_DISABLE_OPTIMISTIC_CACHING=1

# Define all --build-arg options
ONBUILD ARG MIRROR_SOURCE
ONBUILD ENV MIRROR_SOURCE=${MIRROR_SOURCE:-mirror.zim.uni-due.de}

ONBUILD ARG NODE_VERSION
ONBUILD ENV NODE_VERSION=${NODE_VERSION:-14.17.4}

ONBUILD ARG NPM_TOKEN
ONBUILD ENV NPM_TOKEN=$NPM_TOKEN

# Node flags for the Meteor build tool
ONBUILD ARG TOOL_NODE_FLAGS
ONBUILD ENV TOOL_NODE_FLAGS=$TOOL_NODE_FLAGS

# Override package mirror
ONBUILD RUN sed -i "s@deb.debian.org@$MIRROR_SOURCE@g" /etc/apt/sources.list.d/debian.sources

# copy the app to the container
ONBUILD COPY . $APP_SOURCE_DIR

# install all dependencies, build app, clean up
ONBUILD RUN cd $APP_SOURCE_DIR && \
  bash -l $BUILD_SCRIPTS_DIR/install-deps.sh && \
  bash -l $BUILD_SCRIPTS_DIR/install-node.sh && \
  bash -l $BUILD_SCRIPTS_DIR/install-meteor.sh && \
  bash -l $BUILD_SCRIPTS_DIR/build-meteor.sh && \
  bash -l $BUILD_SCRIPTS_DIR/post-build-cleanup.sh


# Default values for Meteor environment variables
ENV ROOT_URL=http://localhost
ENV PORT=3000

EXPOSE 3000

WORKDIR $APP_BUNDLE_DIR/bundle

# start the app
ENTRYPOINT ["./entrypoint.sh"]
CMD ["node", "main.js"]
