#!/usr/bin/env node
import program from 'commander';

import use from './use';

program.version('0.0.1');

// ----------------------------------------------------------------------------
// biome use [project]
// Open a shell containing a project's variables
// ----------------------------------------------------------------------------
program
.command('use [project]')
.description("Open a shell with a project's associated variables included")
.action(project => {
  use(project).catch(console.error.bind(console));
});

program.parse(process.argv);
