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
  elif [[ "$PASSED_PROJECT" ]]; then
    echo "Error: no such project $PASSED_PROJECT."
    exit 1
  else
    echo "Error: please pass a project as an argument or create a Biomefile with biome init."
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
        # get the variable name, its default value
        VARIABLE_NAME=$(echo $i | sed 's/=.*//')
        VARIABLE_DEFAULT_VALUE=$(echo $i | cut -f2- -d'=')

        # also, get whether it's been set already.
        if [[ -f "$PROJECT_PATH" ]]; then
          VARIABLE_ALREADY_SET=$(cat $PROJECT_PATH | grep "^export $VARIABLE_NAME")
        else
          VARIABLE_ALREADY_SET=""
        fi

        if [[ "$VARIABLE_ALREADY_SET" != "" ]] && [[ "$VARIABLE_NAME" != "name" ]]; then
          echo "$VARIABLE_NAME has been defined. Run biome edit to change its value."
        elif [[ "$VARIABLE_NAME" != "name" ]]; then
          read -p "Value for $VARIABLE_NAME? ($VARIABLE_DEFAULT_VALUE) " VARIABLE_VALUE

          # replace the value with the default if the user didn't enter anything
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
# Install all variables into the global project config
'')
  get_project $2
  fetch_var_values
  echo "All variables for $PROJECT have been defined. To start this environment, run biome use."
  ;;

# given a project, source it into the current shell
use)
  get_project $2
  echo Sourcing $PROJECT from $PROJECT_PATH

  # Spawn a new shell
  set_meta_vars
  bash -c "$(cat $PROJECT_PATH) && $SHELL -l"
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
      echo "# This is a Biomefile. It helps you create an environment to run this app." > Biomefile
      echo "# More info at https://github.com/1egoman/biome" >> Biomefile
      echo "name=$PROJECT" >> Biomefile

      # get variables
      get_variable
      while [[ "$VAR_NAME" ]]; do
        echo "$VAR_NAME=$VAR_DEFAULT" >> Biomefile
        get_variable
      done

      # create a new project
      make_template_project
      echo
      echo "Ok, let's set up your local environment."
      fetch_var_values

      # make a commit with git
      echo "The environment $PROJECT has been created. To start this environment, run biome use."
    fi
  else
    echo "Error: Biomefile exists. To re-init, remove the local Biomefile and try again."
    exit 1
  fi
  ;;

# Nuke the specified project's environment and Biomefile
rm)
  get_project $2
  if [[ -f "$HOME/.biome/$PROJECT.sh" ]]; then
    rm $HOME/.biome/$PROJECT.sh
    echo "Removed your environment. Run biome to re-configure."
  else
    echo "Error: There isn't an environment for this project."
    exit 1
  fi
  ;;

help)
  echo "Usage: biome COMMAND [project]"
  echo
  echo "Commands:"
  echo "  biome init <project> - Create a new project in the current directory."
  echo "  biome edit [project] - Edit the current or the specified project."
  echo "  biome use [project] - Spawn a subshell containing a project's variables."
  echo "  biome rm [project] - Delete a project's environment so it can be reconfigured."
  echo "  biome - Prompt for any template variables and add them to the ~/.biome/project.sh file."
  echo
  echo "Set up a new project:"
  echo "  - Run biome init to create a new Biomefile to be used as template for setting up your envionment in the future."
  echo "  - Run biome use to try your new environment."
  echo "  - Profit?"
  ;;

*)
  echo "Hmm, I don't know how to do that. Run biome help for assistance."
  exit 1
  ;;

esac
