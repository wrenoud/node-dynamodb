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

{assert} = require 'chai'
magneto = require 'magneto'

describe 'ddb', ->
  before =>
    port = 4567
    magneto.listen port, (err) =>
      spec = {endpoint: "http://localhost:#{port}"}#, accessKeyId: '', secretAccessKey: '', region: ''}
      {@objToDDB, @scToDDB, @objFromDDB, @arrFromDDB} = require('../lib/ddb').ddb(spec)
      @complexJsObj =
        str: 'string'
        strSet: ['foo', 'bar']
        num: 1234
        numSet: [1234, 5678]
      @complexDdbObj =
        str: {'S': 'string'}
        strSet: {SS: ['foo', 'bar']}
        num: {N: '1234'}
        numSet: {'NS': ['1234', '5678']}
      return

  describe '.objToDDB()', =>
    it 'should convert JS objects with scalar fields to DDB objects with scalar fields', =>
      assert.deepEqual {key: {S: 'str'}}, @objToDDB({key: 'str'})
      assert.deepEqual {key: {N: '1234'}}, @objToDDB({key: 1234})

    it 'should convert JS objects with array fields to DDB objects with array fields', =>
      assert.deepEqual {key: {SS: ['foo']}}, @objToDDB({key: ['foo']})
      assert.deepEqual {key: {SS: ['foo', 'bar']}}, @objToDDB({key: ['foo', 'bar']})
      assert.deepEqual {key: {NS: ['42']}}, @objToDDB({key: [42]})
      assert.deepEqual {key: {NS: ['4', '5', '42']}}, @objToDDB({key: [4, 5, 42]})

    it 'should convert result of .objFromDDB() to original DDB object', =>
      ddbObj = {key: {SS: ['foo']}}
      assert.deepEqual ddbObj, @objToDDB(@objFromDDB(ddbObj))

    it 'should convert complex JS objects to corresponding complex DDB objects', =>
      assert.deepEqual @complexDdbObj, @objToDDB(@complexJsObj)

    it 'should exclude null fields in JS objects from conversion to DDB objects', =>
      assert.deepEqual {}, @objToDDB({key: null})
      assert.deepEqual {'key1': {'S': 'str'}}, @objToDDB({key1: 'str', key: null})
      assert.deepEqual {'key1': {'N': '1234'}}, @objToDDB({key1: 1234, key: null})

  describe '.objFromDDB()', =>
    it 'should convert DDB objects with scalar fields to JS objects', =>
      assert.deepEqual {key: 'str'}, @objFromDDB({key: {S: 'str'}})
      assert.deepEqual {key: 1234}, @objFromDDB({key: {N: '1234'}})

    it 'should convert DDB objects with array fields to JS objects with array fields', =>
      assert.deepEqual {key: ['foo']}, @objFromDDB({key: {SS: ['foo']}})
      assert.deepEqual {key: ['foo', 'bar']}, @objFromDDB({key: {SS: ['foo', 'bar']}})
      assert.deepEqual {key: [42]}, @objFromDDB({key: {NS: ['42']}})
      assert.deepEqual {key: [4, 5, 42]}, @objFromDDB({key: {NS: ['4', '5', '42']}})

    it 'should convert result of .objToDDB() to original JS object', =>
      jsObj = {key: [55, 66]}
      assert.deepEqual jsObj, @objFromDDB(@objToDDB(jsObj))

    it 'should convert complex DDB objects to corresponding complex JS objects', =>
      assert.deepEqual @complexJsObj, @objFromDDB(@complexDdbObj)
