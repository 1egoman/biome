![Biome: a small script to manage a user's environment variables](https://raw.githubusercontent.com/1egoman/biome/master/resources/hero.png)

Biome is a simple way to manage your app's environment--all the flags and secrets that vary between deployments.

Biome stores the makeup of your app's environment, so when a new user or contributor wants to run
your app, Biome prompts them for all required secrets. 

Biome saves all your secrets in one place, away from version control. Environment details never
leave your local system.

## Install
Biome is written in bash, and can be installed with:
```bash
curl https://raw.githubusercontent.com/1egoman/biome/master/biome.sh > /usr/local/bin/biome
```

## Getting Started
Within your project, run `biome init <project name>` to configure your project's environment.

```
bob@desktop /project $ biome init
Name of project? project
Enter a variable name you'd like to add. FOO
Enter a default value, or leave empty for none. 
Enter a variable name you'd like to add. BAR
Enter a default value, or leave empty for none. baz
Enter a variable name you'd like to add. 

Value for FOO? () 123
Value for BAR? (baz) 
Nice! To use this environment, run biome use!
```

Later on, another user can run `biome` in the project's root to setup a new environment.
```
janice@laptop /project $ biome
Value for FOO? () 456
Value for BAR? (baz) something else
```
Once it's time to start the app, either user can spawn a new environment with `biome use`.
```
/project $ biome use
Sourcing project from ~/.biome/project.sh
/project $ echo $BIOME_PROJECT
project
/project $
```

## FAQ
- **How do I change an environment later on?** `biome edit [project name]`.

- **What's the difference between `biome use` and `biome use [project name]`?**
Omitting a project name tells Biome to look in the current directory for a Biomefile. If found,
the specified name will be used in place of the passed project name.

- **Do I have to install Biome globally?**
No. Some choose to install Biome locally (in the root of the project), which makes the process of
contributing easier for others.

- **I'm having problems. Help me!**
If you can't figure out a problem on your own, leave an issue and I'll take a look.

- **I want to contribute.**
Great! Pull requests are always welcome.

----------
Created by [Ryan Gaus](http://rgaus.net)
