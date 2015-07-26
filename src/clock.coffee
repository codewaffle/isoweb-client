ntp = (t0, t1, t2, t3) ->
  return {
    rt: (t3 - t0) - (t2 - t1),
    off: ((t1 - t0) + (t2 - t3)) / 2
  }

history = []
offset_avg = 0
rt_avg = 0

module.exports =
  ntp_sync: (t0, t1, t2, t3) ->
    history.push(ntp(t0, t1, t2, t3))
  server_now: ->
    Date.now()/1000.0 + offset_avg
  server_adjusted: ->
    Date.now()/1000.0 + offset_avg - Math.max(rt_avg*2.0, 0.1)
  reset_latency: ->
    history.length = 0
  calculate_latency: ->
    offset_avg = history.map((t) -> t.off).reduce((t, s) -> t + s) / history.length
    rt_avg = history.map( (t) -> t.rt ).reduce((t, s) -> t + s) / history.length
    console.log 'ping: ' + rt_avg + '   offset: ' + offset_avg

