{assert} = require 'chai'
magneto = require 'magneto'

exports.shouldThrow = (task) =>
  return (cb) =>
    try
      task()
    catch e
      cb null, true
      return
    assert false, "did not throw: #{task.toString()}"

exports.shouldNotThrow = (task) =>
  return (cb) =>
    try
      task()
      cb null, true
      return
    catch e
    assert false, "did throw: #{task.toString()}"

# start magneto, execute task followed by done
ddb = null
exports.before = (done, task) =>
  set = (ddb) =>
    exports.ddb = ddb
    task?()
    done?()
  if ddb then set ddb
  else
    port = 4567
    magneto.listen port, (err) =>
      spec =
        apiVersion: '2011-12-05' #'2012-08-10'
        sslEnabled: false
        accessKeyId: 'x'
        secretAccessKey: 'x'
        region: 'x'
        endpoint: "http://localhost:#{port}"
      ddb = require('../lib/ddb').ddb spec
      set ddb

exports.after = (done, task) =>
  task?()
  done?()
