---
title: Load Testing with K6
description: Learn how to use K6 to proactively catch performance issues, uncover hidden bottlenecks, and avoid costly production surprises. We’ll cover test setup, useful anecdotes from real-world issues, and how to make load testing part of your regular CI/CD pipeline. Ideal for devs and platform engineers wanting better confidence in system performance.
author: Adrian L Thomas
keywords: load testing, k6, javascript, go, golang
url: https://www.adrian-thomas.com
style: |
  h1,h2,h3 {
        text-align: center;
    }
  a {
        text-decoration: inherit;
        color: inherit;
        cursor: auto;
    }
---



# DRAFT

These slides are **IN PROGRESS**. If you're reading this, they probably don't quite make sense yet as I've not finished!

Continue at your own risk...



---

<!-- 
    footer: hello@adrian-thomas.com
-->

<style scoped>
img {
    display: block;
    margin-left: auto;
    margin-right: auto;
}
</style>

# Load Testing with K6

### Adrian L Thomas, MEng

![width:200px](./images/linkedin-qr-code.png)

---

<!-- paginate: true -->

# Who?

- Generalist Software Engineer
- Done a bunch of roles: SWE, Team Lead, Staff Engineer...
- Worked across a bunch of technologies (too many to list!)
- Talk to me in the pub about: cars, running, pizza, or any of the above..

---

# Load Testing with K6
- What you will learn
    - What performance testing is
    - Why to performance test
    - K6: What it is, what you can do with it, getting up and running...
    - Gotchas / Best Practice / Advanced Use Cases
- This talk is mainly focused towards engineers (SWE, SDET, Platform) who may be launching a new service soon, or wish to retrospectively add load to their service (before your users do it for you!).

- Out of scope: K6 Browser, Grafana Cloud, and a bunch of other more advance use cases.

Disclaimer: Not respresenting any company, all views are my own, this is based on personal experience, etc etc.

TODO - can I add QR code / footer throughout?

---

# What is a Load Test?
- It's literally a test that puts network load on your system
- Usually simulating beyond the traffic that you are expecting to receive, and observe whether the system will cope

---

# Types of Load Tests

<style scoped>
p {
  font-size: 0.5em;
}
</style>

![height:200px](./images/test-types.png)
*Source: https://grafana.com/docs/k6/latest/testing-guides/test-types/*

---

# Why Load Test?

- Perhaps about to launch a new service
- Or expecting a significant jump in traffic for an event
- Maybe you're expecting a slow and gentle increase...
- Or you just want to ensure performance remains the same over time (e.g. no regressions introduced)

---

# Load Testing Use Cases

- Whatever the reason: it helps you understand:
    - how far your current implementation will take you
    - where the system bends
    - what your scaling challenges may be

---

*Anecdote: Bad dependabot update*

TODO - does this fit here? the context is once we already had our tests running in CI and things were relatively stable... we THEN spotted this once the change was introduced.

<!-- Dependabot automatically merged a minor patch OTEL update to a bunch of repos. It was difficult to see what change introduced it (particularly when the investigation started days later). The performance tests for my little service helped me narrow this down (git bisect style) and fix a bunch of performance issues for multiple teams and services that were impacting production across the organization. -->

---

TODO - where does this anecdote fit?

*Anecdote: Pre go-live: CPU Throttling*

<!-- The service was operating normally under our manual and automated testing (integration tests) on staging. When we started to load test, we unravelled K8S configuration that plagued not only our service but other services too, that meant even though the K8S cluster had CPU capacity to handle the additional load, AND our service scaled out to 10 instances, our service would still be throttled and perform poorly. -->

---

# Question

> Q: Why bother load testing at all? why not just let the users test in production with real traffic and real hardware?

<!-- A: You could... but if it breaks, it's too late. You're in panic mode to try and fix it! The idea is to understand your limits before you get there (and this also helps you setup any alerting accordingly) -->

---

# K6 - In this talk

- I'll be talking about K6 (https://k6.io)
- It's a free, and open source load testing tool (by Grafana Labs)
- There are other tools out there

_Time for questions at the end - or grab me in the pub after_

<!-- I'll be talking about the free, open source product, not the cloud offering -->

---

# K6 - Execution Engine

- K6 itself is written in Go
- Test scripts in Javascript
- Executed in Go: Sobek (an engine to execute JS in Go)
- i.e. simulating 10 users testing your website === 10 instances of Sobek running your script at a time
- You don't need to worry about the parallelism in code

*https://grafana.com/docs/k6/latest/reference/glossary/#sobek*
> 

---

# Quickstart: Installing

```sh
brew install k6 # macos
choco install k6 # windows 
```

---

# Quickstart: What Does a Simple Test Script Look Like?

<!-- Consider: Skipping the next slides in favour of a live demo. -->

```javascript
import http from 'k6/http';
import { sleep } from 'k6';

export const options = {
  iterations: 10,
};

export default function () {
  http.get('https://quickpizza.grafana.com');

  sleep(1);
}
```

Any guesses for how long this test takes to execute?

*Source: https://grafana.com/docs/k6/latest/get-started/write-your-first-test/*

<!-- 

Explain each line (imports, iterations, how the func gets called)

Note: no "await" on the get!

No VUs configured, so just one user.

Function is called 10 times, but sleeps 1 second each time. So the total test time is ~10 seconds.

If we had 10 VUs then it would spend those 10 iterations sooner (so execution would be ~1s)

K6 can do so much, but it doesn't need to be complicated.


