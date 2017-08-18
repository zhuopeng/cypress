require("../spec_helper")

fs = require("fs-extra")
path = require("path")
Promise = require("bluebird")
FileUtil = require("#{root}lib/util/file")
appData = require("#{root}lib/util/app_data")
savedState = require("#{root}lib/saved_state")
savedStateUtil = require("#{root}lib/util/saved_state")

fs = Promise.promisifyAll(fs)

describe "lib/util/saved_state", ->
  describe "project name hash", ->
    projectPath = "/foo/bar"

    it "starts with folder name", ->
      hash = savedStateUtil.toHashName projectPath
      expect(hash).to.match(/^bar-/)

    it "computed for given path", ->
      hash = savedStateUtil.toHashName projectPath
      expected = "bar-1df481b1ec67d4d8bec721f521d4937d"
      expect(hash).to.equal(expected)

    it "does not handle empty project path", ->
      tryWithoutPath = () -> savedStateUtil.toHashName()
      expect(tryWithoutPath).to.throw "Missing project path"

describe "lib/saved_state", ->
  beforeEach ->
    fs.unlinkAsync(savedState.path).catch ->
      ## ignore error if file didn't exist in the first place

  it "is a function", ->
    expect(savedState).to.be.a("function")

  it "returns an instance of FileUtil", ->
    expect(savedState()).to.be.instanceof(FileUtil)

  it "sets file path to app data path and file name to 'state'", ->
    statePath = savedState().path
    expected = path.join(appData.path(), "projects", "__global__", "state.json")
    expect(statePath).to.equal(expected)

  it "caches state file instance per path", ->
    a = savedState("/foo/bar")
    b = savedState("/foo/bar")
    expect(a).to.equal(b)

  it "returns different state file for different path", ->
    a = savedState("/foo/bar")
    b = savedState("/foo/baz")
    expect(a).to.not.equal(b)