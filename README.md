![Biome: a small script to manage a user's environment variables](https://raw.githubusercontent.com/1egoman/biome/master/resources/hero.png)

Biome is a simple way to manage your app's environment--all the flags and secrets that vary between deployments.

Biome stores the makeup of your app's environment, so when a new user or contributor wants to run
your app, Biome prompts them for all required secrets. 

Biome stores all your secrets in one place, away from version control. Environment details never
leave your local system.


























[![Licence](https://img.shields.io/npm/l/biome.svg)](http://spdx.org/licenses/ISC)

## Installation
```bash
npm install -g biome
```

## Usage
```bash
$ biome --help
  Usage: biome [options] [command]

  Commands:

    init [project]            Create a new project with the specified name, and save an alias to this folder.
    add [project]             Add a variable to a project. Specify like NAME=value.
    use [project]             Open a shell with a project's associated variables included.
    edit [project]            Open $EDITOR with the project's associated environment variables.
    vars [options] [project]  Echo all variables.

  Options:
    -h, --help     output usage information
    -V, --version  output the version number

  Examples:

  $ biome init project
  $ biome add project FOO=bar BAZ="I'm a teapot"
  $ biome use project
```

## Workflow
To set up an environment, first run `biome init project` to set up a new environment called
`project`. Then, to add new variables to an environment, run `biome add project KEY=value`. To
perform more complicated configurations, edit the environment directly with `biome edit project`.

Once you'd like to use the environment, run `biome use project`. A new instance of `$SHELL` will be
spawned containing all the configured variables, plus a few Biome-specific ones. To view your
current environment, type `biome`.

## How it works:
For each project, biome creates 2 files: a local `Biomefile` and a global `project.json`.
```
// Biomefile
{
  "name": "project"
}
// project.json
{
  "VARIABLE": "value"
}
```
The local `Biomefile` can be committed to source control because it just contains a reference to the
global project. The `project.json` is stored in `~/.biome/project.json`, where `project` is replaced
with the identifier in the `Biomefile`. This file is where the environment variables themselves are
actually stored. Since each user can have a separate `project.json` for each system, everyone can
customize their config to suit their needs.

Configuration
---
- `BIOME_LOCAL_NAME`: The name of the file in the project that references an environment. Defaults
  to `Biomefile`.
- `BIOME_FOLDER_NAME`: The name of the folder that biome stores all secrets within. Defaults to
  `~/.biome`.

### Tips and Tricks
- Want to include other environments into a project? Within the project's environment, add the
  special key `$include` mapping to an array of envornments. For example, `"$include": ["another",
  "environment", "here"]`.
- Easily give new users a simple way to enter values. Within the `Biomefile`, define a property
  called `template`. Each key of `template` should be the variable name, while each value should be
  its default value. For example:
```json
{
  "name": "my-project",
  "template": {
    "KEY": "value"
  }
}
```
  Then, when the user runs `biome init`, they'll be prompted for the values specified. Above, they'd
  be prompted for `KEY`, and given a default choice of "value".
- Don't want to hardcode templates into a project? As an argument to `biome init`, specify a
  template url after the project name, like `biome init project http://example.com/template.json`.


----------
Created by [Ryan Gaus](http://rgaus.net)
