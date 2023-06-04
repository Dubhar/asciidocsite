#!/usr/bin/env ash

main() {
  echo "$(date +"%Y-%m-%d %H:%MZ") - updating website"

  local dirname
  dirname=$(repo_uri_to_dir "${REPO}")

  update_git_files
  process_asciidoc
  publish
}

repo_uri_to_dir() {
  local reponame
  reponame=$(basename "${1}")
  local dirname
  echo "${reponame%.*}"
}

clone_or_pull() {
  local repouri
  repouri="${1}"
  local repodir
  repodir=$(repo_uri_to_dir "${repouri}")
  if [ -d "${repodir}" ]; then
    (
      cd "${repodir}" || exit
      git -c core.sshCommand="ssh -i /ssh_key -o StrictHostKeyChecking=no" pull
    )
  else
    git -c core.sshCommand="ssh -i /ssh_key -o StrictHostKeyChecking=no" clone "${repouri}"
  fi
}

update_git_files() {
  clone_or_pull "${REPO}"
  clone_or_pull "https://github.com/darshandsoni/asciidoctor-skins.git"
  cp asciidoctor-skins/css/*.css "${dirname}/."
}

process_asciidoc() {
  (
    cd "${dirname}" || exit
    asciidoctor '**/*.adoc'
  )
}

publish() {
  rsync -a --exclude '*.adoc' "${dirname}/" /usr/share/nginx/html/
}

main "$@"
