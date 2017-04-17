## Performance Tests Results

We encourage you to perform your own tests, because synthetic results are far from real life situation. We provide them only as starting point in understanding Man's performance.

**Test environment:**

* MacBook Pro (15-inch, 2016)
* CPU 2,7 GHz Intel Core i7
* RAM 16 ГБ 2133 MHz LPDDR3
* Man v0.1.16 and PostgreSQL v9.6.2 running in Nebo15 Docker contianers (listed below);
* ApacheBench v2.3;
* wkhtmltopdf v0.12.4 (with patched qt).

### Mustache Template Rendering

Render simple Mustache template and output it in HTML:

```
$ cat payload.json
{"user_name": "John"}

$ ab -n 10000 -c 50 -T 'application/json' -H 'Accept: text/html' -p 'payload.json' http://localhost:4000/templates/1/actions/render
This is ApacheBench, Version 2.3 <$Revision: 1757674 $>
Copyright 1996 Adam Twiss, Zeus Technology Ltd, http://www.zeustech.net/
Licensed to The Apache Software Foundation, http://www.apache.org/

Benchmarking localhost (be patient)
Completed 1000 requests
Completed 2000 requests
Completed 3000 requests
Completed 4000 requests
Completed 5000 requests
Completed 6000 requests
Completed 7000 requests
Completed 8000 requests
Completed 9000 requests
Completed 10000 requests
Finished 10000 requests


Server Software:        Cowboy
Server Hostname:        localhost
Server Port:            4000

Document Path:          /templates/1/actions/render
Document Length:        29 bytes

Concurrency Level:      50
Time taken for tests:   8.412 seconds
Complete requests:      10000
Failed requests:        0
Total transferred:      3560000 bytes
Total body sent:        1890000
HTML transferred:       290000 bytes
Requests per second:    1188.84 [#/sec] (mean)
Time per request:       42.058 [ms] (mean)
Time per request:       0.841 [ms] (mean, across all concurrent requests)
Transfer rate:          413.31 [Kbytes/sec] received
                        219.42 kb/s sent
                        632.73 kb/s total

Connection Times (ms)
              min  mean[+/-sd] median   max
Connect:        0    0  11.3      0    1127
Processing:    14   40   7.4     39     105
Waiting:       14   40   7.4     39     105
Total:         15   40  13.6     39    1183

Percentage of the requests served within a certain time (ms)
  50%     39
  66%     42
  75%     43
  80%     45
  90%     48
  95%     52
  98%     58
  99%     62
 100%   1183 (longest request)

```

Requests had exact content as this curls:

```
curl -X POST 'http://localhost:4000/templates/1/actions/render'
     -H "Content-Type: application/json"
     -H "Accept: text/html"
     -d '{"user_name": "John"}'
```

### Markdown Template Rendering

```
$ cat payload.json
{}

$ ab -n 10000 -c 50 -T 'application/json' -H 'Accept: text/html' -p 'payload.json' http://localhost:4000/templates/2/actions/render
This is ApacheBench, Version 2.3 <$Revision: 1757674 $>
Copyright 1996 Adam Twiss, Zeus Technology Ltd, http://www.zeustech.net/
Licensed to The Apache Software Foundation, http://www.apache.org/

Benchmarking localhost (be patient)
Completed 1000 requests
Completed 2000 requests
Completed 3000 requests
Completed 4000 requests
Completed 5000 requests
Completed 6000 requests
Completed 7000 requests
Completed 8000 requests
Completed 9000 requests
Completed 10000 requests
Finished 10000 requests


Server Software:        Cowboy
Server Hostname:        localhost
Server Port:            4000

Document Path:          /templates/2/actions/render
Document Length:        25 bytes

Concurrency Level:      50
Time taken for tests:   8.142 seconds
Complete requests:      10000
Failed requests:        0
Total transferred:      3520000 bytes
Total body sent:        1690000
HTML transferred:       250000 bytes
Requests per second:    1228.25 [#/sec] (mean)
Time per request:       40.708 [ms] (mean)
Time per request:       0.814 [ms] (mean, across all concurrent requests)
Transfer rate:          422.21 [Kbytes/sec] received
                        202.71 kb/s sent
                        624.92 kb/s total

Connection Times (ms)
              min  mean[+/-sd] median   max
Connect:        0    0   0.2      0      14
Processing:    13   40   7.2     40     107
Waiting:       13   40   7.2     39     107
Total:         13   41   7.2     40     107

Percentage of the requests served within a certain time (ms)
  50%     40
  66%     42
  75%     44
  80%     45
  90%     48
  95%     52
  98%     57
  99%     62
 100%    107 (longest request)
```


### PDF Generation

```
$ ab -n 10000 -c 50 -T 'application/json' -H 'Accept: application/pdf' -p 'payload.json' http://localhost:4000/templates/1/actions/render
This is ApacheBench, Version 2.3 <$Revision: 1757674 $>
Copyright 1996 Adam Twiss, Zeus Technology Ltd, http://www.zeustech.net/
Licensed to The Apache Software Foundation, http://www.apache.org/

Benchmarking localhost (be patient)
Completed 1000 requests
Completed 2000 requests
Completed 3000 requests
Completed 4000 requests
Completed 5000 requests
Completed 6000 requests
Completed 7000 requests
Completed 8000 requests
Completed 9000 requests
Completed 10000 requests
Finished 10000 requests


Server Software:        Cowboy
Server Hostname:        localhost
Server Port:            4000

Document Path:          /templates/1/actions/render
Document Length:        5814 bytes

Concurrency Level:      50
Time taken for tests:   442.214 seconds
Complete requests:      10000
Failed requests:        0
Total transferred:      61490000 bytes
Total body sent:        1950000
HTML transferred:       58140000 bytes
Requests per second:    22.61 [#/sec] (mean)
Time per request:       2211.070 [ms] (mean)
Time per request:       44.221 [ms] (mean, across all concurrent requests)
Transfer rate:          135.79 [Kbytes/sec] received
                        4.31 kb/s sent
                        140.10 kb/s total

Connection Times (ms)
              min  mean[+/-sd] median   max
Connect:        0    0   0.1      0       2
Processing:  1128 2208 184.0   2209    3363
Waiting:     1055 2204 183.8   2205    3363
Total:       1129 2208 183.9   2210    3364

Percentage of the requests served within a certain time (ms)
  50%   2210
  66%   2284
  75%   2330
  80%   2360
  90%   2439
  95%   2501
  98%   2581
  99%   2629
 100%   3364 (longest request)
 ```
