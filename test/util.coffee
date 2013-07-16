magneto = require 'magneto'

exports.didThrow = (task) =>
  return (cb) =>
    try
      task()
    catch e
      cb null, true
      return
    cb "did not throw: #{task.toString()}"

exports.didNotThrow = (task) =>
  return (cb) =>
    try
      task()
      cb null, true
      return
    catch e
      cb "did throw: #{task.toString()}"

exports.throwIfErr = (err, res) =>
  if err? then throw err

exports.tryCatch = (done, task) =>
  try
    task?()
    done?()
  catch e
    done? e

# start magneto, then execute task followed by done
ddb = null
exports.before = (done, task) =>
  set = (ddb) =>
    exports.ddb = ddb
    task?()
    done? null, ddb

  if ddb then set ddb
  else
    port = 4567
    magneto.listen port, (err) =>
      if err? then done? err
      else
        spec =
          apiVersion: '2011-12-05' #'2012-08-10'
          sslEnabled: false
          accessKeyId: 'x'
          secretAccessKey: 'x'
          region: 'x'
          endpoint: "http://localhost:#{port}"
        ddb = require('../lib/ddb').ddb spec
        set ddb

# perform cleanup, then execute task followed by done
exports.after = (done, task) =>
  task?()
  done?()
