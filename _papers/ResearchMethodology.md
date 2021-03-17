---
layout: default
title: My Research Mistakes.
tags:
- how to do research
---

A friend suggested I improve my research process following [post](https://lalith.in/2020/09/27/Low-Level-Advice-For-Systems-Research/).
I am listing down some of the important suggestions in this post along with degree to which I have followed them for my current project.
This will serve as lessons for my future self to not repeat and others who wish to follow.

1. Set up the baseline as early as possible. Use this
to measure the baselines as early as possible, even before you start formulating a hypothesis about something you’d like to improve.. (**NO**)

1. Prepare your experiment infrastructure as early as possible.  build the experiment setup and infrastructure as early as possible, and preferably even before you build the system. Do you have a setup ready (**NO**) ?

Always my primary mistake, coupled with not setting up baselines. I make this mistake as I am often not clear on the space I am in or hurry to find a solution before baselines are clear. I have to fix this problem very early.

2. test for correctness during development time, so you don’t have to during experiments; debugging performance problems and system behavior over an experiment is hard enough. Do I have correctness tests ? Am I using continous integration ? Add new test cases for every bug found ? (** NOT RELEVANT YET **)
  Use static style checker and code coverage

4. automating the living crap out of your experiment workflow. Never, ever, configure your infrastructure manually.  Always use feature flags and configuration parameters. If you are recompiling your code to enable featues, you are doing it completely wrong (** NOT RELEVANT YET **)

5. Avoid tunnel vision.wait to see a report with data about all your experiments before iterating on a change to your system. Dont get fixated on an unimportant metric. (** NOT RELEVANT YET **)

6. Measurement. Use your intuition to ask questions, not answer them. If I beat a baseline do not assume it is due to the algorithm, dig deeper perform low level analysis.(Am I sure its not coz database is slower on reads, are measurement in the baseline different) (** NOT RELEVANT YET **)

1. building a working end-to-end version early with hardcoded assumptions and evolve the system to work with increasingly complex inputs.
