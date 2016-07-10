import assert from 'assert';
import mockFs from 'mock-fs';
import fs from 'fs';
import path from 'path';
import {findVariablesFor} from '../src/manager';
import sinon from 'sinon';
import untildify from 'untildify';

import mockCleanSlate from './helpers/mockCleanState';

describe("findVariablesFor", function() {
  describe("With variables in state", function() {
    beforeEach(function() {
      process.env.BIOME_FOLDER_NAME = "~/.biome";
      process.env.BIOME_LOCAL_NAME = "Biomefile";
      mockCleanSlate({HELLO: "world", FOO: "bar"});
    });
    afterEach(function() {
      mockFs.restore();
    });

    it("should find variables for a specified project", function() {
      return findVariablesFor("project").then(vars => {
        assert.deepEqual(vars, {HELLO: "world", FOO: "bar"});
      });
    });
  });
  describe("Without any variables in state", function() {
    beforeEach(function() {
      process.env.BIOME_FOLDER_NAME = "~/.biome";
      process.env.BIOME_LOCAL_NAME = "Biomefile";
      mockCleanSlate();
    });
    afterEach(function() {
      mockFs.restore();
    });

    it("should find variables for a specified project", function() {
      return findVariablesFor("project").then(vars => {
        assert.deepEqual(vars, {});
      });
    });
  });
  describe("With variables and $include", function() {
    beforeEach(function() {
      process.env.BIOME_FOLDER_NAME = "~/.biome";
      process.env.BIOME_LOCAL_NAME = "Biomefile";
      mockCleanSlate({HELLO: "world", "$include": ["another"]}, {
        "another.json": JSON.stringify({FOO: "bar"})
      });
    });
    afterEach(function() {
      mockFs.restore();
    });

    it("should find variables for a specified project", function() {
      return findVariablesFor("project").then(vars => {
        assert.deepEqual(vars, {HELLO: "world", FOO: "bar"});
      });
    });
  });
});

describe("getEnv", function() {
});
