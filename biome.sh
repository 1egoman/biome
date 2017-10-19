#!/bin/bash
# vim: set autoindent noexpandtab tabstop=4 shiftwidth=4 :
# Biome is a script that manages an isolated shell environment for a project.
# Written by Ryan Gaus

# From the CWD, find the nearest Biomefile.
# Walk backward from the pwd until the root. If there's a Biomefile, return it.
# Once at the root, (where dirname of a path equals the path itself), throw an error.
function get_biomefile {
	local find_prefix
	local last_find_prefix
	find_prefix="$(pwd)"

	while [[ ! -f "${find_prefix}/Biomefile" && ! -f "${find_prefix}/.Biomefile" ]]; do
		last_find_prefix="${find_prefix}"
		find_prefix="$(dirname "${last_find_prefix}")"

		if [[ "${find_prefix}" == "${last_find_prefix}" ]]; then
			return 1 # no biomefile was found
		fi
	done

	# Biomefile has preference over .Biomefile
	if [[ -f "${find_prefix}/Biomefile" ]]; then
		BIOMEFILE="${find_prefix}/Biomefile"
	else
		BIOMEFILE="${find_prefix}/.Biomefile"
	fi
}

function get_project {
	local passed_project="${1}"
	local passed_project_path="${HOME}/.biome/${1}.sh"

	# step 0: get the Biomefile path, if a project was not passed
	get_biomefile

	# step 1: if the passed project doesn't exist and there's a Biomefile, use the Biomefile.
	if ([[ "${passed_project}" == '' ]] || [[ ! -f "${passed_project_path}" ]]) && [[ -f "${BIOMEFILE}" ]]; then
		PROJECT=$(grep ^name "${BIOMEFILE}" | awk -F= '{print $2}')

	# if the passed project's path exists, then use the passed project
	elif [[ -f "${passed_project_path}" ]]; then
		# use passed project
		PROJECT="${passed_project}"

	# otherwise, throw an error
	elif [[ "${passed_project}" ]]; then
		echo "Error: no such project ${passed_project}."
		exit 2
	else
		echo "Error: please pass a project as an argument or create a Biomefile with biome init."
		exit 1
	fi

	PROJECT_PATH="${HOME}/.biome/${PROJECT}.sh"
}

function set_meta_vars {
	export BIOME_SHELL="true"
	export BIOME_PROJECT="${PROJECT}"

	# add the project name to the shell prompt if possible and necessary
	if [[ -n "${BASH_VERSION}" ]] && [[ -z "${BIOME_SHELL_INIT_CFG}" ]]; then
		INITIAL_PROMPT_COMMAND="${PROMPT_COMMAND}"
		export PROMPT_COMMAND="[[ -z \"\${BIOME_SHELL_INIT_CFG}\" ]] && PS1=\"($PROJECT) \${PS1}\"; unset PROMPT_COMMAND"
	fi
}

function unset_meta_vars {
	unset BIOME_SHELL
	unset BIOME_PROJECT

	# reset any modifications involving the shell prompt
	if [[ -n "${BASH_VERSION}" ]] && [[ -z "${BIOME_SHELL_INIT_CFG}" ]]; then
		PROMPT_COMMAND="${INITIAL_PROMPT_COMMAND}"
	fi
}

function get_variable {
	read -r -p "Enter a variable name you'd like to add, or [Enter] to finish. " VAR_NAME

	if [[ "${VAR_NAME}" ]]; then
		read -r -p "Enter ${VAR_NAME}'s default value, or leave empty for none. " VAR_DEFAULT
	fi
}

function make_template_project {
	cat <<-EOF > "${HOME}/.biome/${PROJECT}.sh"
	# A file that contains environment variables for a project
	# Activate me with biome use ${PROJECT}
	# add variables like export FOO="bar"
	# include other variables with source /path/to/more/vars
	EOF
}

