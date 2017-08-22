Rest Cronjob Golang Docker
---

Clone the repository. And follow the commands below.

Create de image.
```sh
sudo docker build -t thiagozs/rest-cron-docker:1.0.0 .
```

Run image.
```sh
sudo docker run -d --restart=always --name=cronjob -p 8011:8011 -t thiagozs/rest-cron-docker:1.0.0
```

## BoltDB or Redis
Kala uses BoltDB by default for the job database, however you can also use Redis by using the jobDB and jobDBAddress params:

kala run --jobDB=redis --jobDBAddress=127.0.0.1:6379

PS: **You need edit the image on Dockerfile and pass the parameters for run it.**

## Overview of routes

| Task | Method | Route |
| --- | --- | --- |
|Creating a Job | POST | /api/v1/job/ |
|Getting a list of all Jobs | GET | /api/v1/job/ |
|Getting a Job | GET | /api/v1/job/{id}/ |
|Deleting a Job | DELETE | /api/v1/job/{id}/ |
|Getting metrics about a certain Job | GET | /api/v1/job/stats/{id}/ |
|Starting a Job manually | POST | /api/v1/job/start/{id}/ |
|Getting app-level metrics | GET | /api/v1/stats/ |

## Job JSON Example

```
{
        "name":"test_job",
        "id":"93b65499-b211-49ce-57e0-19e735cc5abd",
        "command":"bash -c ls -Flash",
        "owner":"",
        "disabled":false,
        "dependent_jobs":null,
        "parent_jobs":null,
        "schedule":"R2/2015-06-04T19:25:16.828696-07:00/PT10S",
        "retries":0,
        "epsilon":"PT5S",
        "success_count":0,
        "last_success":"0001-01-01T00:00:00Z",
        "error_count":0,
        "last_error":"0001-01-01T00:00:00Z",
        "last_attempted_run":"0001-01-01T00:00:00Z",
        "next_run_at":"2015-06-04T19:25:16.828794572-07:00"
}
```

## Breakdown of schedule string. (ISO 8601 Notation)

Example `schedule` string:

```
R2/2017-06-04T19:25:16.828696-07:00/PT10S
```

This string can be split into three parts:

```
Number of times to repeat/Start Datetime/Interval Between Runs
```

#### Number of times to repeat

This is designated with a number, prefixed with an `R`. Leave out the number if it should repeat forever.

Examples:

* `R` - Will repeat forever
* `R1` - Will repeat once
* `R231` - Will repeat 231 times.

#### Start Datetime

This is the datetime for the first time the job should run.

Kala will return an error if the start datetime has already passed.

Examples:

* `2017-06-04T19:25:16`
* `2017-06-04T19:25:16.828696`
* `2017-06-04T19:25:16.828696-07:00`
* `2017-06-04T19:25:16-07:00`

*To Note: It is recommended to include a timezone within your schedule parameter.*

#### Interval Between Runs

