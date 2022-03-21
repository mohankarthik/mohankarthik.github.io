---
layout: single
title:  "Setting up GitHub Actions to Deploy Front-End Code on AWS S3 and Cloudfront"
date:   2022-03-21 10:00:00 +0530
categories: engineering
tags: devops github-actions aws angular react vue
toc: true
---
# Assumption
AWS S3 and Cloudfront are fantastic infrastructure to deploy your production website (either static, say a simple HTML/CSS, or generated via a static site generator via Gatsby, Hugo, Jekyll, etc...); or a dynamic front-end (say using React, Angular, etc...). This post will cover on how to deploy an angular / react / vue code to S3 and Cloudfront.

This post assumes that you already have a working JS project (either Angular / React / Vue / etc...), and that you've [setup AWS S3 bucket with a website endpoint](https://docs.aws.amazon.com/AmazonS3/latest/userguide/WebsiteHosting.html)

The post also assumes that you've your code hosted on Github.

# CI/CD alternatives
There are many CI/CD platforms today, including Jenkins, GitHub Actions, Circle CI, Atlassian Bamboo, etc... Given that most of us end up using Github to host the code, and that GitHub provides free minutes to run the pipelines, it's just a very convinient option without any significant downsides.

# How does Github Actions work
Github actions can be triggered by many actions
* Manually
* On a periodic interval via a cronjob
* On pushing a new commit to a branch
* On creating / updating / deleting a pull request

Depending on the configuration, GitHub would simply create a new container (using very similar concepts to Docker) and do the job that you specify. The job could be anything. You could create a GitHub action to print "Hello World!". Which is a nice way to test out things and get yourself comfortable with the idea.

# GitHub action to deploy Javascript code
To create a new GitHub workflow, you create a `.github` folder in the root of your project and then a `workflows` folder. Within this folder, you can add a `<name>.yml` to define your workflow / pipeline. Below is the code that you can directly use, and then we'll break it down.

Note the below config uses `yarn` but you can replace it with `npm` if that's your package manager.
```
name: <name>
on:
  push:
    branches: 
      - master
concurrency: <name>
jobs:
  <name>:
    name: <name>
    timeout-minutes: <time in minutes after which the job should timeout>
    runs-on: ubuntu-latest
    env:
      NODE_VERSION: '<Node version number>'
      S3_BUCKET: <s3 bucket ID>
      CDN_DISTRIBUTION_ID: <cloudfront ID>
      AWS_REGION: <aws region>
    steps:
      - name: Checkout the code
        uses: actions/checkout@v2
        with:
          fetch-depth: 0
      - name: Install node
        uses: actions/setup-node@v2
        with:
          node-version: ${{ env.NODE_VERSION }}
      - name: Get yarn cache directory path
        id: yarn-cache-dir-path
        run: echo "::set-output name=dir::$(yarn cache dir)"
      - name: Cache the dependencies
        uses: actions/cache@v2
        id: yarn-cache
        with:
          path: ${{ steps.yarn-cache-dir-path.outputs.dir }}
          key: ${{ runner.os }}-yarn-${{ hashFiles('**/yarn.lock') }}
          restore-keys: |
            ${{ runner.os }}-yarn-
      - name: yarn install
        run: yarn --prefer-offline
      - name: build
        run: <your yarn command to build your site>
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v1
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: {{ env.AWS_REGION }}
      - name: deploy
        run: |
          aws s3 rm s3://${{ env.S3_BUCKET }}/ --recursive
          aws s3 cp ./target/www s3://${{ env.S3_BUCKET }} --cache-control 'public, max-age=31104000' --recursive
          aws configure set preview.cloudfront true
          aws cloudfront create-invalidation --distribution-id ${{ env.CDN_DISTRIBUTION_ID }} --paths "/*"
```

Let's break the above down