# Get all defined variables in the Biomefile, and ask the user for their values. Stick these in
# ~/.biome/${PROJECT}.sh
function fetch_var_values {
	get_biomefile

	if [[ -f "${BIOMEFILE}" ]]; then
		while read -r -u 10 i; do
			if [[ ! "${i}" =~ ^# ]] && [[ "${i}" != '' ]]; then # not a comment or empty line
				# get the variable name, its default value
				VARIABLE_NAME="$(echo "${i}" | sed 's/=.*//')"
				VARIABLE_DEFAULT_VALUE="$(echo "${i}" | cut -f2- -d'=')"

				# also, get whether it's been set already.
				if [[ -f "${PROJECT_PATH}" ]]; then
					VARIABLE_ALREADY_SET="$(grep "^export ${VARIABLE_NAME}" "${PROJECT_PATH}")"
				else
					VARIABLE_ALREADY_SET=''
				fi

				if [[ "${VARIABLE_ALREADY_SET}" != '' ]] && [[ "${VARIABLE_NAME}" != "name" ]]; then
					echo "${VARIABLE_NAME} has been defined. Run biome edit to change its value."
				elif [[ "${VARIABLE_NAME}" != "name" ]]; then
					read -r -p "Value for ${VARIABLE_NAME}? (${VARIABLE_DEFAULT_VALUE}) " VARIABLE_VALUE

					# replace the value with the default if the user didn't enter anything
					if [[ "${VARIABLE_VALUE}" == '' ]]; then
						VARIABLE_VALUE=${VARIABLE_DEFAULT_VALUE}
					fi

					echo "export ${VARIABLE_NAME}=\"${VARIABLE_VALUE}\"" >> "${HOME}/.biome/${PROJECT}.sh"
				fi
			fi
		done 10< "${BIOMEFILE}"
	else
		echo "There isn't a Biomefile here. To create a new project, run biome init."
		echo "For help, run biome help."
		exit 2
	fi
}

# if ~/.biome doesn't exist, make it
if [[ ! -d "${HOME}/.biome" ]]; then
	mkdir "${HOME}/.biome"

	# add .bash_profile code for biome child shells
	if [[ -n "${BASH_VERSION}" ]] && [[ -f "${HOME}/.bash_profile" ]]; then
		echo -e "
# biome configuration
export BIOME_SHELL_INIT_CFG=\"true\"
if [[ ! -z \"\${BIOME_PROJECT}\" ]]; then
	export PS1=\"(\${BIOME_PROJECT}) \${PS1}\"
fi" >> ~/.bash_profile
	fi
fi

# Parse the arguments for flags
for arg in "${@}"; do
	case ${arg} in
		-h|--hidden) HIDDEN=true;;
	esac
done

# all the different subcommands
case ${1} in
# Install all variables into the global project config
'')
	get_project "${2}"
	fetch_var_values
	echo "All variables for ${PROJECT} have been defined. To start this environment, run biome use."
	;;

# given a project, source it into the current shell. Creates a 'biome shell'.
use)
	get_project "${@:2}" # allow mutltiple words
	echo "Sourcing ${PROJECT} from ${PROJECT_PATH}"

	# Spawn a new shell
	set_meta_vars
	bash -c "$(cat "${PROJECT_PATH}") && ${SHELL} -l"
	unset_meta_vars
	;;

# When in a biome shell, update variables to their latest values.
# For example:
# biome use
# $ # change the defined values with biome edit
# $ . biome inject
# $ # now the values are updated following edits
inject)
	# is being sourced?
	if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
		echo "Error: please source this script by either running \`. biome inject\` or \`source biome inject\`"
		exit 1
	fi


	# if already inside of a biome shell, update its contents.
	if [[ "${BIOME_PROJECT}" != '' ]]; then
		BIOME_PROJECT_NO_WHITESPACE="$(echo "${BIOME_PROJECT}" | sed 's/ //g')"
		PROJECT_PATH="${HOME}/.biome/${BIOME_PROJECT_NO_WHITESPACE}.sh"
		source "${PROJECT_PATH}"
		echo "Injected data from ${BIOME_PROJECT_NO_WHITESPACE}."
	else
		echo "Not in a Biome shell. Run \`biome use\` to enter one with your current config."
	fi
	;;

