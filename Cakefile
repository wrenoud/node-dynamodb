magneto = require 'magneto'

task 'magneto', 'Run DynamoDB mock service', ->
  port = process.env.MAGNETO_PORT ? 4567
  magneto.listen port, () ->
    console.log "Magneto listening on port #{port}.."
