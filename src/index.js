#!/usr/bin/env node
import program from 'commander';
import preflight from './preflight';

import use, {vars} from './use';
import add from './add';
import init from './init';

program.version(require("../package").version);

// ----------------------------------------------------------------------------
// biome init <project>
// Creatw a new project
// ----------------------------------------------------------------------------
program
.command('init [project]')
.description("Create a new project with the specified name, and save an alias to this folder.")
.action(project => {
  init(project).then(project => {
    console.log(`Created new project ${project}. Add new vars with biome add or fire it up with biome use.`);
  }).catch(console.error.bind(console));
});

// ----------------------------------------------------------------------------
// biome add [COMMAND]=[value]
// add an environment variable to the project's variables
// ----------------------------------------------------------------------------
program
.command('add [project]')
.description("Add a variable to a project. Specify like NAME=value.")
.action(project => {
  // if the first part was not a project, reset the variable
  if (project.indexOf('=') !== -1) { project = undefined; }

  // get variables, strip out project if it was passed
  let args = process.argv.slice(3);
  if (args[0].indexOf('=') === -1) {
    args = args.slice(1);
  }

  if (args.length === 0) {
    console.error("No args were passed. Pass variables like NAME=value.")
  } else {
    // collect all matches
    let allMatches = args.map(arg => arg.split('='));
    add(project, allMatches).then(out => {
      console.log(`Sourced all variables. Try biome use to try out what you just added.`);
    }).catch(console.log.error.bind(console))
  }
});

// ----------------------------------------------------------------------------
// biome ls
// list all environments
// ----------------------------------------------------------------------------
program
.command('ls')
.description("List all projects on this system.")
.action(project => {
  console.log("TODO")
});

// ----------------------------------------------------------------------------
// biome use [project]
// Open a shell containing a project's variables
// ----------------------------------------------------------------------------
program
.command('use [project]')
.description("Open a shell with a project's associated variables included.")
.action(project => {
  use(project).catch(console.error.bind(console));
});

// ----------------------------------------------------------------------------
// biome source [project]
// source variables into the current shell - kinda
// ----------------------------------------------------------------------------
program
.command('vars [project]')
.description("Echo all variables.")
.action(project => {
  vars(project).catch(console.error.bind(console));
});

preflight().then(out => program.parse(process.argv));
