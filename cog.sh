#!/bin/sh

set -a

CHECK="${1}"
LATEST_TAG_ONLY="${2}"
RELEASE="${3}"
GIT_USER="${4}"
GIT_USER_EMAIL="${5}"
WORK_DIR="${6}"
INITIAL_VERSION="${7}"

# shellcheck disable=2164
cd "${WORK_DIR}"
echo "[cog-action] working directory: ${WORK_DIR}, current directory: ${PWD}"

echo "[cog-action] setting git user : ${GIT_USER}"
git config --global user.name "${GIT_USER}"

echo "[cog-action] setting git user email ${GIT_USER_EMAIL}"
git config --global user.email "${GIT_USER_EMAIL}"

cog --version

CURRENT_VERSION=$(cog get-version 2>/dev/null || echo '')
echo "[cog-action] current version: ${CURRENT_VERSION}, initial version: ${INITIAL_VERSION}"

if [ "${CHECK}" = 'true' ]; then
  if [ "${LATEST_TAG_ONLY}" = 'true' ]; then
    if [ -n "${CURRENT_VERSION}" ]; then
      echo "[cog-action] checking commits from ${CURRENT_VERSION}"
      cog check --from-latest-tag || exit 1
    else
      echo '[cog-action] no tag found, checking from first commit'
      cog check || exit 1
    fi
  else
    echo "[cog-action] checking all commits"
    cog check || exit 1
  fi
fi

if [ "${RELEASE}" = 'true' ]; then
  if [ -z "${CURRENT_VERSION}" ] && [ -n "${INITIAL_VERSION}" ]; then
    git commit --allow-empty -m 'chore: repo init'
    cog bump --version "${INITIAL_VERSION}"
  else
    cog bump --auto || exit 1
  fi

  NEXT_VERSION=$(cog get-version 2>/dev/null || echo '')
  echo "[cog-action] next version: ${NEXT_VERSION}, current version: ${CURRENT_VERSION}"

  echo "version=${NEXT_VERSION}" >> "${GITHUB_OUTPUT}"
  if [ -n "${NEXT_VERSION}" ] && [ "${CURRENT_VERSION}" != "${NEXT_VERSION}" ]; then
    echo 'bumped=true' >> "${GITHUB_OUTPUT}"
  fi

  CHNG="RELEASE_NOTES_${NEXT_VERSION}.md"
  cog changelog --at "${NEXT_VERSION}" > "${CHNG}"
  echo "changelog=${CHNG}" >> "${GITHUB_OUTPUT}"
fi
