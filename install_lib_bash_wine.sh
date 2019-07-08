#!/bin/bash

# function include_dependencies {
#     my_dir="$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )"  # this gives the full path, even for sourced scripts
#     source "${my_dir}/lib_color.sh"
#     source "${my_dir}/lib_helpers.sh"
#
# }
#
# include_dependencies  # we need to do that via a function to have local scope of my_dir

function get_sudo_exists {
    # we need this for travis - there is no sudo command !
    if [[ -f /usr/bin/sudo ]]; then
        echo "True"
    else
        echo "False"
    fi
}

function get_sudo_command {
    # we need this for travis - there is no sudo command !
    if [[ $(get_sudo_exists) == "True" ]]; then
        local sudo_command="sudo"
        echo ${sudo_command}
    else
        local sudo_command=""
        echo ${sudo_command}
    fi
}

function set_lib_bash_wine_permissions {
    local sudo_command=$(get_sudo_command)
    ${sudo_command} chmod -R 0755 /usr/lib/lib_bash_wine
    ${sudo_command} chmod -R +x /usr/lib/lib_bash_wine/*.sh
    ${sudo_command} chown -R root /usr/lib/lib_bash_wine
    ${sudo_command} chgrp -R root /usr/lib/lib_bash_wine
}

function install_lib_bash_wine_if_not_exist {
    if [[ ! -d "/usr/lib/lib_bash_wine" ]]; then
        echo "installing lib_bash_wine"
        $(get_sudo_command) git clone https://github.com/bitranox/lib_bash.git /usr/lib/lib_bash_wine > /dev/null 2>&1
        set_lib_bash_wine_permissions
    fi
}

function get_lib_bash_wine_needs_update {
    local git_remote_hash=$(git --no-pager ls-remote --quiet https://github.com/bitranox/lib_bash_wine.git | grep HEAD | awk '{print $1;}' )
    local git_local_hash=$( $(get_sudo_command) cat /usr/lib/lib_bash_wine/.git/refs/heads/master)
    if [[ "${git_remote_hash}" == "${git_local_hash}" ]]; then
        echo "False"
    else
        echo "True"
    fi
}

function update_lib_bash_wine_if_exist {
    if [[ -d "/usr/lib/lib_bash_wine" ]]; then
        if [[ $(get_lib_bash_wine_needs_update) == "True" ]]; then
            echo "lib_bash_wine needs to update"
            (
                # create a subshell to preserve current directory
                cd /usr/lib/lib_bash_wine
                local sudo_command=$(get_sudo_command)
                ${sudo_command} git fetch --all  > /dev/null 2>&1
                ${sudo_command} git reset --hard origin/master  > /dev/null 2>&1
                set_lib_bash_wine_permissions
            )
            echo "lib_bash_wine update complete"
        else
            echo "lib_bash_wine is up to date"
        fi
    fi
}


update_lib_bash_wine_if_exist
install_lib_bash_wine_if_not_exist
