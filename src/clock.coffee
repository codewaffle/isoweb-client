ntp = (t0, t1, t2, t3) ->
  return {
    rt: (t3 - t0) - (t2 - t1),
    off: ((t1 - t0) + (t2 - t3)) / 2
  }

drift = {}
history = []
offset_avg = 0
rt_avg = 0
history_size = 125

push_sample = (sample) ->
  history.push(sample)

  if history.length > history_size
    offset_avg -= (history[0].off)/history_size
    rt_avg -= (history[0].rt)/history_size
    history.shift()
    offset_avg += sample.off / history_size
    rt_avg += sample.rt / history_size
  else
    offset_avg = history.map((t) -> t.off).reduce((t, s) -> t + s) / history.length
    rt_avg = history.map( (t) -> t.rt ).reduce((t, s) -> t + s) / history.length

  console.log 'ping: ' + rt_avg + '  offset: ' + offset_avg

module.exports =
  ntp_sync: (t0, t1, t2, t3) ->
    push_sample(ntp(t0, t1, t2, t3))
  server_now: ->
    Date.now()/1000.0 + offset_avg
