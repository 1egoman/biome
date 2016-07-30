#!/bin/env bats
# a quick note: this file uses tabs to ensure that <<-EOF will work properly. Please use tabs too!

function setup {
	BIOME="$(pwd)/biome.sh"
	TEST_ROOT="$(pwd)/test"
	clean_test
}

# reset the test location
function clean_test {
	cd $TEST_ROOT
	rm -R workspace/
	mkdir workspace
	mkdir workspace/cwd
	mkdir workspace/home
	OLDHOME="$HOME"
	HOME="$(pwd)/workspace/home"
	cd workspace/cwd
}

# ----------------------------------------------------------------------------
# biome init
# ------------------------------------------------------------------------------

@test "biome init will initialize a new project" {
	INPUT="$(cat <<-EOF
	my_app
	FOO
	bar
	EOF)"

	echo "$INPUT" | $BIOME init
	$(cmp $HOME/.biome/my_app.sh <<-EOF
		# A file that contains environment variables for a project
		# Activate me with biome use my_app
		# add variables like export FOO="bar"
		# include other variables with source /path/to/more/vars
		export FOO="bar"
	EOF)
}

@test "biome init will initialize a new project with values" {
	INPUT="$(cat <<-EOF
	my_app
	FOO
	bar

	baz
	EOF)"

	echo "$INPUT" | $BIOME init
	$(cmp $HOME/.biome/my_app.sh <<-EOF
		# A file that contains environment variables for a project
		# Activate me with biome use my_app
		# add variables like export FOO="bar"
		# include other variables with source /path/to/more/vars
		export FOO="baz"
	EOF)
}

@test "biome init will fail with a Biomefile" {
	touch Biomefile

	run $BIOME init
	[ "$status" -eq 1 ]
}

@test "biome init will fail with a preexisting environment" {
	echo "name=my_app" > Biomefile
	mkdir -p $HOME/.biome
	touch $HOME/.biome/my_app.sh

	run $BIOME init
	[ "$status" -eq 1 ]
}

# ----------------------------------------------------------------------------
# biome
# ------------------------------------------------------------------------------

@test "biome will create the environment that's defined in the Biomefile" {
	cat <<-EOF > Biomefile
	name=my_app
	FOO=hello
	BAR=world
	BAZ=
	EOF

	INPUT="$(cat <<-EOF
	data

	more data
	EOF)"
	echo "$INPUT" | $BIOME

	chmod 700 $HOME/.biome/my_app.sh
	$(cmp $HOME/.biome/my_app.sh <<-EOF
		export FOO="data"
		export BAR="world"
		export FOO="more data"
	EOF)
}

@test "biome will append to an already existing environment" {
	# create Biomefile ane pre-initialized data
	cat <<-EOF > Biomefile
	name=my_app
	ALREADY_EXISTS=
	FOO=hello
	BAR=world
	BAZ=
	EOF
	mkdir -p $HOME/.biome
	cat <<-EOF > $HOME/.biome/my_app.sh
	export ALREADY_EXISTS="hello"
	EOF

	INPUT="$(cat <<-EOF
	data

	more data
	EOF)"
	echo "$INPUT" | $BIOME

	chmod 700 $HOME/.biome/my_app.sh
	$(cmp $HOME/.biome/my_app.sh <<-EOF
		export ALREADY_EXISTS="hello"
		export FOO="data"
		export BAR="world"
		export FOO="more data"
	EOF)
}

# ----------------------------------------------------------------------------
# biome use
# ------------------------------------------------------------------------------

@test "biome use will spawn a subshell with the correct environment vars set" {
	# create Biomefile ane pre-initialized data
	cat <<-EOF > Biomefile
	name=my_app
	EOF
	mkdir -p $HOME/.biome
	cat <<-EOF > $HOME/.biome/my_app.sh
	export A_VARIABLE="value"
	EOF

	# log all environment variables within the shell to ~/environment
	OLDSHELL="$SHELL"
	SHELL="bash -c 'env > $HOME/environment'"
	run $BIOME use # use run so the command will always run so the shell can be reset
	SHELL="$OLDSHELL"

	chmod 700 $HOME/.biome/my_app.sh
	# these variables should be set
	[[ "$(cat $HOME/environment | grep A_VARIABLE=value)" != "" ]] &&
	[[ "$(cat $HOME/environment | grep BIOME_SHELL=true)" != "" ]] &&
	[[ "$(cat $HOME/environment | grep BIOME_PROJECT=my_app)" != "" ]];
}






HOME="$OLDHOME"
