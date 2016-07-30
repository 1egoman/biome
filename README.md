<img src="https://raw.githubusercontent.com/1egoman/biome/master/resources/logo.png" style="width: 300px;" />

[![CircleCI](https://circleci.com/gh/1egoman/biome.svg?style=shield)](https://circleci.com/gh/1egoman/biome)

# Biome
Biome is a small utility to manage environment variables associated with a project. It provides a
simple interface that lets anyone create a copy of a projects environment for loca testing or
deployment.

The core of Biome consists of a `Biomefile`, a file in the root of your project that defines the
projects name as well as each of the project's variable mapped to its default value. Since this file
contains no secret information, it can (and should) be version-controlled.

```bash
name=my_cool_app
FOO=bar
BAZ=Multiple words work too
KEY_WITHOUT_DEFAULT=
```

Once on a local system, Biome uses this file as a template to assemble an environment for your app
to run within. These environments are stored in `~/.biome`, indexed by the `name` in the
`Biomefile`. A user can set one of these up from a pre-configured `Biomefile` by running `biome` and
entering any overrides for their system.

```bash
export FOO="value overriden from default"
export BAZ="Multiple words work too"
export KEY_WITHOUT_DEFAULT="a value must be defined here"
```
From the root of the repository, a user can run `biome use`, which will spawn a subshell and source
the specified environment.


## Install
```bash
brew tap 1egoman/tap
brew install biome
```

If you're on linux, here's a 1-liner:
```bash
curl https://raw.githubusercontent.com/1egoman/biome/master/biome.sh > /usr/local/bin/biome && sudo chmod +x /usr/local/bin/biome
```
For help, run `biome help`.

<!--
## Usage
![Biome: Getting Started](https://raw.githubusercontent.com/1egoman/biome/master/resources/Getting Started.png)
-->

## FAQ
- **How do I change an environment later on?** `biome edit [project name]`.

- **What's the difference between `biome use` and `biome use [project name]`?**
Omitting a project name tells Biome to look in the current directory for a Biomefile. If found,
the specified name will be used in place of the passed project name.

- **Is there an easy way to tell which environment I'm in within a shell created by biome use?**
Biome sets a few additional environment variables (see all with `env | grep BIOME`), one of
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
