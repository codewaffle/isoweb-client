ntp = (t0, t1, t2, t3) ->
  return {
    rt: (t3 - t0) - (t2 - t1),
    off: ((t1 - t0) + (t2 - t3)) / 2
  }

drift = {}

module.exports =
  ntp_sync: (t0, t1, t2, t3) ->
    new_drift = ntp(t0, t1, t2, t3)
    console.log(t0, t1, t2, t3, new_drift)
