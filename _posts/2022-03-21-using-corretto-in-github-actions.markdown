---
layout: single
title:  "Using Corretto on GitHub Action"
date:   2022-03-21 10:00:00 +0530
categories: engineering
tags: devops github-actions java corretto
toc: true
---
See the [previous post](https://mohankarthik.dev/engineering/2022/03/21/setting-up-github-actions-to-deploy-angular.html) for details on how to understand the basics of GitHub actions and to set it up

The below workflow fetches the latest Corretto 8 installer into a local path, and then installs it. You can change the `CORRETTO_URL` to the version and latest tar gz file.

# GitHub action for Java (using maven)
{% raw %}
```
name: <name>
on: <triggers>
concurrency: <name>
jobs:
  <name>:
    name: <name>
    env:
      CORRETTO_URL: https://corretto.aws/downloads/latest/amazon-corretto-8-x64-linux-jdk.tar.gz
    steps:
      - name: retrieve latest corretto 8 jdk
        run: |
          test -d ${{ runner.temp }}/jdk || mkdir ${{ runner.temp }}/jdk
          test -f ${{ runner.temp }}/jdk/corretto.tar.gz || ( wget -qP ${{ runner.temp }}/jdk $ {{ env.CORRETTO_URL }} )
      - name: Set up JDK 8 from file
        uses: actions/setup-java@v2
        with:
          distribution: 'jdkfile'
          jdkFile: ${{ runner.temp }}/jdk/corretto.tar.gz
          java-version: '8'
          architecture: x64
          cache: "maven"
```
{% endraw %}



