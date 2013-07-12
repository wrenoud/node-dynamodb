magneto = require 'magneto'
{spawn} = require 'child_process'

binPath = './node_modules/.bin'
process.env.PATH = "#{binPath}:#{process.env.PATH}"

task 'test', 'Run test suite', ->
  test = spawn "#{binPath}/mocha", [
    '--compilers', 'coffee:coffee-script'
    '--reporter', 'spec'
    'test/conversion.coffee'
  ]
  test.stdout.pipe process.stdout
  test.stderr.pipe process.stderr
