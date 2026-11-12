## The palettes of the Mediterranean sources, clustered by affinity propagation (naffprop) and
## projected on a plane by principal components, for the post "Designing a Mediterranean look".
##
## Not run by CI: naffprop is not a dependency of tabelline. To run it again, after a palette
## changes in `docs/theme.nim`:
##
##   git clone https://github.com/pietroppeter/naffprop ../naffprop     # beside tabelline
##   nim r --hints:off --path:../naffprop/src docs/devlog/data/mediterranean/cluster.nim
##
## It writes `clusters.json` here, which the post reads (and draws) when it is built.
##
## Each palette is a point with 18 coordinates: its six colours, in role order (paper, ink,
## primary, secondary, warning, success), each in OKLab (lightness and two axes of colour), where
## a distance is close to the difference the eye sees. The similarity of two palettes is minus
## their squared distance; every palette's preference is the median of the similarities, as R's
## apcluster does by default, so affinity propagation picks the number of clusters itself.

import std/[algorithm, json, math, os, sequtils, strutils]
import naffprop/ap
import ../../../theme

func linear(c: float): float =
  let c = c / 255
  if c <= 0.04045: c / 12.92 else: pow((c + 0.055) / 1.055, 2.4)

func oklab(hex: string): array[3, float] =
  ## sRGB to OKLab (Björn Ottosson, 2020).
  let (r, g, b) = (linear(float parseHexInt(hex[1 .. 2])), linear(float parseHexInt(hex[3 .. 4])),
                   linear(float parseHexInt(hex[5 .. 6])))
  let l = cbrt(0.4122214708 * r + 0.5363325363 * g + 0.0514459929 * b)
  let m = cbrt(0.2119034982 * r + 0.6806995451 * g + 0.1073969566 * b)
  let s = cbrt(0.0883024619 * r + 0.2817188376 * g + 0.6299787005 * b)
  [0.2104542553 * l + 0.7936177850 * m - 0.0040720468 * s,
   1.9779984951 * l - 2.4285922050 * m + 0.4505937099 * s,
   0.0259040371 * l + 0.7827717662 * m - 0.8086757660 * s]

# the points: one per source
var keys: seq[string]
var x: seq[seq[float]]
for (key, colours) in mediterraneanSources:
  keys.add key
  var p: seq[float]
  for c in colours:
    for v in oklab(c.hex): p.add v
  x.add p
let (n, d) = (x.len, x[0].len)

# affinity propagation: similarities, the median as preference, R's defaults
var s = zeros[float](n)
var offDiagonal: seq[float]
for i in 0 ..< n:
  for j in 0 ..< n:
    var dist = 0.0
    for k in 0 ..< d: dist += (x[i][k] - x[j][k]) ^ 2
    s[i, j] = -dist
    if i != j: offDiagonal.add -dist
offDiagonal.sort
let preference = (offDiagonal[offDiagonal.len div 2 - 1] + offDiagonal[offDiagonal.len div 2]) / 2
let sv = s.view
sv.prepare([preference], noise = true, seed = 42)
let res = sv.affinityPropagation(maxits = 1000, convits = 100, damping = 0.9)

# principal components: the covariance of the centred points, its two largest eigenvectors by
# power iteration (the second after taking the first away)
var mean = newSeq[float](d)
for p in x:
  for k in 0 ..< d: mean[k] += p[k] / float(n)
var c = newSeq[seq[float]](d)
for i in 0 ..< d: c[i] = newSeq[float](d)
for p in x:
  for i in 0 ..< d:
    for j in 0 ..< d: c[i][j] += (p[i] - mean[i]) * (p[j] - mean[j]) / float(n - 1)
var total = 0.0
for i in 0 ..< d: total += c[i][i]

proc topEigen(c: seq[seq[float]]): (float, seq[float]) =
  var v = newSeq[float](c.len)
  for i in 0 ..< v.len: v[i] = 1.0 / float(i + 1)
  var lambda = 0.0
  for _ in 0 ..< 2000:
    var w = newSeq[float](v.len)
    for i in 0 ..< v.len:
      for j in 0 ..< v.len: w[i] += c[i][j] * v[j]
    let norm = sqrt(w.foldl(a + b * b, 0.0))
    for i in 0 ..< v.len: v[i] = w[i] / norm
    lambda = norm
  (lambda, v)

let (l1, v1) = topEigen(c)
var c2 = c
for i in 0 ..< d:
  for j in 0 ..< d: c2[i][j] -= l1 * v1[i] * v1[j]
let (l2, v2) = topEigen(c2)

func project(p, mean, v: seq[float]): float =
  for k in 0 ..< p.len: result += (p[k] - mean[k]) * v[k]

var points = newJArray()
for i in 0 ..< n:
  let lab = res.labels[i]
  points.add %*{"key": keys[i], "x": project(x[i], mean, v1), "y": project(x[i], mean, v2),
                "cluster": lab, "exemplar": res.exemplars[lab] == i}
var exemplars = newJArray()
for e in res.exemplars: exemplars.add %keys[e]
let output = %*{
  "method": "affinity propagation (naffprop), OKLab, 6 colours per palette, preference = median similarity",
  "preference": preference, "iterations": res.iterations, "converged": res.converged,
  "exemplars": exemplars, "explained": [l1 / total, l2 / total], "points": points}
writeFile(currentSourcePath().parentDir / "clusters.json", output.pretty & "\n")
echo res.exemplars.len, " clusters, ", res.iterations, " iterations, converged: ", res.converged
echo "explained: ", $round(100 * l1 / total).int, "% + ", $round(100 * l2 / total).int, "%"
for e, ex in res.exemplars:
  var members: seq[string]
  for i in 0 ..< n:
    if res.labels[i] == e: members.add keys[i]
  echo keys[ex], ": ", members.join(", ")
