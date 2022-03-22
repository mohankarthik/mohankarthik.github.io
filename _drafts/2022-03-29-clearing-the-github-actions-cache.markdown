---
layout: single
title:  "Clearing the GitHub Actions Cache"
date:   2022-03-29 10:00:00 +0530
categories: engineering
tags: devops github-actions
toc: true
---
Most GitHub actions (either to deploy or to test) will have enabled cached via the [exceptionally great cache action](https://github.com/actions/cache). But what happens when something that got cached is no longer used, or is breaking tests because of an older dependency. How do you clear out the cache?

Well, apparently you can't!!! But, looks like the amazing folks at GitHub are looking to solve it and this is on their roadmap.

But, we are engineers and we always have work-arounds. I think we are so accustomed to workarounds, that I have workarounds even for perfectly working things in my life! But we digress. So what's the workaround.

You simply change the cache key. The current architecture is that GitHub will clear out the cache if it's not being used for more than 7 days. So by using a different cache key, you'll essentially create a new cache and the old cache will get deleted after 7 days.
Change the key from 

{% raw %}`${{ runner.os }}-xyz-${{ hashFiles(...) }}`{% endraw %}

to 

{% raw %}`${{ runner.os }}-xyz-v2-${{ hashFiles(...) }}`{% endraw %}

A really cool way to do it, is to set up a cache version number which you can change from GitHub secrets. So you don't even need to update and commit the code if you want to clear out the cache. Create a secret in the current GitHub repository called `CACHE_VERSION`, and then change your workflow to

{% raw %}`${{ runner.os }}-foo-${{ secrets.CACHE_VERSION }}-${{ hashFiles(...) }}`{% endraw %}

