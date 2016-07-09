- `biome init`
- `biome add`
- `biome use`
- `$include within the project.json file`
- `BIOME_LOCAL_NAME`
- `BIOME_FOLDER_NAME`


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
