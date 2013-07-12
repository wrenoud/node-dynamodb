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

task 'magneto', 'Run DynamoDB mock service', ->
  port = process.env.MAGNETO_PORT ? 4567
  magneto.listen port, () ->
    console.log "Magneto listening on port #{port}.."
