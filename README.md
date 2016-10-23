[<img width="350" src="./logo.png">](https://github.com/1egoman/biome)

Biome is a tool that creates isolated containers for your app's environment variables.

[![CircleCI](https://circleci.com/gh/1egoman/biome.svg?style=shield)](https://circleci.com/gh/1egoman/biome)

## Introduction
Typically, one stores all their environment variables in `.env` (or something similar), and sources
them in, before running their app. This is bad for two reasons:

1. Forgot to gitignore your `.env` file? Time to regenerate all your secrets.
2. If you need to re-clone your project, you have to reconstruct your environment.

Biome takes a different approach. Biome creates separate "environments" for each of your app's
configurations to live in. Each environment can easily be sourced to bring in all of your app's
secrets. Each app's configuration lives in `~/.biome/app_name.sh` - all secrets live far away from
code. Within each project is a `Biomefile` that references the container name in `~/.biome`, and
this file is version controlled along with your code. Combining these two files allow new users to
easily construct their own version of your environment.

## Install
```bash
brew tap 1egoman/tap
brew install biome
```

or, here's a 1-liner to install it in `/usr/local/bin/biome`:
```bash
curl https://raw.githubusercontent.com/1egoman/biome/master/biome.sh > /tmp/biome && sudo install -m 555 /tmp/biome /usr/local/bin/ && rm -f /tmp/biome
```
For help, run `biome help`.

## Quickstart
First, create a new environment by running `biome init`:
```
Name of project? biome-project
Enter a variable name you'd like to add. FOO      
Enter FOO's default value, or leave empty for none. default value      
Enter a variable name you'd like to add. 

Ok, let's set up your local environment.
Value for FOO? (default value) bar
The environment biome-project has been created. 
To start this environment, run biome use.
```

Then, to open your environment, run `biome use`. You'll get a shell with the variables defined that
you specified in the previous command. Exit the shell with `exit`.

To learn more, run `biome help`:
```
usage: biome <command>

Commands:
  init [-h]    Create a new environment for the project in the current directory. Use the -h|--hidden flag to use a hidden .Biomefile.
  edit         Edit the environment in the current directory.
  use          Spawn a subshell with the project in the cwd's sourced environment.
  inject       Update a new environment with changes since it has been activated with biome use.
  rm           Delete a project's environment so it can be reconfigured.
  (no command) Given the template specified in the Biomefile, creates a new environment for your app.

Set up a new project:
  - Run biome init to make a new environment. You'll be prompted for a name and the default configuration.
  - Run biome use to try out your new environment. Leave the environment by running exit.
  - Make any changes to your environment with biome edit

Create a new environment in a project that already uses Biome:
  - Run biome. You'll be prompted for all the configuration values that the Biomefile contains.
  - Run biome use to try out your new environment. Leave the environment by running exit.
```

## Projects and Organisations using Biome
- [Backstroke](https://github.com/1egoman/backstroke)
- [Density](https://github.com/densityco)
- [Add your Project](https://github.com/1egoman/biome/issues/30)

## FAQ
- **Is there an easy way to tell which environment I'm in within a shell created by biome?**
Biome sets a few additional environment variables (see them with `env | grep BIOME`), one of
them being `BIOME_PROJECT`. This contains the name of the current project that has been loaded from
the environment.

- **Do I have to install Biome globally?**
No, some people choose to install Biome locally (in the root of the project), which makes the process of
contributing easier for others.

- **I'm facing problems using Biome. Help me!**
If you can't figure out a problem on your own, leave an issue and I'll take a look.

- **I want to contribute.**
Great! Pull requests are always welcome.

---
Created by [Ryan Gaus](http://rgaus.net)
