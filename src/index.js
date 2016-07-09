#!/usr/bin/env node
import program from 'commander';
import preflight from './preflight';

import use from './use';
import add from './add';
import init from './init';

program.version(require("../package").version);

// ----------------------------------------------------------------------------
// biome init <project>
// Creatw a new project
// ----------------------------------------------------------------------------
program
.command('init <project>')
.description("Create a new project with the specified name, and save an alias to this folder.")
.action(project => {
  init(project).then(out => {
    console.log(`Created new project ${project}. Add new vars with biome add or fire it up with biome use.`);
  }).catch(console.error.bind(console));
});

// ----------------------------------------------------------------------------
// biome add [COMMAND]=[value]
// add an environment variable to the project's variables
// ----------------------------------------------------------------------------
program
.command('add [project]')
.description("Create a new project with the specified name, and save an alias to this folder.")
.action(project => {
  // if the first part was not a project, reset the variable
  if (project.indexOf('=') !== -1) { project = undefined; }

  // parse out variables
  const matchVarRegex = /([^ ]+)\=(["'].*["']|[^ ])/gi;
  let args = process.argv.slice(3).join(' ');

  let match = matchVarRegex.exec(args);
  if (match === null) {
    console.error("No args were passed. Pass variables like NAME=value.")
  } else {
    // collect all matches
    let allMatches = [];
    while (match !== null) {
      allMatches.push(match);
      match = matchVarRegex.exec(args);
    }

    add(project, allMatches).then(out => {
      console.log(`Sourced all variables. Try biome use to try out what you just added.`);
    }).catch(console.log.error.bind(console))
  }
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

preflight().then(out => program.parse(process.argv));
