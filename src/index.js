#!/usr/bin/env node
import program from 'commander';

import use from './use';
import init from './init';

program.version('0.0.1');

// ----------------------------------------------------------------------------
// biome init <project>
// Open a shell containing a project's variables
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
// biome use [project]
// Open a shell containing a project's variables
// ----------------------------------------------------------------------------
program
.command('use [project]')
.description("Open a shell with a project's associated variables included.")
.action(project => {
  use(project).catch(console.error.bind(console));
});

program.parse(process.argv);
