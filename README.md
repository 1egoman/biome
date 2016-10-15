<h1><a href="https://github.com/1egoman/biome" target="_blank"><img width="350" src="./logo.svg"></a></h1>

Biome is a tool to create isolated containers for your app's environment variables.

[![CircleCI](https://circleci.com/gh/1egoman/biome.svg?style=shield)](https://circleci.com/gh/1egoman/biome)

## Introduction
Typically, one stores all their environment variables in `.env` (or something similar), and sources
them in before running their app. This is bad for two reasons:

1. Forget to gitignore your `.env` file? Time to regenerate all your secrets.
2. If you need to re-clone your project, you have to reconstruct your environment.

Biome takes a different approach. Biome creates separate "environments" for each of your app's
configurations to live in. Each environment can easily be sourced to bring in all of your app's
secrets. Each app's configuration lives in `~/.biome/app_name.sh` - all secrets live far away from
code. Within each project is a `Biomefile` that references the container name in `~/.biome`, and
this file is version controlled along with your code. Combining these two files allows new users to
easily construct their own version of your environment.

## Install
```bash
brew tap 1egoman/tap
brew install biome
```

If you're on linux, here's a 1-liner to install it in `/usr/local/bin/biome`:
```bash
curl https://raw.githubusercontent.com/1egoman/biome/master/biome.sh > /usr/local/bin/biome && sudo chmod +x /usr/local/bin/biome
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
The environment biome-project has been created. To start this environment, run biome use.
```

Then, to open your environment, run `biome use`. You'll get a shell with the variables defined that
you specified in the previous command. Exit the shell with `exit`.

To learn more, run `biome help`.

## FAQ
- **Is there an easy way to tell which environment I'm in within a shell created by biome use?**
Biome sets a few additional environment variables (see them with `env | grep BIOME`), one of
them being `BIOME_PROJECT`. This contains the name of the current project that has been loaded from
the environment.

- **Do I have to install Biome globally?**
No. Some choose to install Biome locally (in the root of the project), which makes the process of
contributing easier for others.

- **I'm having problems. Help me!**
If you can't figure out a problem on your own, leave an issue and I'll take a look.

- **I want to contribute.**
Great! Pull requests are always welcome.

----------
Created by [Ryan Gaus](http://rgaus.net)