# edit a specified project
edit)
	get_project "${2}"

	if [[ "${EDITOR}" ]]; then
		"${EDITOR}" "${PROJECT_PATH}"
	else
		vi "${PROJECT_PATH}"
	fi

	echo "Note: if you have any biome sessions open, make sure you run biome inject to copy any
	edits you just made to each session."
	;;

# Create a new local Biomefile and associated template
init)
	get_biomefile

	if [[ ! -f "${BIOMEFILE}" ]]; then
		read -r -p "Name of project? " PROJECT
		PROJECT_PATH="${HOME}/.biome/${PROJECT}.sh"

		if [[ -f "${PROJECT_PATH}" ]]; then
			# when it already exists...
			echo "This project already exists. If you'd like to overwrite it, run rm ~/.biome/${PROJECT}.sh then run this again."
		else
			if [[ ${HIDDEN} == true ]]; then
				BIOMEFILENAME=".Biomefile";
			else
				BIOMEFILENAME="Biomefile";
			fi

			echo "# This is a Biomefile. It helps you create an environment to run this app." > "${BIOMEFILENAME}"
			echo "# More info at https://github.com/1egoman/biome" >> "${BIOMEFILENAME}"
			echo "name=${PROJECT}" >> "${BIOMEFILENAME}"

			# get variables
			get_variable
			while [[ "${VAR_NAME}" ]]; do
				echo "${VAR_NAME}=${VAR_DEFAULT}" >> "${BIOMEFILENAME}"
				get_variable
			done

			# create a new project
			make_template_project
			echo
			echo "Ok, let's set up your local environment."
			fetch_var_values

			# make a commit with git
			echo "The environment ${PROJECT} has been created. To start this environment, run biome use."
		fi
	else
		echo "Error: Biomefile exists. To start using this environment on your system run 'biome'"
		exit 3
	fi
	;;

# Nuke the specified project's environment and Biomefile
rm)
	get_project "${2}"
	if [[ -f "${HOME}/.biome/${PROJECT}.sh" ]]; then
		rm "${HOME}/.biome/${PROJECT}.sh"
		echo "Removed your environment. Run biome to re-configure."
	else
		echo "Error: There isn't an environment for this project."
		exit 2
	fi
	;;

help)
	echo "usage: biome <command>"
	echo
	echo "Commands:"
	echo -e "  init [-h|--hidden]\\tCreate a new environment for the project in the current directory. Use --hidden flag to use a hidden .Biomefile."
	echo -e "  edit\\tEdit the environment in the current directory."
	echo -e "  use\\tSpawn a subshell with the project in the cwd's sourced environment."
	echo -e "  inject\\tUpdate a new environment with changes since it has been activated with biome use."
	echo -e "  rm\\tDelete a project's environment so it can be reconfigured."
	echo -e "  (no command)\\tGiven the template specified in the Biomefile, create a new environment for your app."
	echo
	echo "Set up a new project:"
	echo "  - Run biome init to make a new environment. You'll be prompted for a name and the default configuration."
	echo "  - Run biome use to try out your new environment. Leave the environment by running exit."
	echo "  - Make any changes to your environment with biome edit"
	echo
	echo "Create a new environment in a project that already uses Biome:"
	echo "  - Run biome. You'll be prompted for all the configuration values that the Biomefile contains."
	echo "  - Run biome use to try out your new environment. Leave the environment by running exit."
	echo
	;;

*)
	echo "Hmm, I don't know how to do that. Run biome help for assistance."
	exit 1
	;;

esac
