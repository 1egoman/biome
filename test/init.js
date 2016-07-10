import assert from 'assert';
import fs from 'fs';
import path from 'path';
import init from '../src/init';
import sinon from 'sinon';
import untildify from 'untildify';
import mockFs from 'mock-fs';

import {mockEmptyState} from './helpers/mockCleanState';

describe("Init", function() {
  beforeEach(function() {
    process.env.BIOME_FOLDER_NAME = "~/.biome";
    process.env.BIOME_LOCAL_NAME = "Biomefile";
    mockEmptyState();
  });
  afterEach(function() {
    mockFs.restore();
  });

  it("should create new variables specifying a project", function() {
    return init("project").then(out => {
      // Biomefile
      let file = untildify(path.join(process.cwd(), "Biomefile"));
      assert.deepEqual(
        JSON.parse(fs.readFileSync(file)),
        {name: "project"}
      );

      // .biome/prject-name.json
      file = untildify(path.join("~", ".biome", "project.json"));
      assert.deepEqual(JSON.parse(fs.readFileSync(file)), {});
    });
  });
});
