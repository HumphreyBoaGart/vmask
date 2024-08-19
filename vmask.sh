#!/bin/bash

### All script functions are thrown in a simple case statement
case $1 in

### Script documentation with 'vmask help'
help | -h | --help)
exec cat <<EOF

  $(tput bold)LIST ALL AVAILABLE MASKS:$(tput sgr0)
    $(tput setaf 3)$ vmask list$(tput sgr0)

  $(tput bold)TAKE A MASK OUT OF STORAGE:$(tput sgr0)
    $(tput setaf 3)$ vmask on MASKNAME$(tput sgr0)

  $(tput bold)PUT MASK BACK INTO STORAGE:$(tput sgr0)
    $(tput setaf 3)$ vmask off MASKNAME$(tput sgr0)

  $(tput bold)GENERATE NEW MASK & SAVE TO STORAGE:$(tput sgr0)
    $(tput setaf 3)$ vmask new$(tput sgr0)

    $(tput bold)Or, to bypass interactive mode:$(tput sgr0)
    $(tput setaf 3)$ vmask new MASKNAME PORT$(tput sgr0)

    $(tput bold)Do not put two masks on the same port!$(tput sgr0)
    If you are only pulling out one mask at a time,
    this is not a big deal. HOWEVER, if you are
    planning on activating multiple masks at once,
    you will run into problems if more than one
    mask is configured to use the same port.

  $(tput bold)DELETE A MASK FROM STORAGE:$(tput sgr0)
    $(tput setaf 3)$ vmask del MASKNAME$(tput sgr0)

  $(tput bold)COMMAND DOCUMENTATION:$(tput sgr0)
    $(tput setaf 3)$ vmask help$(tput sgr0)

EOF
;;

### List available masks with 'vmask list'
list)
  exec ls -I "*.*" --color=always $HOME/.config/vmask/data
;;

### Take mask out of storage with 'vmask on'
on)
  if [[ $2 != '' ]]; then
    exec docker compose -f $HOME/.config/vmask/data/$2/compose.yaml up -d
  else
    exec echo " $(tput setaf 1 bold)ERROR: You did not state which mask to wear!$(tput sgr0)"
  fi
;;

### Put mask back in storage with 'vmask off'
off)
  if [[ $2 != '' ]]; then
    docker kill $2-gluetun $2-firefox
    docker rm $2-gluetun $2-firefox
    docker network rm $2_default
  else
    exec echo " $(tput setaf 1 bold)ERROR: You did not state which mask to take off!$(tput sgr0)"
  fi
;;

### Generate new mask with 'vmask new'
new)
  if [[ $2 != '' && $3 != '' ]]; then
    name=${2// /_}
    name=${name//[^a-zA-Z0-9_]/}
    port=${3//[^0-9]/}
  elif [[ $2 != '' && $3 == '' ]]; then
    exec echo " $(tput setaf 1 bold)ERROR: Port number required to bypass interactive mode!$(tput sgr0)"
  else
    echo " $(tput setaf 6 bold)Please enter a name for your new mask:$(tput sgr0)"
    echo -n "  (alphanumeric only) "
    read -r name
    echo " $(tput setaf 6 bold)What port should we access this mask with?$(tput sgr0)"
    echo -n "  (numerals only) "
    read -r port
    name=${name// /_}
    name=${name//[^a-zA-Z0-9_]/}
    port=${port//[^0-9]/}
  fi
  if [[ $name != '' && $port != '' ]]; then
    mkdir -pv $HOME/.config/vmask/data/$name/storage
    cp -v $HOME/.config/vmask/skel/compose.yaml $HOME/.config/vmask/data/$name/compose.yaml
    sed -i -e 's/{{MASKNAME}}/'$name'/g' $HOME/.config/vmask/data/$name/compose.yaml
    sed -i -e 's/{{PORTNUM}}/'$port'/g' $HOME/.config/vmask/data/$name/compose.yaml
    sed -i -e 's/{{HOMEUSER}}/'$USER'/g' $HOME/.config/vmask/data/$name/compose.yaml
  else
    exec echo " $(tput setaf 1 bold)ERROR: You did not define all the attributes!$(tput sgr0)"
  fi
;;

### Delete existing mask with 'vmask del'
del)
  if [[ $2 != '' ]]; then
    exec rm -rfv $HOME/.config/vmask/data/$2
  else
    exec echo " $(tput setaf 1 bold)ERROR: You did not enter a name!$(tput sgr0)"
  fi
;;

### Output error for any input not explicitly defined
*)
  exec echo " $(tput setaf 1 bold)ERROR: No valid command specified!$(tput sgr0)"
;;

### Close case statement and move on with our life
esac
