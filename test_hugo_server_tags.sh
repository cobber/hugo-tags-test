#!/bin/sh

################################################################################
#
# Config
#

hugo_exe="hugo"
hugo_opts="--disableFastRender --quiet"
hugo_test_dir="tags_test/"
base_url="http://127.0.0.1:1313/"   # hugo doesn't listen to ::1
curl="curl"
curl_opts="-s"                      # add '-v' for more details
sleep=2                             # ample time for 'hugo server' to react to changes

################################################################################

print_environment() {
    log "# testing /tags/ updates in ${hugo_exe}"
    type "${hugo_exe}"  # which hugo
    "${hugo_exe}" version
    echo "system: " $( uname -a )
}

die_if_server_exists() {
    # don't start if hugo is already running
    if killall -s "${hugo_exe}" > /dev/null 2>&1
    then
        echo "${hugo_exe} seems to be running already."
        echo "stop it and try again."
        echo "e.g.: killall ${hugo_exe}"
        exit
    fi
}

die_if_dir_exists() {
    # don't clobber an existing test dir
    if [[ -d "${hugo_test_dir}" ]]
    then
        echo "${hugo_test_dir} already exists."
        echo "remove it and try again (or try again in an empty directory)."
        exit
    fi
}

setup_test_site() {
    echo
    log "# setting up new test hugo site in ${hugo_test_dir}"
    mkdir -p "${hugo_test_dir}"
    cd "${hugo_test_dir}"

    mkdir -p content/pages layouts/_default/

    echo "    - config.yaml"
    cat > config.yaml <<_CONFIG_
title: Hugo Server Tags Update Test
baseUrl: ${base_url}
_CONFIG_

    echo "    - layouts/_default/terms.html"
    cat > layouts/_default/terms.html <<_TERMS_TEMPLATE_
{{- range .Data.Terms.Alphabetical }}
    - {{ .Page.Title }}
{{- else }}
    no tags
{{- end -}}
_TERMS_TEMPLATE_
}

log() {
    echo $( date "+%H:%M:%S" ) "$@"
}

restart_hugo() {
    echo
    log "# restarting ${hugo_exe} server ${hugo_opts}"
    killall "${hugo_exe}" > /dev/null 2>&1
    if killall -s "${hugo_exe}" > /dev/null 2>&1
    then
        echo "oops - I could not restart ${hugo_exe}"
        exit
    fi

    {
    "${hugo_exe}" server ${hugo_opts} \
        | sed 's/^/    /'
    } &
    sleep ${sleep}
}

add_page() {
    page="$1"; shift
    tags="$1"; shift
    echo
    log "# creating content/pages/${page} with tags: ${tags}"
    cat > "content/pages/${page}.md" <<_PAGE_
---
titel: $page
tags:  $tags
---
_PAGE_
}

check_tags() {
    sleep ${sleep}
    echo
    log "# available tags:"
    ${curl} ${curl_opts} "${base_url}tags/"
    echo
}

################################################################################

print_environment

die_if_server_exists
die_if_dir_exists

setup_test_site

restart_hugo
add_page "page1" "[ one, two ]"
check_tags

restart_hugo
check_tags

add_page "page2" "[ three, four ]"
check_tags

add_page "page3" "[ five ]"
check_tags

restart_hugo
check_tags

exit
