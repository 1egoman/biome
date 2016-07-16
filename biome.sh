#!/bin/bash

# I want to create one:
# $ biome init

# biome init project

function get_project {
  PASSED_PROJECT=$1
  PASSED_PROJECT_PATH="$HOME/.biome/$1.sh"

  # step 1: if the passed project doesn't exist and there's a Biomefile, use the Biomefile.
  if ([[ "$PASSED_PROJECT" == "" ]] || [[ ! -f "$PASSED_PROJECT_PATH" ]]) && [[ -f "Biomefile" ]]; then
    PROJECT=$(cat Biomefile | grep ^name | cut -f2- -d'=')

  # if the passed project's path exists, then use the passed project
  elif [[ -f "$PASSED_PROJECT_PATH" ]]; then
    # use passed project
    PROJECT=$PASSED_PROJECT

  # otherwise, throw an error
  else
    echo "Error: no such project $PASSED_PROJECT."
    exit 1
  fi

  PROJECT_PATH="$HOME/.biome/$PROJECT.sh"
}

function set_meta_vars {
  export BIOME_SHELL="true"
  export BIOME_PROJECT="$PROJECT"
}
function unset_meta_vars {
  unset BIOME_SHELL
  unset BIOME_PROJECT
}

function get_variable {
  read -p "Enter a variable name you'd like to add. " VAR_NAME
  if [[ "$VAR_NAME" ]]; then
    read -p "Enter a default value, or leave empty for none. " VAR_DEFAULT
  fi
}

# all the different subcommands
case $1 in

# given a project, source it into the current shell
use)
  get_project $2
  echo Sourcing $PROJECT from $PROJECT_PATH

  # Spawn a new shell
  set_meta_vars
  bash -c "$(cat $PROJECT_PATH) && bash"
  unset_meta_vars
  ;;

# edit a specified project
edit)
  get_project $2
  if [[ "$EDITOR" ]]; then
    $EDITOR $PROJECT_PATH
  else
    vi $PROJECT_PATH
  fi
  ;;

# TODO: read through a template from the Biomefile and ask for variables
install)
  get_project $2
  echo $PROJECT_PATH
  touch $HOME/.biome/$PROJECT.sh
  cat $HOME/.biome/$PROJECT.sh
  while read -u 10 i; do
    # get the valu
    VARIABLE_NAME=$(echo $i | sed 's/=.*//')
    VARIABLE_DEFAULT_VALUE=$(echo $i | cut -f2- -d'=')
    read -p "Value for $VARIABLE_NAME? ($VARIABLE_DEFAULT_VALUE) " VARIABLE_VALUE

    # replace the value with the default
    if [[ "$VARIABLE_VALUE" == "" ]]; then
      VARIABLE_VALUE=$VARIABLE_DEFAULT_VALUE
    fi

    echo export $VARIABLE_NAME=\"$VARIABLE_VALUE\" >> $HOME/.biome/$PROJECT.sh
  done 10< Biomefile
  ;;

# biome init abc
init)
  if [[ ! -f "Biomefile" ]]; then
    read -p "Name of project? " PROJECT
    PROJECT_PATH="$HOME/.biome/$PROJECT.sh"

    if [[ -f "$PROJECT_PATH" ]]; then
      # when it already exists...
      echo "This project already exists. If you'd like to overwrite it, run rm ~/.biome/$PROJECT.sh then run this again."
    else
      echo "name=$PROJECT" > Biomefile

      # get variables
      get_variable
      while [[ "$VAR_NAME" ]]; do
        echo "$VAR_NAME=$VAR_DEFAULT" >> Biomefile
        get_variable
      done

      # create a new project
      cat <<EOF > ~/.biome/$PROJECT.sh
# A file that contains environment variables for a project
# Activate me with biome use $PROJECT
# add variables like export FOO="bar"
# include other variables with source /path/to/more/vars
EOF

    fi
  fi
  ;;

*)
  echo "No such command. Please run biome --help for help."
  ;;
esac
