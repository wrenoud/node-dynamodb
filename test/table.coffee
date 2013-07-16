###
// Copyright Teleportd Ltd. and other Contributors
//
// Permission is hereby granted, free of charge, to any person obtaining a
// copy of this software and associated documentation files (the
// "Software"), to deal in the Software without restriction, including
// without limitation the rights to use, copy, modify, merge, publish,
// distribute, sublicense, and/or sell copies of the Software, and to permit
// persons to whom the Software is furnished to do so, subject to the
// following conditions:
//
// The above copyright notice and this permission notice shall be included
// in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
// OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
// NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
// DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
// OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
// USE OR OTHER DEALINGS IN THE SOFTWARE.
###

{assert, expect} = require 'chai'
async = require 'async'
util = require './util'

describe 'ddb', ->

  before (done) =>
    util.before done, =>
      {@ddb, @throwIfErr, @tryCatch, @tryCatchDone, @didThrow, @didNotThrow} = util
      {@listTables, @createTable, @deleteTable, @describeTable, @updateTable} = util.ddb
      @table1Name = 'users'
      @table2Name = 'posts'
      @table1Keys = {hash: ['user_id', @ddb.schemaTypes().string], range: ['time', @ddb.schemaTypes().number]}
      @table2Keys = {hash: ['post_id', @ddb.schemaTypes().string], range: ['text', @ddb.schemaTypes().string]}
      @provisionedThroughput = {read: 5, write: 5}

  after util.after

  it 'should have .listTables() method', =>
    expect(@ddb).to.respondTo 'listTables'

  it 'should have .createTable() method', =>
    expect(@ddb).to.respondTo 'createTable'

  it 'should have .deleteTable() method', =>
    expect(@ddb).to.respondTo 'deleteTable'

  it 'should have .describeTable() method', =>
    expect(@ddb).to.respondTo 'describeTable'

  it 'should have .updateTable() method', =>
    expect(@ddb).to.respondTo 'updateTable'

  describe '.listTables()', =>

    it 'should not throw', (done) =>
      async.parallel [
        @didNotThrow => @listTables {}
      ], done

    it 'should not list any tables when no tables exist', (done) =>
      async.waterfall [
        (cb) => @tryCatch cb, =>
          @listTables {}, cb

        (tables, cb) => @tryCatchDone cb, =>
          assert.isArray tables, 'should return array of table names'
          assert.deepEqual tables, [], 'should return empty array of table names'
          assert.equal tables.length, 0, 'should return empty array of table names'
      ], done

  describe '.createTable()', =>
    it 'should create table if table does not exist', (done) =>
      async.waterfall [
        (cb) => @tryCatch cb, =>
          @createTable @table1Name, @table1Keys, @provisionedThroughput, cb

        (table, cb) => @tryCatchDone cb, =>
          expect(table).to.contain.keys 'TableName', 'KeySchema', 'TableStatus'
          expect(table.TableName).to.equal @table1Name
          expect(table.TableStatus).to.equal 'ACTIVE'

        (cb) => @tryCatch cb, =>
          @listTables {}, cb

        (tables, cb) => @tryCatchDone cb, =>
          assert.equal tables.length, 1, 'should return single table name'
          assert.deepEqual tables, [@table1Name], 'should return name table was created with'
      ], done

  describe '.deleteTable()', =>

    it 'should'

  describe '.describeTable()', =>

    it 'should'

  describe '.updateTable()', =>

    it 'should'