This is defined by the [ISO8601 Interval Notation](https://en.wikipedia.org/wiki/ISO_8601#Time_intervals).

It starts with a `P`, then you can specify years, months, or days, then a `T`, preceded by hours, minutes, and seconds.

Lets break down a long interval: `P1Y2M10DT2H30M15S`

* `P` - Starts the notation
* `1Y` - One year
* `2M` - Two months
* `10D` - Ten days
* `T` - Starts the time second
* `2H` - Two hours
* `30M` - Thirty minutes
* `15S` - Fifteen seconds

Now, there is one alternative. You can optionally use just weeks. When you use the week operator, you only get that. An example of using the week operator for an interval of every two weeks is `P2W`.

Examples:

* `P1DT1M` - Interval of one day and one minute
* `P1W` - Interval of one week
* `PT1H` - Interval of one hour.

### More Information on ISO8601

* [Wikipedia's Article](https://en.wikipedia.org/wiki/ISO_8601)

## /job

This route accepts both a GET and a POST. Performing a GET request will return a list of all currently running jobs.
Performing a POST (with the correct JSON) will create a new Job.

Note: When creating a Job, the only fields that are required are the `Name` and the `Command` field. But, if you omit the `Schedule` field, the job will be ran immediately.

Example:
```bash
$ curl http://127.0.0.1:8000/api/v1/job/
{"jobs":{}}
$ curl http://127.0.0.1:8000/api/v1/job/ -d '{"epsilon": "PT5S", "command": "bash /home/ajvb/gocode/src/github.com/ajvb/kala/examples/example-kala-commands/example-command.sh", "name": "test_job", "schedule": "R2/2017-06-04T19:25:16.828696-07:00/PT10S"}'
{"id":"93b65499-b211-49ce-57e0-19e735cc5abd"}
$ curl http://127.0.0.1:8000/api/v1/job/
{
    "jobs":{
        "93b65499-b211-49ce-57e0-19e735cc5abd":{
            "name":"test_job",
            "id":"93b65499-b211-49ce-57e0-19e735cc5abd",
            "command":"bash /home/ajvb/gocode/src/github.com/ajvb/kala/examples/example-kala-commands/example-command.sh",
            "owner":"",
            "disabled":false,
            "dependent_jobs":null,
            "parent_jobs":null,
            "schedule":"R2/2017-06-04T19:25:16.828696-07:00/PT10S",
            "retries":0,
            "epsilon":"PT5S",
            "success_count":0,
            "last_success":"0001-01-01T00:00:00Z",
            "error_count":0,
            "last_error":"0001-01-01T00:00:00Z",
            "last_attempted_run":"0001-01-01T00:00:00Z",
            "next_run_at":"2017-06-04T19:25:16.828794572-07:00"
        }
    }
}
```

## /job/{id}

This route accepts both a GET and a DELETE, and is based off of the id of the Job. Performing a GET request will return a full JSON object describing the Job.
Performing a DELETE will delete the Job.

Example:
```bash
$ curl http://127.0.0.1:8000/api/v1/job/93b65499-b211-49ce-57e0-19e735cc5abd/
{"job":{"name":"test_job","id":"93b65499-b211-49ce-57e0-19e735cc5abd","command":"bash /home/ajvb/gocode/src/github.com/ajvb/kala/examples/example-kala-commands/example-command.sh","owner":"","disabled":false,"dependent_jobs":null,"parent_jobs":null,"schedule":"R2/2017-06-04T19:25:16.828696-07:00/PT10S","retries":0,"epsilon":"PT5S","success_count":0,"last_success":"0001-01-01T00:00:00Z","error_count":0,"last_error":"0001-01-01T00:00:00Z","last_attempted_run":"0001-01-01T00:00:00Z","next_run_at":"2017-06-04T19:25:16.828737931-07:00"}}
$ curl http://127.0.0.1:8000/api/v1/job/93b65499-b211-49ce-57e0-19e735cc5abd/ -X DELETE
$ curl http://127.0.0.1:8000/api/v1/job/93b65499-b211-49ce-57e0-19e735cc5abd/
```

## /job/stats/{id}

Example:
```bash
$ curl http://127.0.0.1:8000/api/v1/job/stats/5d5be920-c716-4c99-60e1-055cad95b40f/
{"job_stats":[{"JobId":"5d5be920-c716-4c99-60e1-055cad95b40f","RanAt":"2017-06-03T20:01:53.232919459-07:00","NumberOfRetries":0,"Success":true,"ExecutionDuration":4529133}]}
```

## /job/start/{id}

Example:
```bash
$ curl http://127.0.0.1:8000/api/v1/job/start/5d5be920-c716-4c99-60e1-055cad95b40f/ -X POST
```

## /stats

Example:
```bash
$ curl http://127.0.0.1:8000/api/v1/stats/
{"Stats":{"ActiveJobs":2,"DisabledJobs":0,"Jobs":2,"ErrorCount":0,"SuccessCount":0,"NextRunAt":"2017-06-04T19:25:16.82873873-07:00","LastAttemptedRun":"0001-01-01T00:00:00Z","CreatedAt":"2017-06-03T19:58:21.433668791-07:00"}}
```

---

The MIT License (MIT)

Copyright (c) 2017 THIAGO ZILLI SARMENTO

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
