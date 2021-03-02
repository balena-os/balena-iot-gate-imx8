CL_FUNCTIONS=/usr/share/cl-deploy/cl-functions.inc
if [[ ! -f ${CL_FUNCTIONS} ]];then
cat << eof
The package library file ${CL_FUNCTIONS} is not found.
Reinstall the cl-deploy package.
eof
exit 3
fi

source ${CL_FUNCTIONS}

conf=/etc/cl-auto.conf
sample=/usr/share/cl-deploy/cl-auto.conf.sample

show_conf() {
[[ -f ${conf} ]] && cat ${conf} || cat <<< "${conf} not found"
}

get_mode() {
[[ $(basename $(readlink /sbin/init)) == 'cl-init' ]] && echo "on" || echo "off"
}

get_auto_device() {
dev_name=$(get_root_device)
echo ${dev_name}
}

usage () {
cat << eof
  on/E -- Enable auto install boot mode
 off/D -- Disable auto install boot mode
     M -- Modify ${conf} file
     C -- Copy ${sample} file to /etc/cl-auto.conf
     G -- Start autoinstaller now
     X -- Exit cl-auto.shell
     B -- Fast reboot

Conf file:
$(show_conf)

eof
}

PS1='$(usage)\n\nautoinstaller ( device: $(get_auto_device) ;  boot mode : $(get_mode) ) > '
set -m

alias G='cl-auto'
alias E='cl-auto -A'
alias on='cl-auto -A'
alias D='cl-auto -a'
alias off='cl-auto -a'
alias C='cl-auto -c'
alias M='vi ${conf}'
alias X='exit'
alias B='cl-reboot'
