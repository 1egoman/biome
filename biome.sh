#!/bin/bash
# Biome is a script that manages an isolated shell environment for a project.
# Written by Ryan Gaus

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
    read -p "Enter $VAR_NAME's default value, or leave empty for none. " VAR_DEFAULT
  fi
}
function make_template_project {
cat <<EOF > ~/.biome/$PROJECT.sh
# A file that contains environment variables for a project
# Activate me with biome use $PROJECT
# add variables like export FOO="bar"
# include other variables with source /path/to/more/vars
EOF
}

# Get all defined variables in the Biomefile, and ask the user for their values. Stick these in
# ~/.biome/$PROJECT.sh
function fetch_var_values {
  if [[ -f "Biomefile" ]]; then
    while read -u 10 i; do
      if [[ ! "$i" =~ ^# ]]; then # not a comment
        # get the value
        VARIABLE_NAME=$(echo $i | sed 's/=.*//')
        VARIABLE_DEFAULT_VALUE=$(echo $i | cut -f2- -d'=')
        if [[ "$VARIABLE_NAME" != "name" ]]; then
          read -p "Value for $VARIABLE_NAME? ($VARIABLE_DEFAULT_VALUE) " VARIABLE_VALUE

          # replace the value with the default
          if [[ "$VARIABLE_VALUE" == "" ]]; then
            VARIABLE_VALUE=$VARIABLE_DEFAULT_VALUE
          fi

          echo export $VARIABLE_NAME=\"$VARIABLE_VALUE\" >> $HOME/.biome/$PROJECT.sh
        fi
      fi
    done 10< Biomefile
  else
    echo "There isn't a Biomefile here. To create a new project, run biome init."
    echo "For help, run biome help."
    exit 1
  fi
}

# if ~/.biome doesn't exist, make it
if [[ ! -d "$HOME/.biome" ]]; then
  mkdir $HOME/.biome
fi

# all the different subcommands
case $1 in

# given a project, source it into the current shell
use)
  get_project $2
  echo Sourcing $PROJECT from $PROJECT_PATH

  # Spawn a new shell
  set_meta_vars
  bash -c "$(cat $PROJECT_PATH) && bash -l"
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

# Create a new local Biomefile and associated template
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
      make_template_project
      echo
      fetch_var_values

      # make a commit with git
      echo "Nice! To use this environment, run biome use!"
    fi
  else
    echo "Error: Biomefile exists. To re-init, remove the local Biomefile and try again."
    exit 1
  fi
  ;;

# Nuke the specified project's environment and Biomefile
rm)
  get_project $2
  if [[ -f "Biomefile" ]]; then
    rm Biomefile
    rm $HOME/.biome/$PROJECT.sh
    echo "Removed local Biomefile and your environment."
  else
    echo "Error: There isn't a Biomefile here."
    exit 1
  fi
  ;;

help)
  echo "Commands:"
  echo "  biome init <project> - Create a new project in the current directory."
  echo "  biome edit [project] - Edit the current or the specified project."
  echo "  biome use [project] - Spawn a subshell containing a project's variables."
  echo "  biome rm [project] - Deleta a project;s environment and Biomefile."
  echo "  biome - Prompt for any template variables and add them to the ~/.biome/project.sh file."
  echo "(A good place to start is biome init project)."
  ;;

# Install all variables into the global project config
*)
  get_project $2
  fetch_var_values
  echo "Great! To use these variables, run biome use $PROJECT"
  ;;
esac
