ntp = (t0, t1, t2, t3) ->
  return {
    rt: (t3 - t0) - (t2 - t1),
    off: ((t1 - t0) + (t2 - t3)) / 2
  }

drift = {}
history = []
history_avg = 0
history_size = 10
server_offset = 0

push_sample = (sample) ->
  history.push(sample)

  if history.length > history_size
    history_avg -= history[0]/history_size
    history.shift()
    history_avg += sample/history_size
  else
    history_avg = history.reduce((t, s) -> t + s) / history.length

  console.log 'avg', history_avg, history.length


module.exports =
  ntp_sync: (t0, t1, t2, t3) ->
    push_sample(ntp(t0, t1, t2, t3).off)
  server_now: ->
    Date.now()/1000.0 + server_offset
