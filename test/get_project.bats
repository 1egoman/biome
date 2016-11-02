#!/bin/bash
load test_helper

@test "get_project should get a project by a passed name" {
	mkdir -p "$HOME/.biome"
	cat <<-EOF > $HOME/.biome/my_app.sh
	export A_VARIABLE="value"
	EOF

	$BIOME rm my_app

	run cat $HOME/.biome/my_app.sh # (the file should not exist)
	[[ "$status" == 1 ]]
}

@test "get_project should get a project by an implicit Biomefile" {
	cat <<-EOF > Biomefile
	name=my_app
	EOF

	mkdir -p "$HOME/.biome"

	cat <<-EOF > $HOME/.biome/my_app.sh
	export A_VARIABLE="value"
	EOF

	$BIOME rm

	run cat "$HOME/.biome/my_app.sh" # (the file should not exist)
	[[ "$status" == 1 ]]
}

@test "get_project should use the passed project over the Biomefile" {
	cat <<-EOF > Biomefile
	name=some_other_app
	EOF
	mkdir -p "$HOME/.biome"
	cat <<-EOF > $HOME/.biome/my_app.sh
	export A_VARIABLE="value"
	EOF

	$BIOME rm my_app

	run cat "$HOME/.biome/my_app.sh" # (the file should not exist)
	[[ "$status" == 1 ]]
}

@test "get_project should fail without a Biomefile or passed project" {
	# no Biomefile
	run $BIOME rm
	[[ "$status" == 1 ]]
}
