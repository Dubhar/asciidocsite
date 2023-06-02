#!/usr/bin/env ash

main() {
  echo "$(date +"%Y-%m-%d %H:%MZ") - updating website"
  local reponame
  reponame=$(basename "${REPO}")
  local dirname
  dirname=${reponame%.*}

  update_git_files
  process_asciidoc
  publish
}

update_git_files() {
  if [ -d "${dirname}" ]; then
    (
      cd "${dirname}" || exit
      git -c core.sshCommand="ssh -i /ssh_key -o StrictHostKeyChecking=no" pull
    )
  else
    git -c core.sshCommand="ssh -i /ssh_key -o StrictHostKeyChecking=no" clone "${REPO}"
  fi
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
