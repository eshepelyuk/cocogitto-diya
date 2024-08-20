#!/bin/sh

set -a

CHECK="${1}"
LATEST_TAG_ONLY="${2}"
RELEASE="${3}"
GIT_USER="${4}"
GIT_USER_EMAIL="${5}"
WORK_DIR="${6}"

# shellcheck disable=2164
cd "${WORK_DIR}"
echo "Working directory: ${WORK_DIR}, current directory: ${PWD}"

echo "Setting git user : ${GIT_USER}"
git config --global user.name "${GIT_USER}"

echo "Settings git user email ${GIT_USER_EMAIL}"
git config --global user.email "${GIT_USER_EMAIL}"

cog --version

CURRENT_VERSION=$(cog get-version 2>/dev/null || echo '')

if [ "${CHECK}" = 'true' ]; then
  if [ "${LATEST_TAG_ONLY}" = 'true' ]; then
    if [ -n "${CURRENT_VERSION}" ]; then
      echo "Checking commits from ${CURRENT_VERSION}"
      cog check --from-latest-tag || exit 1
    else
      echo 'No tag found checking history from first commit'
      cog check || exit 1
    fi
  else
    echo "Checking all commits"
    cog check || exit 1
  fi
fi

if [ "${RELEASE}" = 'true' ]; then
  cog bump --auto || exit 1
  NEXT_VERSION=$(cog get-version 2>/dev/null || echo '')
  # shellcheck disable=2086
  echo "version=${NEXT_VERSION}" >> $GITHUB_OUTPUT
  if [ -n "${NEXT_VERSION}" ] && [ "${CURRENT_VERSION}" != "${NEXT_VERSION}" ]; then
    # shellcheck disable=2086
    echo 'bumped=true' >> $GITHUB_OUTPUT
  fi
fi
