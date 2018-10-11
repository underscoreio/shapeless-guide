#!/bin/bash
#
# Deploy the PDF, HTML, EPUB files of an Underscore book (source)
# into another Git repository (target)
#
set -e

# Configuration
# 1. The key for writing into the other repository.
#    This is committed to the repo, encrypted by Travis,
#    with filename extension '.enc'.
export KEY_FILENAME="book_deploy_rsa"
# 2. The branch we deploy from.
#    Only deploy for non-PR commits to this branch.
export DEPLOY_BRANCH="develop"
# 3. Folder inside target of where to place the artifacts:
export TARGET_DIR=books/shapeless-guide/
# 4. Commit message prefix (for the "books" repository)
export COMMIT_PREFIX="deploy shapeless guide via travis"
# End of configuration

if [[ "${TRAVIS_PULL_REQUEST}" == "false" && "${TRAVIS_BRANCH}" == "${DEPLOY_BRANCH}" ]]; then
  echo "Starting deploy to Github Pages"
  mkdir -p "~/.ssh"
  echo -e "Host github.com\n\tStrictHostKeyChecking no\nIdentityFile ~/.ssh/${KEY_FILENAME}\n" >> ~/.ssh/config
  cp ${KEY_FILENAME} ~/.ssh/${KEY_FILENAME}
  chmod 600 ~/.ssh/${KEY_FILENAME}

  git config --global user.email "hello@underscore.io"
  git config --global user.name "Travis Build"

  export SRC_DIR=`pwd` # e.g., /home/travis/build/underscoreio/insert-book-name-here

  export TEMP_DIR=/tmp/dist
  mkdir -p $TEMP_DIR
  cd $TEMP_DIR
  git clone git@github.com:underscoreio/books.git

  mkdir -p $TARGET_DIR
  cd $TARGET_DIR

  cp $SRC_DIR/dist/*.pdf .
  cp $SRC_DIR/dist/*.html .
  cp $SRC_DIR/dist/*.epub .

  git add .
  git commit -m "$COMMIT_PREFIX $TRAVIS_JOB_NUMBER $TRAVIS_COMMIT [ci skip]"
  git push git@github.com:underscoreio/books.git master:master

  rm -rf $TEMP_DIR
fi
