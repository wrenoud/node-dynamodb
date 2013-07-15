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
async = require 'async'
util = require './util'

describe 'ddb', ->

  before (done) =>
    util.before done, =>
      {@didThrow, @didNotThrow} = util
      {@scToDDB, @objToDDB, @objFromDDB, @arrFromDDB} = util.ddb
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

  after util.after

  it 'should have .scToDDB() method', =>
    assert.isDefined @scToDDB
    assert.isFunction @scToDDB

  it 'should have .objToDDB() method', =>
    assert.isDefined @objToDDB
    assert.isFunction @objToDDB

  it 'should have .objFromDDB() method', =>
    assert.isDefined @objFromDDB
    assert.isFunction @objFromDDB

  it 'should have .arrFromDDB() method', =>
    assert.isDefined @arrFromDDB
    assert.isFunction @arrFromDDB

  describe '.scToDDB()', =>

    it 'should convert scalar JS values to scalar DDB objects', =>
      assert.deepEqual {S: 'str'}, @scToDDB('str')
      assert.deepEqual {N: '1234'}, @scToDDB(1234)
      assert.deepEqual {SS: ['a', 'b']}, @scToDDB(['a', 'b'])
      assert.deepEqual {NS: ['1', '2', '3']}, @scToDDB([1, 2, 3])
      assert.deepEqual {NS: []}, @scToDDB([])

    it 'should not throw when converting valid type scalar JS values to DDB objects', (done) =>
      async.parallel [
        @didNotThrow => @scToDDB 'str'
        @didNotThrow => @scToDDB 1234
        @didNotThrow => @scToDDB ['a', 'b']
        @didNotThrow => @scToDDB [1, 2, 3]
        @didNotThrow => @scToDDB []
      ], done

    it 'should throw when converting invalid type scalar JS values to DDB objects', (done) =>
      # JS type reference: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/typeof
      async.parallel [
        @didThrow => @scToDDB true
        @didThrow => @scToDDB false
        @didThrow => @scToDDB undefined
        @didThrow => @scToDDB {}
        @didThrow => @scToDDB ->
      ], done

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

    it 'should exclude null/undefined fields in JS objects from conversion to DDB objects', =>
      assert.deepEqual {}, @objToDDB({key: null})
      assert.deepEqual {'key1': {'S': 'str'}}, @objToDDB({key1: 'str', key: null})
      assert.deepEqual {'key1': {'N': '1234'}}, @objToDDB({key1: 1234, key: null})

    it 'should not throw when converting JS objects with valid type fields to DDB objects', (done) =>
      async.parallel [
        @didNotThrow => @objToDDB {key: 'a'}
        @didNotThrow => @objToDDB {key: 1}
        @didNotThrow => @objToDDB {key: ['a', 'b']}
        @didNotThrow => @objToDDB {key: [1, 2, 3]}
      ], done

    it 'should throw when converting JS objects with invalid type fields to DDB objects', (done) =>
      async.parallel [
        @didThrow => @objToDDB {key: true}
        @didThrow => @objToDDB {key: false}
        @didThrow => @objToDDB {key: undefined}
        @didThrow => @objToDDB {key: {}}
        @didThrow => @objToDDB {key: ->}
      ], done

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

    it 'should not throw when converting DDB objects with valid type fields to JS objects', (done) =>
      async.parallel [
        @didNotThrow => @objFromDDB {key: {'N': '1'}}
        @didNotThrow => @objFromDDB {key: {'N': 1}}
        @didNotThrow => @objFromDDB {key: {'S': 'a'}}
        @didNotThrow => @objFromDDB {key: {'S': 1}}
        @didNotThrow => @objFromDDB {key: {'NS': ['a', 'a']}}
        @didNotThrow => @objFromDDB {key: {'SS': [1, 2, 3]}}
      ], done

    it 'should throw when converting DDB objects with invalid type fields to JS objects', (done) =>
      async.parallel [
        @didThrow => @objFromDDB {key: {'BAD': 'a'}}
        @didThrow => @objFromDDB {key: {'BAD': '1'}}
        @didThrow => @objFromDDB {key: {'BAD': ['a', 'b']}}
        @didThrow => @objFromDDB {key: {'BAD': [1, 2, 3]}}
        @didThrow => @objFromDDB {key: {'': 'str'}}
        @didThrow => @objFromDDB {key: {'': 1}}
      ], done

  describe '.arrFromDDB()', =>

    it 'should convert arrays of DDB objects into arrays of JS objects', =>
      @jsArr = [
        {str: 'a'}
        {num: 1}
        {strArr: ['a', 'b']}
        {numArr: [1, 2, 3]}
      ]
      @ddbArr = [
        {str: {S: 'a'}}
        {num: {N: '1'}}
        {strArr: {SS: ['a', 'b']}}
        {numArr: {NS: ['1', '2', '3']}}
      ]
      assert.deepEqual @jsArr, @arrFromDDB(@ddbArr)

    it 'should replace elements of DDB object arrays with JS objects', =>
      assert.deepEqual @jsArr, @ddbArr

    it 'should not throw when converting arrays of DDB objects into arrays of JS objects', (done) =>
      @ddbArr = [
        {str: {S: 'a'}}
        {num: {N: '1'}}
        {strArr: {SS: ['a', 'b']}}
        {numArr: {NS: ['1', '2', '3']}}
      ]
      async.parallel [
        @didNotThrow => @arrFromDDB @ddbArr
      ], done
