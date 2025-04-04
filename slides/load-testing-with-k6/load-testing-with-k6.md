---
title: Load Testing with K6
description: Learn how to use K6 to proactively catch performance issues, uncover hidden bottlenecks, and avoid costly production surprises. We’ll cover test setup, useful anecdotes from real-world issues, and how to make load testing part of your regular CI/CD pipeline. Ideal for devs and platform engineers wanting better confidence in system performance.
author: Adrian L Thomas
keywords: load testing, k6, javascript, go, golang
url: https://www.adrian-thomas.com
---

# DRAFT

These slides are **IN PROGRESS**. If you're reading this, they probably don't quite make sense yet as I've not finished!

Continue at your own risk...

---

# Intro
- Who am I? - Website, LinkedIn, etc (QR code)
- What do I do?
- What you will learn
- This talk is mainly focused towards engineers (SWE, SDET, Platform) who may be launching a new service soon, or wish to retrospectively add monitoring to their service.

---

# Why Load Test?
- Why performance test?
- Other kinds of performance tests (*load* being one of them: also stress, soak)
- Gain an understanding where the system bends and where potential scaling challenges may be
- Not just for big companies: but it is more if you're expecting load and want to ensure your environment can support more load (and/or scale accordingly)

---

# Use Cases
- Preparing for a launch
    - e.g. launching a new service (anecdote)
- Monitor for regressions
    - Anecdotes

---

# K6
- K6: One liner, what is it?
- K6: I'll be talking about the free, open source product, not the cloud offerings

- _There will be some time at the end for questions - or grab me in the pub after_

---

# Quickstart: Simple example
CLI example and output too

Show some code, and it's output... demo its simplicity

---

# Core Concepts
- Virtual Users (VUs)
- Scenarios and stages
- Thresholds and checks
- Metrics (http_req_duration, iterations, etc.)

---

# Live Walkthrough and Demo
- Show a couple of examples.... show the code, show it running
- Test against a simple API in Cloudflare?

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

---

# Getting set up in CI
- Depending on the complexity of your tests, you might not want to run _all_ of them regularly (e.g. hours of execution)
- Sanity checking the health of your endpoints for 10 minutes or so should give you a good indication

---

# Frequency
- Ideally every night (cron / nightly pipeline)
- You might decide to do it more regularly: but caution should be applied.. you may disrupt your colleagues (if a shared environment) / or it may be expensive!

---

# Example Output & Metrics (skip time depending)
- Maybe show the output in GHA
- Metrics out: P95, requests per second, errors,and deeper metrics (memory, cpu, network throughput, etc)
- Failing build the build - and alerting 
    - Caveat: P95 between K6 output and external metrics may be different (but should be similar)
- Show a nice P95/P99 graph? maybe Cloudflare gives us something out of the box?

---

# Gotchas (to look out for)
- Load tests running against a CDN
- Warm up time (to scale) in tests.

---

# Best Practices / Advanced (skip time depending)
- Write tests scripts to be reusable: make use of env vars (so you can run them locally or in other environments)
- Try to simulate existing traffic patterns - e.g. if distribute the load between endpoints that are hit frequently and less frequently in production with real traffic.

---

# FAQ's (skip time depending)
- Why not just test in production with real traffic and real hardware? (no: it's too late, and doesn't show you where your limits are)
- Why reset the environment each time? if it slows down over time isn't that a good indication? (no: it's a side effect)

---

# Summary
- Summarise key points
- Reiterate who I am (also I'll be available in May!)
- Can find the slides here: (short url & QR code)
- Links to further reading
- Q&A