## Triggers
This [page](https://docs.github.com/en/actions/using-workflows/events-that-trigger-workflows) contains detailed information, and summarizing the most used triggers

```
on:
  push:
    branches: 
      - master # Matches any push on the master branch
      - *asd* # Matches any branch that has asd in the name like basd, basdf, etc...
  pull_request:
    types:
      - opened # When a new PR is opened
      - reopened # When a PR is re-opened
      - synchronize # When a PR is updated
```
The above are your conventional triggers. So if you want to build and deploy anytime you push / merge to a branch (say the main / master). This is what we do in our original example. If you want to build each time a pull request is updated, so you get to test the bleeding edge work, then you can trigger it on pull_request -> types -> opened, synchronized. 

## Choosing the Runner
In the above example, we use `ubuntu-latest`. This could be the default choice for most people, but look at [other options](https://docs.github.com/en/actions/using-github-hosted-runners/about-github-hosted-runners).

## Naming the Job
A job has a name
```
jobs:
  <name>:
    name: <name>
```
Pretty straightforward. Everyone has a name! It's just cruel to be nameless!

## Defining environment variables
It's a good idea to always defining common variables in once place, so you can easily use them in multiple places. Same as [DRY](https://en.wikipedia.org/wiki/Don%27t_repeat_yourself)
```
    env:
      NODE_VERSION: '<Node version number>'
      S3_BUCKET: <s3 bucket ID>
      CDN_DISTRIBUTION_ID: <cloudfront ID>
      AWS_REGION: <aws region>
```
In this case, let's also define what these variables are.
* NODE_VERSION: This is straight forward. Simply put the node version that you've locally used to build the project. Also ensure to keep this aligned with your local version, so you don't get surprises when you deploy
* S3_BUCKET: This is the name of the S3 bucket. Typically you want a name that is unique. In my case it would be `dev.mohankarthik.xxx` and since I own `mohankarthik.dev`, the naming convention becomes unique for me.
* CDN_DISTRIBUTION_ID: This is the ID of the cloudfront entry. You can skip cloudfront, but it's pretty spectacular and I'd suggest enabling it even for hobby projects.
* AWS_REGION: The Region where your AWS account is hosted. us-east-1, etc...

## Steps
This is where the money is. Now let's dive in.

Each step has an `name` and either `uses` or `run`. `uses` essentially uses an existing module directly with no work from us. How cool is that. We get small open-source tasks to run and get us what we want. You can see the list of all existing actions [here](https://github.com/marketplace?type=actions).

### Checkout the code
```
      - name: Checkout the code
        uses: actions/checkout@v2
        with:
          fetch-depth: 0
```
This piece of code basically checks your code out into the machine that's building the code. `fetch-depth` being set to 0 basically means that it will do a shallow pull, only the current commit and not the entire history.

### Installing node
```
      - name: Install node
        uses: actions/setup-node@v2
        with:
          node-version: ${{ env.NODE_VERSION }}
```
This installs the node version that you've specified in the env. For other frameworks / languages, change to the approrpriate setup. There are many [existing actions](https://github.com/marketplace?type=actions&query=setup+) to help setup other languages.

### Caching
This is a really cool feature of GitHub (and many other CI/CD tools too). GitHub Actions will save all the dependencies (the infamous `node_modules` folder) into memory, and then the next time you run your workflow, it'll restore the local version before trying to get it from the internet. Which will speed up the whole build significantly.
```
      - name: Get yarn cache directory path
        id: yarn-cache-dir-path
        run: echo "::set-output name=dir::$(yarn cache dir)"
```
The above part gets the directory where the cache will get stored and sets it as the yarn cache directory

```
      - name: Cache the dependencies
        uses: actions/cache@v2
        id: yarn-cache
        with:
          path: ${{ steps.yarn-cache-dir-path.outputs.dir }}
          key: ${{ runner.os }}-yarn-${{ hashFiles('**/yarn.lock') }}
          restore-keys: |
            ${{ runner.os }}-yarn-
```
This is the part that actually caches all the dependencies after the first install. You can update this to your language of choice by changing the cache directory to where your framework / language will store the dependencies. `.pub-cache` for flutter, `.m2` for maven, etc...

### Install dependencies
This part is simple
```
      - name: yarn install
        run: yarn --prefer-offline
```
Call a console command to install all dependencies by calling `yarn` or `npm install`. You can do similar for other languages like `pip install -r requirements.txt`, etc...

This part will also automatically fetch from the cache specified ahead instead of fetching from internet if the cache already has data.

### Build
```
      - name: build
        run: <your yarn command to build your site>
```
Simple as it is. Call the command line that you want to build the project. And can be customized for the language / framework of choice

### Deploying to AWS
```
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v1
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: {{ env.AWS_REGION }}
```
Before we get to this section, we'll need to setup an IAM account on AWS dedicated for this GitHub workflow. It's generally a good idea to not use the same IAM account for multiple purposes, so create one just for this. Copy the Key ID and Access Key to GitHub Settings -> Secrets (the url would be something like `https://github.com/<organization>/<repository>/settings/secrets/actions`). This will then be accessible to the workflow in run time using the above script.

```
      - name: deploy
        run: |
          aws s3 rm s3://${{ env.S3_BUCKET }}/ --recursive
          aws s3 cp ./target/www s3://${{ env.S3_BUCKET }} --cache-control 'public, max-age=31104000' --recursive
          aws configure set preview.cloudfront true
          aws cloudfront create-invalidation --distribution-id ${{ env.CDN_DISTRIBUTION_ID }} --paths "/*"
```
This is the code that actually pushes the built distributable onto AWS. 
* In this case the first line deletes the existing content on S3 so it's a clean slate. 
* Then the second line copies the entire website content to the S3 bucket. While doing so, it adds headers onto each object so that the browser fetching these information will cache it efficiently.
* The 3rd & 4th line invalidates the cloudfront cache, so the next time a browser requests for the data, it'll get the latest objects that we just push.

# Wrapping up
That's pretty much it. Now all you need is to add this file into your repository and commit it in and watch the magic happen!