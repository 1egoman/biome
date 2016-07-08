import assert from 'assert';
import index from '../src/index';

describe("It's cool", function() {
  it("should return stuff", function() {
    assert.deepEqual(index(), {data: "Hello world"});
  });
});
