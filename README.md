# JSONKitTest
Benchmarks JSONKit vs. NSJSON

Results (x86_64, macOS 10.15.7):
```
$ JSONKitTest 1000 Resources/twitterescaped.json
JSONKit decode: min elapsed = 35572.800
JSONKit decode: max elapsed = 46066.720000
JSONKit decode: mean elapsed = 37441.030200

NSJSON decode: min elapsed = 78416.580
NSJSON decode: max elapsed = 112591.210000
NSJSON decode: mean elapsed = 83006.576840

JSONKit encode: min elapsed = 12952.310
JSONKit encode: max elapsed = 19549.990000
JSONKit encode: mean elapsed = 13847.499880

NSJSON encode: min elapsed = 37956.040
NSJSON encode: max elapsed = 45913.720000
NSJSON encode: mean elapsed = 40209.905200
```

JSONKit is still the best!
