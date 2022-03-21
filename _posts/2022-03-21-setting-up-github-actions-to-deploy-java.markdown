---
layout: single
title:  "Setting up GitHub Actions to Deploy JAVA code on Elastic Beanstalk"
date:   2022-03-21 10:00:00 +0530
categories: engineering
tags: devops github-actions aws maven java corretto
toc: true
---

See the [previous post](https://mohankarthik.dev/engineering/2022/03/21/setting-up-github-actions-to-deploy-angular.html) for details on how to understand the basics of GitHub actions and to set it up

The below is the workflow yml that will build and deploy a maven war file to Elastic Beanstalk. If you've questions on how to use this, and why certain things are being used, fire away in the comments.

# GitHub action for Java (using maven)
{% raw %}
```
name: <name>
on:
  push:
    branches:
      - <branch>
  workflow_dispatch:
concurrency: <name>
jobs:
  <name>:
    name: <name>
    timeout-minutes: <time to wait before timeout>
    runs-on: ubuntu-latest
    env:
      CORRETTO_URL: https://corretto.aws/downloads/latest/amazon-corretto-8-x64-linux-jdk.tar.gz
    steps:
      - name: Checkout the code
        uses: actions/checkout@v2
        with:
          fetch-depth: 0
      - name: Cache jdk binary
        uses: actions/cache@v2
        with:
          path: ${{ runner.temp }}/jdk
          key: ${{ runner.os }}-jdk-8
          restore-keys: ${{ runner.os }}-jdk
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
      - name: Enable caching
        uses: actions/cache@v2
        with:
          path: ~/.m2/repository
          key: ${{ runner.os }}-m2-${{ hashFiles('**/pom.xml') }}
          restore-keys: |
            ${{ runner.os }}-m2
      - name: Create the installer after running the tests
        run: mvn clean install
      - name: Get the current time
        id: time
        uses: nanzm/get-time-action@v1.1
        with:
          timeZone: 8
          format: 'YYYY-MM-DD-HH-mm-ss'
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v1
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: us-east-1
      - name: Upload the war file to AWS
        env:
          TIME: "${{ steps.time.outputs.time }}"
        run: |
          cp ./<project>/target/<filename>.war ./<project>/target/$TIME.war
          aws s3 cp ./<project>/target/$TIME.war s3://<s3 bucket name>/
          aws elasticbeanstalk create-application-version --application-name <app name> --version-label $TIME --source-bundle S3Bucket="<s3 bucket name>",S3Key="$TIME.war" --auto-create-application
          aws elasticbeanstalk update-environment --environment-name <env name> --version-label $TIME
```
{% endraw %}