-->

---

# Quickstart: Running a test

```sh
k6 run script.js
```

---

# Quickstart: Test Output

```

         /\      Grafana   /‾‾/  
    /\  /  \     |\  __   /  /   
   /  \/    \    | |/ /  /   ‾‾\ 
  /          \   |   (  |  (‾)  |
 / __________ \  |_|\_\  \_____/ 

     execution: local
        script: scripts/simple-example.js
        output: -

     scenarios: (100.00%) 1 scenario, 1 max VUs, 10m30s max duration (incl. graceful stop):
              * default: 10 iterations shared among 1 VUs (maxDuration: 10m0s, gracefulStop: 30s)


  █ TOTAL RESULTS 

    HTTP
    http_req_duration.......................................................: avg=106.66ms min=100.36ms med=107.64ms max=114.69ms p(90)=111.55ms p(95)=113.12ms
      { expected_response:true }............................................: avg=106.66ms min=100.36ms med=107.64ms max=114.69ms p(90)=111.55ms p(95)=113.12ms
    http_req_failed.........................................................: 0.00%  0 out of 10
    http_reqs...............................................................: 10     0.878629/s

    EXECUTION
    iteration_duration......................................................: avg=1.13s    min=1.1s     med=1.1s     max=1.37s    p(90)=1.16s    p(95)=1.26s   
    iterations..............................................................: 10     0.878629/s
    vus.....................................................................: 1      min=1       max=1
    vus_max.................................................................: 1      min=1       max=1

    NETWORK
    data_received...........................................................: 32 kB  2.8 kB/s
    data_sent...............................................................: 1.0 kB 92 B/s




running (00m11.4s), 0/1 VUs, 10 complete and 0 interrupted iterations
```

<!-- 
Note: A few things going on. 

Notable: 
    http_req_dur
    http_req_failed

    runtime at bottom
 -->

---

# Core Concepts - Virtual Users (VUs)
- VUs just represent a user hitting your endpoint
- If you have 10 VUs then you have 10 users running the script at once
TODO

---

# Core Concepts - Scenarios and Stages
TODO



---

# Core Concepts - Thresholds and Checks

TODO

---

# Core Concepts - Metrics

TODO

CLI output not to necessarily be trusted (you may want to store the logs as artifacts in your CI), but your actual server metrics may be a better source of truth. Gives you the other side of the story if anything funky is going on.

You can also feed them in to AWS CloudWatch, New Relic, Promethesus... etc etc - but may not be necessary if you already have something setup.

TODO some useful things to be looking for? (p95, request duration.......)
but when digging deeper: CPU, RAM, throughput, DB load... etc.

---

# Live Walkthrough and Demo
- Already shown a basic example. Live demo of a heavier one? over wifi? dare I?
- Take a look at some of the traffic in Cloudflare.... and the graphs..

---

# Preparing a Test Environment
TODO - section may be a bit too much..
- Setting it up proper, things you need to think about....
- Writing the tests are actually only a small part of it
- Getting a reusable environment in a shape you can use for testing can be a time consuming aspect

- Think about: scenarios you want to test
- Endpoints? Read only? Writes too? If you're mutating data you may need a way to reset the test environment so subsequent runs are not influenced by prior runs.
- Do you know how much traffic you can expect? multiply it by 10 (early warning system!)
- Data modeling: Can your endpoints respond very differently customer to customer? (e.g. they're storing their own differing data structures)
- You need to find a suitable environment to test _against_: staging/pre-production usually makes most sense
    - It should be an environment setup identical to production. But customers aren't using it, so your load tests won't impact them.
- But also a suitable machine to test _from_. If you're testing regularly (like in CI) you want something stable: not being used for other workloads, or otherwise able to introduce noise. A cloud hosted runner probably won't be ideal, but a self hosted runner or other dedicated machine in your control is best.

FAQ: - Why reset the environment each time? if it slows down over time isn't that a good indication? (no: it's a side effect)

---

# Getting set up in CI
- Depending on the complexity of your tests, you might not want to run _all_ of them regularly (e.g. hours of execution)
- Sanity checking the health of your endpoints for 10 minutes or so should give you a good indication

# CI Frequency
- Ideally every night (cron / nightly pipeline)
- You might decide to do it more regularly: but caution should be applied.. you may disrupt your colleagues (if a shared environment) / or it may be expensive!

---

# Example Output & Metrics (skip time depending)
- Maybe show the output in GHA
- Metrics out: P95, requests per second, errors,and deeper metrics (memory, cpu, network throughput, etc)
- Failing build the build - and alerting 
    - Caveat: P95 between K6 output and external metrics may be different (but should be similar)
- Show a nice P95/P99 graph? maybe Cloudflare gives us something out of the box?

FAQ: What's good/bad? A: it depends on your own definition and SLA's defined.

---

# Gotchas (to look out for)
- Load tests running against a CDN
- Warm up time (to scale) in tests.

# Best Practices / Advanced (skip time depending)
- Write tests scripts to be reusable: make use of env vars (so you can run them locally or in other environments)
- Try to simulate existing traffic patterns - e.g. if distribute the load between endpoints that are hit frequently and less frequently in production with real traffic.
    - FAQ: you can do this by looking at your existing observability data.

--- 

# Resources
- https://grafana.com/docs/k6/latest/

---

# Summary
- Summarise key points
- Reiterate who I am (also I'll be available in May!)
- Can find the slides here: (short url & QR code)
- Links to further reading
- Q&A