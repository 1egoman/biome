# Biome
A small script to manage a project's environment variables.

[![CircleCI](https://circleci.com/gh/1egoman/biome.svg?style=svg&circle-token=5cd1a8690f148661881840c868009db16f10370f)](https://circleci.com/gh/1egoman/biome)

- `biome init`
  Creates a new project and links it with the project in the current directory.
- `biome add`
  Add a variable to the current or specified project
- `biome use`
  Open a subshell sourcing the current or specified project.
- `$include within the project.json file`
- `BIOME_LOCAL_NAME`
- `BIOME_FOLDER_NAME`

## How it works:
For each project, biome creates 2 files: a local `Biomefile` and a global `project.json`. The local
`Biomefile` can be committed to source control because it just contains a reference to the global
project. The `project.json` is stored in `~/.biome/project.json`, where `project` is replaced with
the identifier in the `Biomefile`. This file is where the environment variables themselves are
actually stored. Since each user can have a separate `project.json` for each system, everyone can
customize their config to suit their needs.

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
