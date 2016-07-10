![Biome: a small script to manage a user's environment variables](https://raw.githubusercontent.com/1egoman/biome/master/resources/hero.png)

[![CircleCI](https://circleci.com/gh/1egoman/biome.svg?style=svg&circle-token=5cd1a8690f148661881840c868009db16f10370f)](https://circleci.com/gh/1egoman/biome)

Manage environment variables in a sane way. Never push up secrets again!
- Enforces a clear separation of secrets and code.
- All secrets are in one configurable place. (by default, `~/.biome`)
- Associate any number of variables with any number of projects.
- Easily create complex variable structures that inherit from one-another.

Installation
===
```bash
npm install -g biome
```

Usage
===
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

Workflow
===
To set up an environment, first run `biome init project` to set up a new environment called
`project`. Then, to add new variables to an environment, run `biome add project KEY=value`. To
perform more complicated configurations, edit the environment directly with `biome edit project`.

Once you'd like to use the environment, run `biome use project`. A new instance of `$SHELL` will be
spawned containing all the configured variables, plus a few Biome-specific ones. To view your
current environment, type `biome`.

Behind the scenes
===

- `biome init`
  Creates a new project and links it with the project in the current directory.
- `biome add`
  Add a variable to the current or specified project
- `biome use`
  Open a subshell sourcing the current or specified project.
- `$include within the project.json file`
- `BIOME_LOCAL_NAME`
- `BIOME_FOLDER_NAME`

How it works:
---
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

# Global files
A `~/.biome` folder with a json file for each project:
like `.biome/name.json`:
```
{
  "NODE_ENV": "development",
  "S3_BUCKET_URL": "http://example.com",
  (... and more)
}
```

`biome init project` will create a `.biome` file locally containing:
```
{
  "name": "project"
}
```

Also:
```
biome use [project]
biome add NODE_ENV=development
```

# User flow
1. User downloads biome: `npm i -g biome`
2. User cds to project
3. User runs `biome init project`
  - Biome creates `~/.biome` folder if it doesn't already exist
  - Biome creates `~/.biome/project.json` and writes `{}`
  - Biome puts `{"name": "project"}` into `$PWD/.biome`
4. User wants to mess with a project, so runs `biome use`
  - Looks for local `.biome` file
    - Doesn't exist -> error
    - Exists?
      - Find the `name` inside.
      - Search through `~/.biome` to find a matching name
      - create all env variables inside
      - Profit?
5. User wants to add to a project, so runs `biome add NAME=value`
  - Looks for local `.biome` file
    - Doesn't exist -> error
    - Exists?
      - Find the `name` inside.
      - Search through `~/.biome` to find a matching name
      - add env variable as a key
